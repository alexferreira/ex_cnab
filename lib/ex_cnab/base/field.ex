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

    with {:ok, _id}      <- Map.fetch(template, :id),
         {:ok, _length}  <- Map.fetch(template, :length),
         {:ok, _format}  <- Map.fetch(template, :format),
         {:ok, _default} <- Map.fetch(template, :default)
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
         {:ok, content} <- content_by_regex(field.default, content),
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
         nil  -> {:ok, content}
         [content] ->
            {:ok, Map.fetch(context, Regex.replace(~r/@/, content, "")
                                     |> String.to_atom)}
    end
  end

  defp content_by_regex(false, content), do: {:ok, content}
  defp content_by_regex(call, content) do
      case Regex.run(~r/%([a-z]|_)+ ([a-z]|_)+%/, call) do
        nil -> {:ok, content}
        _ ->
            list = call
                   |> String.trim("%")
                   |> String.split

            apply(__MODULE__, List.first(list)
                              |> String.to_atom(), [List.last(list)
                                                    |> String.to_atom(), content])
      end
  end

  def enforce_format(field, content) do
    case field.format do
      "int" ->
        content_input(field, {:ok, String.pad_leading(content, field.length, "0")})
      "string" ->
        content_input(field, {:ok, String.pad_trailing(content, field.length, " ")})
      "decimal" ->
        content_input(field, decimal_padding(content, field.length, String.contains?(content, ".")))
      "date" ->
        content_input(field, date_time_handler(content, field.length, String.contains?(content, ["/", "-", ":"])))
      "time" ->
        content_input(field, date_time_handler(content, field.length, String.contains?(content, ["-", ":"])))
        _ ->
        {:error, err(:unrecognized_format)}
    end
  end

  defp content_input(field, {:ok, content}), do: {:ok, %{field | content: content}}
  defp content_input(_, {:error, message}), do: {:error, message}

  defp decimal_padding(content, length, false), do: decimal_padding(Enum.join([content, "0"], "."), length, true)
  defp decimal_padding(content, length, true) do
      decimal_list = content |> String.split(".")
      {:ok,
        [
            decimal_list |> List.first() |> String.pad_leading(length |> List.first, "0"),
            decimal_list |> List.last() |> String.pad_trailing(length |> List.last(), "0")
        ]
        |> Enum.join()}
  end

  defp date_time_handler(content, length, true), do: {:ok, content |> String.replace(["/", ":", "-"], "")|> String.pad_trailing(length, "0")}
  defp date_time_handler(content, length, false) when content == "", do: {:ok, content |> String.pad_trailing(length, "0")}
  defp date_time_handler(_content, _length, false), do: {:error, err(:unrecognized_format, "in date or time")}

  defp enforce_length(field), do: %{field | content: String.slice(field.content, 0, field.length)}

  defp convert_string_keys_to_atom(map), do: for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}

  def get(key, content) do
    with {:ok, map} <- ExCnab.Table.tables() |> Map.fetch(key),
         {:ok, content} <- Map.fetch(map, content)
    do
        {:ok, content}
    else
        :error -> {:error, err(:not_found, Enum.join([key, "or", content], " "))}
    end
  end
end
