defmodule ExCnab.CNAB.Decoder do
  @moduledoc false

  use ExCnab.Logger

  alias ExCnab.Base.Reader, as: Base

  @header_file_batch_number "0000"
  @trailer_file_batch_number "9999"

    def decode(document) do
        data_list = document |> String.trim("\n") |> String.split("\n")

        #Create a map grouped by batches
        #Next create a ExCnab.Document structure
        data_list
        |> Enum.group_by(fn cnab_line -> String.slice(cnab_line, 3, 4) end)
        |> Enum.map(fn {batch_number, register_list} -> {batch_number, decode_batch(batch_number, register_list)} end)
        |> Base.Document.new()
    end

    defp decode_batch(@header_file_batch_number, register_list) do
        register_list |> List.to_string |> decode_header_file()
    end

    defp decode_batch(@trailer_file_batch_number, register_list) do
        register_list |> List.to_string |> decode_trailer_file()
    end

    defp decode_batch(batch_number, register_list) do
        header_batch =
            register_list
            |> Enum.find(fn cnab_line -> String.slice(cnab_line, 7, 1) == "1" end)

        batch_operation = identify_batch_operation(header_batch)

        batch = Enum.map(register_list, fn cnab_line -> decode_batch_by_line(cnab_line, batch_operation) end)

        Base.Batch.new(batch_operation, batch_number, batch)
    end

    defp identify_batch_operation(header_batch) do
        case String.slice(header_batch, 8, 5) do
            "C9801" -> "payment_on_checking"
            "G0770" -> "statement_for_cash_management"
            _ -> nil
        end
    end

    defp decode_batch_by_line(cnab_line, batch_operation) do
        case String.slice(cnab_line, 7, 1) do
            "1" -> decode_header_batch(cnab_line, batch_operation)
            "2" -> decode_init_batch(cnab_line, batch_operation) #NOCOVER
            "3" -> decode_detail(cnab_line, batch_operation)
            "4" -> decode_final_batch(cnab_line, batch_operation) #NOCOVER
            "5" -> decode_trailer_batch(cnab_line, batch_operation)
            _ -> "Invalid CNAB Line"
        end
    end

    defp decode_header_file(cnab_line) do
        info("header_file -> #{cnab_line}")

        build_register("header_file", cnab_line, :header_file)
    end

    defp decode_header_batch(cnab_line, template_suffix) do
        info("header_batch -> #{cnab_line}")

        template_suffix
        |> Kernel.<>("_header_batch")
        |> build_register(cnab_line, :header_batch)
    end

    defp decode_init_batch(cnab_line, template_suffix) do
        info("init_batch -> #{cnab_line}") #NOCOVER

        template_suffix
        |> Kernel.<>("_init_batch")
        |> build_register(cnab_line, :init_batch) #NOCOVER
    end

    defp decode_detail(cnab_line, template_suffix) do
        info("detail -> #{cnab_line}")

        operation_type = String.slice(cnab_line, 13, 1)

        template_suffix
        |> Kernel.<>("_detail_")
        |> Kernel.<>(operation_type)
        |> String.downcase()
        |> build_register(cnab_line, :detail)
    end

    defp decode_final_batch(cnab_line, template_suffix) do
        info("final_batch -> #{cnab_line}") #NOCOVER

        template_suffix
        |> Kernel.<>("_final_batch")
        |> build_register(cnab_line, :final_batch) #NOCOVER
    end

    defp decode_trailer_batch(cnab_line, template_suffix) do
        info("trailer_batch -> #{cnab_line}")

        template_suffix
        |> Kernel.<>("_trailer_batch")
        |> build_register(cnab_line, :trailer_batch)
    end

    defp decode_trailer_file(cnab_line) do
        info("trailer_file -> #{cnab_line}")

        build_register("trailer_file", cnab_line, :trailer_file)
    end

    defp build_register(template_name, cnab_line, register_type) do
        {:ok, template_file} = ExCnab.CNAB.Template.load_json_config(template_name)
        template = %{Atom.to_string(register_type) => template_file}

        register_type_code =
            Application.get_env(:ex_cnab, :structure)
            |> Map.fetch!(:register_types)
            |> Keyword.fetch!(register_type)

        {:ok, register} =
            Base.Register.new(template, cnab_line, register_type, register_type_code)
        register
    end
end
