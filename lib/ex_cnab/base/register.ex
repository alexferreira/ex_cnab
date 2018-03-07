defmodule ExCnab.Base.Register do
  @moduledoc false

  import ExCnab.Error

  alias ExCnab.Base.Field

  defstruct type: nil,
            type_code: nil,
            fieldset: nil

  def new(template, json, type, type_code) do
    register = %__MODULE__{
      type: type,
      type_code: type_code,
      fieldset: load_fieldset(template, json, type_code)
    }
  end

  def load_fieldset(template, json, type) do
    case type do
      0 -> load_header_file(template, json)
      1 -> load_header_batch(template, json)
      2 -> load_init_batch()
      3 -> load_detail()
      4 -> load_final_batch()
      5 -> load_trailer_batch()
      9 -> load_trailer_file()
      _ -> err(:not_recognized_type)
    end
  end

  defp load_header_file(template, json) do

    Enum.map(template["fields"], fn field ->
      case Map.fetch(json, field["id"]) do
        {:ok, value} ->
          Field.from_template(field, value)
        _ ->
          Field.from_template(field, nil)
      end
    end)
    |> Enum.filter(fn(field) -> is_nil(field) == false end)
  end

  defp load_header_batch(template, json) do

    Enum.map(template["fields"], fn field ->
      case Map.fetch(json, field["id"]) do
        {:ok, value} ->
          Field.from_template(field, value)
        _ ->
          Field.from_template(field, nil)
      end
    end)
    |> Enum.filter(fn(field) -> is_nil(field) == false end)
  end

  defp load_init_batch(), do: nil

  defp load_detail(), do: nil

  defp load_final_batch(), do: nil

  defp load_trailer_batch(), do: nil

  defp load_trailer_file(), do: nil
end
