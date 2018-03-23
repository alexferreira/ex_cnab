defmodule ExCnab.Base.Register do
    @moduledoc false

    import ExCnab.Error

    alias ExCnab.Base.Field
    alias ExCnab.CNAB.Template

    defstruct type: nil,
    type_code: nil,
    fieldset: nil

    def new(template, json, type, type_code) do
        with true <- Enum.all?([template, json], fn(n) -> not(Enum.empty?(n)) end),
             {:ok, fieldset} <- load_fieldset(template, json, type_code)
        do
            if type != :detail do
                create_register(type, type_code, fieldset)
            else
                {:ok, fieldset}
            end
        else
          false -> {:error, err :empty_json}
          {:error, message} -> {:error, message}
        end
    end

    defp create_register(type, type_code, fieldset) do
        {:ok, %__MODULE__{
            type: type,
            type_code: type_code,
            fieldset: fieldset}}
    end

    def load_fieldset(template, json, type) do

        case type do
            0 -> load_header_file(template["header_file"], json)
            1 -> load_header_batch(template["header_batch"], json)
            2 -> load_init_batch(template["init_batch"], json)
            3 -> load_detail(template["detail"], json)
            4 -> load_final_batch(template["final_batch"], json)
            5 -> load_trailer_batch(template["trailer_batch"], json)
            9 -> load_trailer_file(template["trailer_file"], json)
            _ -> {:error, err(:not_recognized_type)}
        end
    end

    defp load_header_file(nil, _json), do: {:error, err(:not_found, "Header file")}
    defp load_header_file(template, json) when is_binary(template), do: create_fields_in_template(extract_register_template(template), json)
    defp load_header_file(template, json), do: create_fields_in_template(template, json)
    defp load_header_file({:error, message}, _), do: {:error, message}

    defp load_header_batch(nil, _json), do: {:error, err(:not_found, "Header batch")}
    defp load_header_batch(template, json), do: create_fields_in_template(template, json)

    defp load_init_batch(nil, _json), do: nil
    defp load_init_batch(template, json), do: create_fields_in_template(template, json)

    defp load_detail(nil, _json), do: {:error, err(:not_found, "Details")}
    defp load_detail(template, json) do
        details =
            Enum.map(template, fn {_k, v} ->
                case create_fields_in_template(v, json) do
                    {:ok, fieldset} ->
                        {:ok, register} = create_register(:detail, 3, fieldset)
                        register
                    {:error, message} -> {:error, message}
                end
            end)
        case details do
            {:error, message} -> {:error, message}
            _ -> {:ok, details}
        end
    end

    defp load_final_batch(nil, _json), do: nil
    defp load_final_batch(template, json), do: create_fields_in_template(template, json)

    defp load_trailer_batch(nil, _json), do: {:error, err(:not_found, "Trailer batch")}
    defp load_trailer_batch(template, json), do: create_fields_in_template(template, json)

    defp load_trailer_file(nil, _json), do: {:error, err(:not_found, "Trailer file")}
    defp load_trailer_file(template, json) when is_binary(template), do: create_fields_in_template(extract_register_template(template), json)
    defp load_trailer_file(template, json), do: create_fields_in_template(template, json)

    defp extract_register_template(register_type) do
        case Template.load_json_config_by_regex(register_type) do
            {:ok, extended_template} -> extended_template
            _ -> {:error, err(:not_parse_inheritance)}
        end
    end

    defp create_fields_in_template(template, json) do
        fields =
            Enum.map(template["fields"], fn field ->
                case Map.fetch(json, field["id"]) do
                    {:ok, value} ->
                        Field.from_template(field, value)
                    _ ->
                        Field.from_template(field, nil)
                end
            end)

        case Enum.find(fields, fn n -> is_tuple(n) and elem(n, 0) == :error end) do
            nil -> {:ok, fields}
            {:error, message} -> {:error, message}
        end
    end
end
