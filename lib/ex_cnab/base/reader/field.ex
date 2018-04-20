defmodule ExCnab.Base.Reader.Field do
  @moduledoc false
  import ExCnab.Error

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
      |> searialize_field()
    end
  end

  def searialize_field(field) do
      {field.id, field.content}
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
        {:ok, %{field | content: String.to_integer(content)}}
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
