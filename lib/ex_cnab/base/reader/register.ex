defmodule ExCnab.Base.Reader.Register do
    @moduledoc false

    import ExCnab.Error

    alias ExCnab.Base.Reader.Field

    defstruct type: nil,
    type_code: nil,
    fieldset: nil

    def new(template, cnab_line, type, type_code) do
        with true <- Enum.all?([template], fn(n) -> not(Enum.empty?(n)) end),
             {:ok, fieldset} <- load_fieldset(template, cnab_line, type_code)
        do
            create_register(type, type_code, fieldset)
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

    def load_fieldset(template, cnab_line, type) do

        case type do
            0 -> load_header_file(template["header_file"], cnab_line)
            1 -> load_header_batch(template["header_batch"], cnab_line)
            2 -> load_init_batch(template["init_batch"], cnab_line) #NOCOVER
            3 -> load_detail(template["detail"], cnab_line)
            4 -> load_final_batch(template["final_batch"], cnab_line) #NOCOVER
            5 -> load_trailer_batch(template["trailer_batch"], cnab_line)
            9 -> load_trailer_file(template["trailer_file"], cnab_line)
            _ -> {:error, err(:not_recognized_type)}
        end
    end

    defp load_header_file(nil, _cnab_line), do: {:error, err(:not_found, "Header file")}
    defp load_header_file({:error, message}, _), do: {:error, message}
    defp load_header_file(template, cnab_line), do: create_fields_in_template(template, cnab_line)

    defp load_header_batch(nil, _cnab_line), do: {:error, err(:not_found, "Header batch")}
    defp load_header_batch({:error, message}, _), do: {:error, message}
    defp load_header_batch(template, cnab_line), do: create_fields_in_template(template, cnab_line)

    defp load_init_batch(nil, _cnab_line), do: nil
    defp load_init_batch({:error, message}, _), do: {:error, message}
    defp load_init_batch(template, cnab_line), do: create_fields_in_template(template, cnab_line) #NOCOVER

    defp load_detail(nil, _cnab_line), do: {:error, err(:not_found, "Details")}
    defp load_detail({:error, message}, _), do: {:error, message}
    defp load_detail(template, cnab_line), do: create_fields_in_template(template, cnab_line)

    defp load_final_batch(nil, _cnab_line), do: nil
    defp load_final_batch({:error, message}, _), do: {:error, message}
    defp load_final_batch(template, cnab_line), do: create_fields_in_template(template, cnab_line) #NOCOVER

    defp load_trailer_batch(nil, _cnab_line), do: {:error, err(:not_found, "Trailer batch")}
    defp load_trailer_batch({:error, message}, _), do: {:error, message}
    defp load_trailer_batch(template, cnab_line), do: create_fields_in_template(template, cnab_line)

    defp load_trailer_file(nil, _cnab_line), do: {:error, err(:not_found, "Trailer file")}
    defp load_trailer_file({:error, message}, _), do: {:error, message}
    defp load_trailer_file(template, cnab_line), do: create_fields_in_template(template, cnab_line)

    defp create_fields_in_template(template, cnab_line) do
        fields =
            Enum.map(template["fields"], fn field ->
                value =
                    String.slice(cnab_line, field["offset"], generate_length(field["length"]))
                Field.from_template(field, value)
            end)

        case Enum.find(fields, fn n -> is_tuple(n) and elem(n, 0) == :error end) do
            nil -> {:ok, fields}
            {:error, message} -> {:error, message}
        end
    end

    def generate_length(length) do
        if is_list(length) do
            Enum.reduce(length, 0, fn(x, acc) -> x + acc end)
        else
            length
        end
    end
end
