defmodule JobService.TaskSorterTest do
  use ExUnit.Case
  alias JobService.TaskSorter

  describe "sort" do
    test "sorts empty list" do
      assert TaskSorter.sort([]) == {%{}, [], []}
    end

    test "some dependency" do
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

      {_, task_names, failed_names} = TaskSorter.sort(tasks)
      assert task_names == ["task-1", "task-3", "task-2", "task-4"]
      assert failed_names == []
    end

    test "no dependency" do
      tasks = [
        %{
          "name" => "task-1",
          "command" => "echo cmd 1"
        },
        %{
          "name" => "task-2",
          "command" => "echo cmd 2"
        },
        %{
          "name" => "task-3",
          "command" => "echo cmd 3"
        }
      ]

      {_, task_names, failed_names} = TaskSorter.sort(tasks)
      assert task_names == ["task-1", "task-2", "task-3"]
      assert failed_names == []
    end

    test "circular dependency" do
      tasks = [
        %{
          "name" => "task-1",
          "command" => "echo cmd 1",
          "requires" => ["task-2"]
        },
        %{
          "name" => "task-2",
          "command" => "echo cmd 2",
          "requires" => ["task-1"]
        }
      ]

      {_, task_names, failed_names} = TaskSorter.sort(tasks)
      assert task_names == []
      assert failed_names == ["task-1", "task-2"]
    end

    test "some leaves dependency" do
      tasks = [
        %{
          "name" => "task-1",
          "command" => "echo cmd 1"
        },
        %{
          "name" => "task-2",
          "command" => "echo cmd 2"
        },
        %{
          "name" => "task-3",
          "command" => "echo cmd 3",
          "requires" => ["task-4"]
        },
        %{
          "name" => "task-4",
          "command" => "echo cmd 4",
          "requires" => ["task-3"]
        }
      ]

      {_, task_names, failed_names} = TaskSorter.sort(tasks)
      assert task_names == ["task-1", "task-2"]
      assert failed_names == ["task-3", "task-4"]
    end
  end
end
