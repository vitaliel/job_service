defmodule JobServiceWeb.JobController do
  use JobServiceWeb, :controller
  alias JobService.TaskSorter
  action_fallback JobServiceWeb.FallbackController

  def create(conn, %{"tasks" => tasks}) do
    {task_map, result, failed} = TaskSorter.sort(tasks)

    if Enum.empty?(failed) do
      tasks = result |> Enum.map(fn name -> Map.take(task_map[name], ["name", "command"]) end)
      data = %{tasks: tasks}

      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
      |> Plug.Conn.send_resp(200, Jason.encode!(data, pretty: true))
    else
      render_error(conn, failed)
    end
  end

  def bash(conn, %{"tasks" => tasks}) do
    {task_map, result, failed} = TaskSorter.sort(tasks)

    if Enum.empty?(failed) do
      commands = result |> Enum.map(fn name -> task_map[name]["command"] end)

      data =
        ["#!/usr/bin/env bash" | commands] |> Enum.map(fn cmd -> cmd <> "\n" end) |> Enum.join()

      conn
      |> Plug.Conn.put_resp_header("content-type", "text/x-shellscript; charset=utf-8")
      |> Plug.Conn.send_resp(200, data)
    else
      render_error(conn, failed)
    end
  end

  defp render_error(conn, failed) do
    data = %{error: "Failed to order tasks: #{Enum.join(failed, ",")}"}

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
    |> Plug.Conn.send_resp(422, Jason.encode!(data, pretty: true))
  end
end
