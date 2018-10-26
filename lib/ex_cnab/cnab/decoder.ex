defmodule ExCnab.CNAB.Decoder do
  @moduledoc false

  use ExCnab.Logger

  import ExCnab.Error

  alias ExCnab.Base.Reader, as: Base

  @header_file_batch_number "0000"
  @trailer_file_batch_number "9999"

  @diverse_payment "C9801"
  @vendor_payment "C2001"
  @vendor_ted_payment "C2003"
  @vendor_ted_payment_2 "C2041"
  @statement_for_cash_management "G0770"

    def decode(document) do
        data_list = document |> String.trim("\n") |> String.split("\n")

        #Create a map grouped by batches
        #Next create a ExCnab.Document structure
        data_list
        |> Enum.group_by(fn cnab_line -> String.slice(cnab_line, 3, 4) end)
        |> Enum.map(fn {batch_number, register_list} -> decode_batch(batch_number, register_list) end)
        |> Enum.reject(&is_nil/1)
        |> Base.Document.new()
    end

    defp decode_batch(@header_file_batch_number, register_list) do
        header_file = register_list |> List.to_string |> decode_header_file()
        {@header_file_batch_number, header_file}
    end

    defp decode_batch(@trailer_file_batch_number, register_list) do
        trailer_file = register_list |> List.to_string |> decode_trailer_file()
        {@trailer_file_batch_number, trailer_file}
    end

    defp decode_batch(batch_number, register_list) do
        header_batch =
            register_list
            |> Enum.find(fn cnab_line -> String.slice(cnab_line, 7, 1) == "1" end)

        case identify_batch_operation(header_batch) do
            {:ok, batch_operation} ->
                batch = Enum.map(register_list, fn cnab_line -> decode_batch_by_line(cnab_line, batch_operation) end)
                {batch_number, Base.Batch.new(batch_operation, batch_number, batch)}
            {:error, _} ->
                nil
        end
    end

    defp identify_batch_operation(header_batch) do
        case String.slice(header_batch, 8, 5) do
            @diverse_payment -> {:ok, "payment_on_checking"}
            @vendor_payment -> {:ok, "payment_on_checking"}
            @vendor_ted_payment -> {:ok, "payment_on_checking"}
            @vendor_ted_payment_2 -> {:ok, "payment_on_checking"}
            @statement_for_cash_management -> {:ok, "statement_for_cash_management"}
            _ -> {:error, err :batch_operation_not_found}
        end
    end

    defp decode_batch_by_line(cnab_line, batch_operation) do
        case String.slice(cnab_line, 7, 1) do
            "1" -> decode_header_batch(cnab_line, batch_operation)
            "2" -> decode_init_batch(cnab_line, batch_operation)
            "3" -> decode_detail(cnab_line, batch_operation)
            "4" -> decode_final_batch(cnab_line, batch_operation)
            "5" -> decode_trailer_batch(cnab_line, batch_operation)
            _ -> "Invalid CNAB Line"
        end
    end

    defp decode_header_file(cnab_line) do
        pre_build(cnab_line, :header_file)
    end

    defp decode_header_batch(cnab_line, template_suffix) do
        pre_build(cnab_line, template_suffix, :header_batch)
    end

    defp decode_init_batch(cnab_line, template_suffix) do
        pre_build(cnab_line, template_suffix, :init_batch)
    end

    defp decode_detail(cnab_line, template_suffix) do
        pre_build(cnab_line, template_suffix, :detail)
    end

    defp decode_final_batch(cnab_line, template_suffix) do
        pre_build(cnab_line, template_suffix, :final_batch)
    end

    defp decode_trailer_batch(cnab_line, template_suffix) do
        pre_build(cnab_line, template_suffix, :trailer_batch)
    end

    defp decode_trailer_file(cnab_line) do
        pre_build(cnab_line, :trailer_file)
    end

    #Prepare the template name and calls build_register
    defp pre_build(cnab_line, register_type) do
        info("#{register_type} -> #{cnab_line}")

        register_type
        |> Atom.to_string
        |> build_register(cnab_line, register_type)
    end
    defp pre_build(cnab_line, template_suffix, register_type = :detail) do
        info("#{register_type} -> #{cnab_line}")

        operation_type = String.slice(cnab_line, 13, 1)

        template_suffix
        |> Kernel.<>("_detail_")
        |> Kernel.<>(operation_type)
        |> String.downcase()
        |> build_register(cnab_line, register_type)
    end
    defp pre_build(cnab_line, template_suffix, register_type) do
        info("#{register_type} -> #{cnab_line}")

        register_type_string =
            register_type
            |> Atom.to_string()

        template_suffix
        |> Kernel.<>("_")
        |> Kernel.<>(register_type_string)
        |> build_register(cnab_line, register_type)
    end

    #Load the template and calls Register.new()
    defp build_register(template_name, cnab_line, register_type) do
        with {:ok, template_file} <- ExCnab.CNAB.Template.load_json_config(template_name),
             {:ok, template} <- template_maker(template_file, register_type),
             {:ok, register} <- Base.Register.new(template, cnab_line, register_type)
        do
            register
        else
            {:error, _} ->
                nil
        end
    end

    def template_maker(template_file, register_type) do
        template = %{Atom.to_string(register_type) => template_file}
        {:ok, template}
    end
end
