defmodule ExCnab.Base.Field do
  @moduledoc false
  import ExCnab.Error

  defstruct id: nil,
            length: nil,
            format: nil,
            default: nil,
            content: nil

  def from_template(template, content) do
    template = convert_string_keys_to_atom(template)

    with {:ok, id}      <- Map.fetch(template, :id),
         {:ok, length}  <- Map.fetch(template, :length),
         {:ok, format}  <- Map.fetch(template, :format),
         {:ok, default} <- Map.fetch(template, :default)
    do
      struct(__MODULE__, Keyword.new(template))
      |> set_content_field(content)
    end
  end

  defp set_content_field(field, nil) do
    if field.default == false do
      nil
    else
      set_content_field(field, field.default)
    end
  end

  defp set_content_field(field, content) do
    case enforce_format(field, content) do
      {:ok, field} -> enforce_length(field)
      err -> err
    end
  end

  defp enforce_format(field, content) do
    case field.format do
      "int" ->
        {:ok, %{field | content: String.pad_leading(content, field.length, "0")}}
      "string" ->
        {:ok, %{field | content: String.pad_trailing(content, field.length, " ")}}
      _ ->
        {:error, err(:unrecognized_format)}
    end
  end

  defp enforce_length(field) do
    %{field | content: String.slice(field.content, 0, field.length)}
  end

  defp convert_string_keys_to_atom(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end

end
