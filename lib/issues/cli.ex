defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
  Return a tuple of `{ user, project, count }`, or `:help` if help was given
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])

    parse |> result_parser
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({ user, project, count }) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> convert_list_to_map
    |> sort_in_ascending_order
    |> Enum.take(count)
    |> Issues.TableFormatter.print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, :message, 0)
    IO.puts "Error from Github with #{message}"
    System.halt(2)
  end

  def convert_list_to_map(list) do
    list
    |> Enum.map(&Enum.into(&1, Map.new))
  end

  def sort_in_ascending_order(list_of_issues) do
    Enum.sort(list_of_issues, fn(i1, i2) -> i1["created_at"] <= i2["created_at"] end)
  end

  defp result_parser({ [ help: true ], _, _ }), do: :help
  defp result_parser({ _, [ user, project, count ], _ }), do: { user, project, count }
  defp result_parser({ _, [ user, project ], _ }), do: { user, project, @default_count }
  defp result_parser(_), do: :help

end
