defmodule Issues.TableFormatter do
  def print_table_for_columns(rows, headers) do
    data_for_columns = split_into_columns(rows, headers)
    column_width = widths_for(data_for_columns)
    format = format_for(column_width)

    
  end

  defp split_into_columns(rows, headers) do
    for header -> headers, do
      for row -> rows, do: printable(row[header])
    end
  end
end
