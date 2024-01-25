defmodule JobServiceWeb.JobControllerTest do
  use JobServiceWeb.ConnCase

  describe "create job" do
    test "sort tasks", %{conn: conn} do
      tasks = [
        %{
          "name" => "task-1",
          "command" => "echo cmd 1"
        },
        %{
          "name" => "task-2",
          "command" => "echo cmd 2",
          "requires" => ["task-3"]
        },
        %{
          "name" => "task-3",
          "command" => "echo cmd 3",
          "requires" => ["task-1"]
        },
        %{
          "name" => "task-4",
          "command" => "echo cmd 4",
          "requires" => ["task-2", "task-3"]
        }
      ]

      conn = post(conn, ~p"/api/jobs", tasks: tasks)
      tasks = json_response(conn, 200)["tasks"]

      assert tasks == [
               %{
                 "name" => "task-1",
                 "command" => "echo cmd 1"
               },
               %{
                 "name" => "task-3",
                 "command" => "echo cmd 3"
               },
               %{
                 "name" => "task-2",
                 "command" => "echo cmd 2"
               },
               %{
                 "name" => "task-4",
                 "command" => "echo cmd 4"
               }
             ]
    end

    test "sorting failed", %{conn: conn} do
      tasks = [
        %{
          "name" => "task-2",
          "command" => "echo cmd 2",
          "requires" => ["task-3"]
        },
        %{
          "name" => "task-3",
          "command" => "echo cmd 3",
          "requires" => ["task-1"]
        },
        %{
          "name" => "task-4",
          "command" => "echo cmd 4"
        }
      ]

      conn = post(conn, ~p"/api/jobs", tasks: tasks)
      error = json_response(conn, 422)["error"]
      assert error == "Failed to order tasks: task-2,task-3"
    end
  end

  describe "create bash script" do
    test "generates script", %{conn: conn} do
      tasks = [
        %{
          "name" => "task-1",
          "command" => "echo cmd 1"
        },
        %{
          "name" => "task-2",
          "command" => "echo cmd 2",
          "requires" => ["task-3"]
        },
        %{
          "name" => "task-3",
          "command" => "echo cmd 3",
          "requires" => ["task-1"]
        },
        %{
          "name" => "task-4",
          "command" => "echo cmd 4",
          "requires" => ["task-2", "task-3"]
        }
      ]

      conn = post(conn, ~p"/api/jobs/bash", tasks: tasks)

      assert conn.resp_body ==
               "#!/usr/bin/env bash\necho cmd 1\necho cmd 3\necho cmd 2\necho cmd 4\n"
    end
  end
end
