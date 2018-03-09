defmodule ExCnab.Base.Register do
    @moduledoc false

    import ExCnab.Error

    alias ExCnab.Base.Field

    defstruct type: nil,
    type_code: nil,
    fieldset: nil

    def new(template, json, type, type_code) do
        with true <- Enum.all?([template, json], fn(n) -> not(Enum.empty?(n)) end),
             {:ok, fieldset} <- load_fieldset(template, json, type_code)
        do
            {:ok, _register = %__MODULE__{
                type: type,
                type_code: type_code,
                fieldset: fieldset}}
        else
          false -> {:error, err :empty_json}
          {:error, message} -> {:error, message}
        end
    end

    def load_fieldset(template, json, type) do
        case type do
            0 -> {:ok, load_header_file(template["header_file"], json)}
            1 -> {:ok, load_header_batch(template["header_batch"], json)}
            2 -> {:ok, load_init_batch(template["init_batch"], json)}
            3 -> {:ok, load_detail(template["detail"]["a_segment"], json)}
            4 -> {:ok, load_final_batch(nil, json)}
            5 -> {:ok, load_trailer_batch(template["trailer_batch"], json)}
            9 -> {:ok, load_trailer_file(template["trailer_file"], json)}
            _ -> {:error, err(:not_recognized_type)}
        end
    end

    defp load_header_file(template, json), do: create_fields_in_template(template, json)

    defp load_header_batch(template, json), do: create_fields_in_template(template, json)

    defp load_init_batch(nil, _json), do: nil
    defp load_init_batch(template, json), do: create_fields_in_template(template, json)

    defp load_detail(nil, _json), do: nil
    defp load_detail(template, json) do
        create_fields_in_template(template, json)
    end

    defp load_final_batch(nil, _json), do: nil
    defp load_final_batch(template, json), do: create_fields_in_template(template, json)

    defp load_trailer_batch(nil, _json), do: nil
    defp load_trailer_batch(template, json), do: create_fields_in_template(template, json)

    defp load_trailer_file(nil, _json), do: nil
    defp load_trailer_file(template, json), do: create_fields_in_template(template, json)

    defp create_fields_in_template(template, json) do
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
end
