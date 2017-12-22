defmodule GithubIssuesTest do
  use ExUnit.Case
  doctest Issues.GithubIssues

  import Issues.CLI, only: [ parse_args: 1,
                             convert_list_to_map: 1,
                             sort_in_ascending_order: 1 ]

  test ":help returned by option parsing with -h and --help options" do
    assert(parse_args(["-- help","anything"])) == :help
    assert(parse_args(["- h","anything"])) == :help
  end

  test "three values returned if three given" do
    assert(parse_args(["user","project-name", 99])) == {"user","project-name", 99 }
  end

  test "count is default value if two values given" do
    assert(parse_args(["user","project-name" ])) == { "user", "project-name", 4}
  end

  test "sort ascending orders the correct order" do
    results = sort_in_ascending_order(fake_created_at_list(["c", "b", "a"]))
    issues = for issue <- results, do: issue["created_at"]

    assert issues == ~w(a b c)
  end

  defp fake_created_at_list(values) do
    data = for value <- values,
           do: [{ "created_at", value }, { "other_data", "stuff" }]
    convert_list_to_map(data)
  end

end
