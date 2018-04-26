defmodule ExCnab.Base.Reader.Field do
  @moduledoc false
  import ExCnab.Error

  @table_call_regex ~r/%([a-z]|_)+ ([a-z]|_)+%/

  defstruct id: nil,
            length: nil,
            format: nil,
            default: nil,
            content: nil

  def from_template(template, content) do
    template = convert_string_keys_to_atom(template)

    with {:ok, _id}      <- Map.fetch(template, :id),
         {:ok, _length}  <- Map.fetch(template, :length),
         {:ok, _format}  <- Map.fetch(template, :format),
         {:ok, _default} <- Map.fetch(template, :default)
    do
      struct(__MODULE__, Keyword.new(template))
      |> set_content_field(content)
      |> searialize_field(Application.get_env(:ex_cnab, :replace_code_to_string, false))
    end
  end

  defp searialize_field(field, config)
  defp searialize_field(field, false) do
       {field.id, field.content}
  end

  defp searialize_field(field, true) do
        case field.id |> String.contains?("occurrences") do
            true -> handle_occurences(field)
            false -> handle_others(field)
        end
  end

  defp handle_occurences(field) do
      case get_occurences(field.content) do
        "" -> {field.id, field.content}
        list -> {field.id, list}
      end
  end

  defp get_occurences(content, acc \\ [])
  defp get_occurences(content, acc) when content == "", do: list_occurences(acc)
  defp get_occurences(content, acc) do
    occurrence =
        content
        |> String.slice(0..1)

    get_occurences(
            String.replace(content, occurrence, ""),
            acc ++ [occurrence])
  end

  defp list_occurences(ocurrences_list) when ocurrences_list == [], do: ""
  defp list_occurences(ocurrences_list) do
    ocurrences_list
    |> Enum.map(fn n -> extract_content(:occurrences, n) end)
  end

  defp handle_others(field) do
        case check_regex(field, field.content) do
            nil ->
                {field.id, field.content}
            content ->
                {field.id, content}
        end
  end

  def check_regex(%{default: false}, _content), do: nil
  def check_regex(field, content) do
    case Regex.run(@table_call_regex, field.default) do
        nil -> nil
        _ ->   field.default
               |> String.trim("%")
               |> String.split
               |> Enum.at(1)
               |> String.to_atom()
               |> extract_content(content, field.length)
    end
  end

  defp extract_content(table, key, length) do
      if not is_binary(key) do
          extract_content(table, Integer.to_string(key)
                                         |> String.pad_leading(length, "0"))
      else
          extract_content(table, key)
      end
  end

  defp extract_content(table_name, key) do
    case ExCnab.Table.tables() |> Map.fetch(table_name)do
        {:ok, table} ->
            Enum.map(table, fn {k, v} -> {v, k} end)
            |> Enum.into(%{})
            |> Map.get(key)

        :error -> nil
    end
  end

  defp set_content_field(field, content) do
    case enforce_format(field, content) do
      {:ok, field} -> field
      err -> err
    end
  end

  def enforce_format(field, content) do
    case field.format do
      "int" ->
        {:ok, %{field | content: content}}
      "string" ->
        {:ok, %{field | content: String.trim(content)}}
      "decimal" ->
        {:ok, %{field | content: decimal_formatter(content, field.length)}}
      "date" ->
        {:ok, %{field | content: date_formatter(content)}}
      "time" ->
        {:ok, %{field | content: time_formatter(content)}}
        _ ->
        {:error, err(:unrecognized_format)}
    end
  end

  defp decimal_formatter(content, length) do
      [content |> String.slice(0, length |> List.first),
       content |> String.slice(length |> List.first, length |> List.last)]
       |> Enum.join(".")
       |> String.trim_leading("0")
  end

  defp date_formatter(content) do
      [content |> String.slice(0, 2),
       content |> String.slice(2, 2),
       content |> String.slice(4, 4)]
       |> Enum.join("/")
  end

  defp time_formatter(content) do
      [content |> String.slice(0, 2),
       content |> String.slice(2, 2),
       content |> String.slice(4, 2)]
       |> Enum.join("-")
  end

  defp convert_string_keys_to_atom(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
