defmodule ExCnab.CNAB.Encoder do
  @moduledoc false

  import ExCnab.Error

    def encode(json) do
        global_config = load_global_config()

        case load_encoder_template(json) do
            {:ok, encoder_template} ->
                json = prepare_json(json)
                start_encode(global_config, encoder_template, json)
            error ->
                error
        end
    end

    defp load_global_config() do
        Application.get_env(:ex_cnab, :structure)
    end

    defp load_encoder_template(json) do
      case Map.fetch(json, "operation") do
            :error ->
                {:error, err(:operation_not_found)}
            {:ok, operation} ->
                load_json_config(operation)
        end
    end

    def load_json_config(operation) do
        path = build_template_path(operation)

        case File.read(path) do
            {:ok, file} ->
                Poison.decode(file)
            err ->
                err
        end
    end

    defp build_template_path(operation) do
      template_path =
          Application.get_env(:ex_cnab, :cnab_fieldset_templates)
          |> Path.join("#{operation}.json")

      path =
            :code.priv_dir(:ex_cnab)
            |> Path.join(template_path)
            |> Path.absname
            |> Path.expand()
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
        document = ExCnab.Base.Document.new(config, encoder_template, json)
        document
    end

end
