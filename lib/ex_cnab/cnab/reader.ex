defmodule ExCnab.CNAB.Reader do
    @moduledoc false
    alias ExCnab.CNAB

    @template_path "/ex_cnab/reader/templates"

    def read_cnab(cnab_path) do
        {:ok, document} = File.read(cnab_path)

        cnab_decoded = CNAB.Decoder.decode(document)

        #Create a json from a cnab_decoded structure
        file_json = create_file_json(cnab_decoded.content.header_file,
                                            cnab_decoded.content.trailer_file)
        batches_json = create_batches_json(cnab_decoded.content.batches)

        %{
            "file" => file_json,
            "batches" => batches_json
        }
        |> Poison.encode()
    end

    defp create_file_json(header_file, trailer_file) do
        {:ok, template_json } = load_json_config("header_trailer_file")

        header_file_fieldset =
            header_file.fieldset
            |> serialize_fieldset_map()

        trailer_file_fieldset =
            trailer_file.fieldset
            |> serialize_fieldset_map()

        template_json
        |> Enum.map(fn {template_key, _template_value} ->
            case Map.fetch(header_file_fieldset, "file_" <> template_key) do
                {:ok, value} ->
                    {template_key, value}
                _ ->
                    case Map.fetch(trailer_file_fieldset, "file_" <> template_key) do
                        {:ok, value} ->
                            {template_key, value}
                        _ ->
                            {template_key, nil}
                    end
            end
        end)
        |> serialize_fieldset_map()
    end

    #iterate the batches list
    #find the template to each batch operation
    #generate a json batches list
    defp create_batches_json(batches) do
        batches
        |> Enum.map(fn batch ->
            batch_handler(batch.batch_number, batch.operation, batch.content)
        end)
    end

    defp batch_handler(_number, operation, content) do
        #Find all templates
        {:ok, batch_json} = load_json_config("header_trailer_batch")
        {:ok, detail_json} = load_json_config(operation)

        #Create Header batch and Trailer Batch json map
        header_batch_fieldset =
            content
            |> Enum.find(fn register -> register.type_code == 1 end)
            |> Map.get(:fieldset)
            |> serialize_fieldset_map

        trailer_batch_fieldset =
            content
            |> Enum.find(fn register -> register.type_code == 5 end)
            |> Map.get(:fieldset)
            |> serialize_fieldset_map

        batch_header_trailer =
            batch_json
            |> Enum.map(fn {k, _v} ->
                case Map.fetch(header_batch_fieldset, "batches_" <> k) do
                    {:ok, value} ->
                        {k, value}
                    _ ->
                        case Map.fetch(trailer_batch_fieldset, "batches_" <> k) do
                            {:ok, value} ->
                                {k, value}
                                _ ->
                                {k, nil}
                        end
                end
            end)
            |> serialize_fieldset_map()

        #Create Detail
        batch_detail_list =
            content
            |> Enum.filter(fn register -> register.type_code == 3 end)
            |> Enum.filter(fn register ->
                register.fieldset
                |> serialize_fieldset_map
                |> Map.get("batches_payments_segment") == first_detail(operation)
            end)
            |> Enum.map(fn detail ->
                create_detail_register(detail.fieldset |> serialize_fieldset_map(),
                                       detail_json, operation)
            end)

        #Construct the map of batches
        batch_header_trailer
        |> Map.put(preffix(operation), batch_detail_list)
    end

    # Create a detail register json according to the template
    defp create_detail_register(register_fieldset, template_json, operation) do
        template_json
        |> Enum.map(fn {k, _v} ->
            case Map.fetch(register_fieldset, "batches_" <> preffix(operation) <> "_" <> k) do
                {:ok, value} ->
                    {k, value}
                _ ->
                    {k, nil}
            end
        end)
        |> serialize_fieldset_map()
    end

    defp preffix(operation) do
        case operation do
            "payment_on_checking" -> "payments"
            "statement_for_cash_management" -> "statements"
            _ -> nil
        end
    end

    defp first_detail(operation) do
        case operation do
            "payment_on_checking" -> "A"
            "statement_for_cash_management" -> "F"
            _ -> nil
        end
    end

    #Transform a two element tuple list into a map
    defp serialize_fieldset_map(fieldset) do
        fieldset |> Map.new(fn {a,b} -> {a,b} end)
    end

    #Load json template
    defp load_json_config(name) do
        path = build_template_path(name)

        with {:ok, file} <- File.read(path),
             {:ok, json_map} <- Poison.decode(file)
        do
            {:ok, json_map}
        else
            err -> err
        end
    end

    defp build_template_path(name) do
      template_path =
          @template_path
          |> Path.join("#{name}.json")

      _path =
            :code.priv_dir(:ex_cnab)
            |> Path.join(template_path)
            |> Path.absname
            |> Path.expand()
    end
end
