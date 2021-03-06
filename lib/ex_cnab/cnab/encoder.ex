defmodule ExCnab.CNAB.Encoder do
  @moduledoc false

    import ExCnab.Error

    alias ExCnab.CNAB.Template
    alias ExCnab.Table

    def encode(json) do
        config = Table.structure

        case load_encoder_template(json) do
            {:ok, encoder_template} ->
                json = prepare_json(json)
                start_encode(config, encoder_template, json)
            error ->
                error
        end
    end

    defp load_encoder_template(json) do
      case Map.fetch(json, "operation") do
            :error ->
                {:error, err(:operation_not_found)}
            {:ok, operation} ->
                Template.load_json_config(operation)
      end
    end

    def prepare_json(%{} = json) when json == %{}, do: %{}
    def prepare_json(%{} = json) do
        json
        |> Map.to_list()
        |> prepare_key_value(%{})
    end

    defp prepare_key_value([{k, %{} = v} | t], acc), do: prepare_key_value(map_inheritance(k, v), prepare_key_value(t, acc))
    defp prepare_key_value([{k, v} | t], acc), do: prepare_key_value(t, Map.put_new(acc, k, v))
    defp prepare_key_value([], acc), do: acc

    defp map_inheritance(key, value) when is_map(value) do
        Enum.map(value, fn {k, v} -> {Enum.join([key, k], "_"), v} end)
    end

    defp start_encode(config, encoder_template, json) do
        ExCnab.Base.Document.new(config, encoder_template, json)
    end
end
