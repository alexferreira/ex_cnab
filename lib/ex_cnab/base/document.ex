defmodule ExCnab.Base.Document do
  @moduledoc false
  import ExCnab.Error

  defstruct type: nil,
            content: nil

  def new(config, template, json) when is_map(json) do
    case not(Enum.empty?(template)) and not(Enum.empty?(json)) do
        true ->
                {:ok, %__MODULE__{
                    type: json["operation"],
                    content: load_content(template, json)}}

        false -> {:error, err :empty_json}
    end
  end

  def load_content(template, json) do
    [header_file(template, json),
    batches(template, json),
    trailer_file(template, json)]
  end

  # defp load_content(config, template, json) do
  #   # header_file = header_file()
  #
  #   Enum.map(template.structure, fn register_type ->
  #     register_type = Map.fetch!(config.structure, String.to_atom(register_type))
  #     case register_type do
  #       :batch : ""
  #     end
  #     {key, Map.fetch(template, Atom.to_string(key))
  #     |> load_register(json, key, value)}
  #   end)
  #   |> Enum.filter(fn(field) -> is_nil(field) == false end)
  # end
  defp header_file(template, json) do
    {:ok, register} = ExCnab.Base.Register.new(template, json, :header_file, 0)
    register
  end

  defp batches(template, json) do
      {:ok, register} = ExCnab.Base.Register.new(template, json, :header_batch, 1)
      register
  end

  defp trailer_file(_template, _json) do
      nil
  end

  defp load_register(:error, _, _, _) do
    nil
  end

  defp load_register({:ok, template}, json, key, value) do
    {:ok, register} = ExCnab.Base.Register.new(template, json, key, value)
  end

  defp fill_document(operation, header) do
    document = %__MODULE__{
      type: operation,
      content: %{
        header: header
      }
    }

    {:ok, document}
  end

  defp load_type(json) do
    case Map.fetch(json, "operation") do
      :error ->
        {:error, err(:operation_not_found)}

      operation ->
        operation
    end
  end
end
