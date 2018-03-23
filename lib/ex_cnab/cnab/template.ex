defmodule ExCnab.CNAB.Template do

  import ExCnab.Error
  
  @regex ~r/\{\{([a-zA-Z0-9\.\_]+)\}\}/

  def load_json_config_by_regex(name) do
      case Regex.match?(@regex, name) do
        true ->
          Regex.run(@regex, name, capture: :all_but_first)
          |> List.first()
          |> load_json_config()
        false ->
          {:error, err(:not_parse_inheritance)}
      end
  end

  def load_json_config(name) do
      path = build_template_path(name)

      case File.read(path) do
          {:ok, file} ->
              Poison.decode(file)
          err ->
              err
      end
  end

  defp build_template_path(name) do
    template_path =
        Application.get_env(:ex_cnab, :cnab_fieldset_templates)
        |> Path.join("#{name}.json")

    path =
          :code.priv_dir(:ex_cnab)
          |> Path.join(template_path)
          |> Path.absname
          |> Path.expand()
  end
end
