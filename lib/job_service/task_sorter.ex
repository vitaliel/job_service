defmodule JobService.TaskSorter do
  def sort([]) do
    {%{}, [], []}
  end

  def sort(tasks) do
    tasks = tasks |> Enum.map(fn x -> Map.put_new(x, "requires", []) end)
    task_map = tasks |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x["name"], x) end)
    {top_tasks, child_tasks} = tasks |> Enum.split_with(fn x -> Enum.empty?(x["requires"]) end)
    top_tasks = top_tasks |> extract_name
    child_tasks = child_tasks |> extract_name

    {result, failed} = try_sort(task_map, top_tasks, child_tasks)
    {task_map, result, failed}
  end

  defp try_sort(_task_map, [], children) do
    {[], children}
  end

  defp try_sort(_task_map, result, []) do
    {result, []}
  end

  defp try_sort(task_map, result, children) do
    next_task =
      children
      |> Enum.find(fn x ->
        Enum.all?(task_map[x]["requires"], &Enum.member?(result, &1))
      end)

    if next_task do
      children = List.delete(children, next_task)
      try_sort(task_map, result ++ [next_task], children)
    else
      {result, children}
    end
  end

  defp extract_name(tasks) do
    tasks |> Enum.map(fn x -> x["name"] end)
  end
end
