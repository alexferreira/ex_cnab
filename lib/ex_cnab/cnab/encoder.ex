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

  defp start_encode(config, encoder_template, json) do
    document = ExCnab.Document.new(config, encoder_template, json)

    {:ok, document}
  end

  defp load_global_config() do
    Application.get_env(:ex_cnab, :structure)
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

  def prepare_key_value(ancestor_key, map) when is_map(map) do
    key = Map.keys(map) |> elem(0)
    "#{ancestor_key}_#{key}" |> prepare_key_value(Map.fetch!(map, key) )
  end

  def prepare_key_value(key, value) do
    %{key: value}
  end

  def prepare_json(json) do
    Enum.map(json, fn(k, v) ->
      prepare_key_value(k, v)
    end)
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

  defp load_encoder_template(json) do
    case Map.fetch(json, "operation") do
      :error ->
        {:error, err(:operation_not_found)}
      {:ok, operation} ->
        {:ok, load_json_config(operation)}
    end
  end
end
