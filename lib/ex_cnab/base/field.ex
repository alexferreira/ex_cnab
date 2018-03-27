defmodule ExCnab.Base.Field do
  @moduledoc false
  import ExCnab.Error

  defstruct id: nil,
            length: nil,
            format: nil,
            default: nil,
            content: nil

  def from_template(template, content, context) do
    template = convert_string_keys_to_atom(template)

    with {:ok, id}      <- Map.fetch(template, :id),
         {:ok, length}  <- Map.fetch(template, :length),
         {:ok, format}  <- Map.fetch(template, :format),
         {:ok, default} <- Map.fetch(template, :default)
    do
      struct(__MODULE__, Keyword.new(template))
      |> set_content_field(content, context)
    end
  end

  defp set_content_field(field, nil, context) do
    if field.default == false do
        {:error, err(:not_found, field.id)}
    else
      set_content_field(field, content_extract(field.default, context), context)
    end
  end

  defp set_content_field(field, {:ok, content}, context), do: set_content_field(field, content, context)
  defp set_content_field(field, :error, _context), do: {:error, err(:not_found_context, field.id)}
  defp set_content_field(field, content, _context) do
    with true <- is_binary(content),
         {:ok, field} <- enforce_format(field, content)
    do
        enforce_length(field)
    else
        false -> set_content_field(field, Integer.to_string(content), %{})
        err -> err
    end
  end


  defp content_extract(content, context) do
    case Regex.run(~r/@.+/, content) do
        nil -> content
        [new_content] ->
            atom = Regex.replace(~r/@/, new_content, "") |> String.to_atom
            Map.fetch(context, atom)
    end
  end

  def enforce_format(field, content) do
    case field.format do
      "int" ->
        {:ok, %{field | content: String.pad_leading(content, field.length, "0")}}
      "string" ->
        {:ok, %{field | content: String.pad_trailing(content, field.length, " ")}}
      "decimal" ->
        {:ok, %{field | content: decimal_padding(content, field.length, String.contains?(content, ","))}}
      "date" ->
        {:ok, %{field | content: date_handler(content, field.length, String.contains?(content, "/"))}}
        _ ->
        {:error, err(:unrecognized_format)}
    end
  end

  defp decimal_padding(content, length, false), do: decimal_padding(Enum.join([content, "0"], ","), length, true)
  defp decimal_padding(content, length, true) do
      decimal_list = content |> String.split(",")
      [
       decimal_list |> List.first() |> String.pad_leading(length |> List.first, "0"),
       decimal_list |> List.last() |> String.pad_trailing(length |> List.last(), "0")
      ]
      |> Enum.join()
  end

  defp date_handler(content, length, true), do: content |> String.split("/") |> Enum.join |> String.pad_trailing(length, " ")
  defp date_handler(content, length, false), do: content |> String.split("-") |> Enum.join |> String.pad_trailing(length, " ")

  defp enforce_length(field) do
    %{field | content: String.slice(field.content, 0, field.length)}
  end

  defp convert_string_keys_to_atom(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
