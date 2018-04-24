defmodule ExCnab.CNAB.Reader do
    @moduledoc false
    import ExCnab.Error

    alias ExCnab.CNAB

    @template_path "/ex_cnab/reader/templates"
    @path_file_folder "file"

    def read_cnab(cnab_path) do
        {:ok, document} = File.read(cnab_path)

        cnab_decoded = CNAB.Decoder.decode(document)

        #Create a json from a cnab_decoded structure
        header_trailer_file_json =
            create_header_trailer_file_json(cnab_decoded.content.header_file,
                                            cnab_decoded.content.trailer_file)
        batches_json = create_batches_json(cnab_decoded.content.batches)

        header_trailer_file_json
        |> Map.put("batches", batches_json)
        |> Poison.encode()
    end

    defp create_header_trailer_file_json(header_file, trailer_file) do
        #Load all templates
        with {:ok, header_trailer_file_template} <- load_json_template(@path_file_folder, "header_trailer_file"),
             {:ok, header_file_template} <- load_json_template(@path_file_folder, "header_file"),
             {:ok, company_informations_template} <- load_json_template(@path_file_folder, "company_informations"),
             {:ok, company_address_informations_template} <- load_json_template(@path_file_folder, "company_address_informations")
        do
            header_file_fieldset =
                header_file.fieldset
                |> serialize_fieldset_map()

            trailer_file_fieldset =
                trailer_file.fieldset
                |> serialize_fieldset_map()

            header_trailer_file_fieldset =
                Map.merge(header_file_fieldset, trailer_file_fieldset)

            file_json =
                header_trailer_file_template
                |> create_json("file_", header_trailer_file_fieldset)

            header_file_json =
                header_file_template
                |> create_json("", header_file_fieldset)

            company_informations_json =
                company_informations_template
                |> create_json("company_", header_file_fieldset)

            company_address_informations_json =
                company_address_informations_template
                |> create_json("company_address_", header_file_fieldset)

            #Construct the result map
            company_informations_json =
                company_informations_json
                |> Map.put("address", company_address_informations_json)

            header_file_json
            |> Map.put("file", file_json)
            |> Map.put("company", company_informations_json)
        else
            err -> err
        end
    end

    defp create_json(template_json, suffix, fieldset) do
        template_json
        |> Enum.map(fn {template_key, _template_value} ->
            match_template_with_fieldset(template_key, suffix, fieldset)
        end)
        |> serialize_fieldset_map()
    end

    #Iterate the batches list
    #Find the template to each batch operation
    #Generate a json batches list
    defp create_batches_json(batches) do
        batches
        |> Enum.map(fn batch ->
            batch_handler(batch.batch_number, batch.operation, batch.content)
        end)
    end

    defp batch_handler(_number, operation, content) do
        #Load all templates
        with {:ok, batch_json} <- load_json_template(operation, "header_trailer_batch"),
             {:ok, detail_json} <- load_json_template(operation, "detail")
        do
            #Create Header batch and Trailer Batch json map
            header_batch_fieldset =
                extract_fieldset_from_batch(content, :header_batch)

            trailer_batch_fieldset =
                extract_fieldset_from_batch(content, :trailer_batch)

            header_trailer_batch_fieldset =
                Map.merge(header_batch_fieldset, trailer_batch_fieldset)

            header_trailer_batch =
                batch_json
                |> Enum.map(fn {template_key, _template_value} ->
                    match_template_with_fieldset(template_key, "batches_", header_trailer_batch_fieldset)
                end)
                |> serialize_fieldset_map()

            #Create Detail list
            batch_detail_list = create_detail_batch_list(content, detail_json, operation)

            #Construct the map of batches
            batch =
                header_trailer_batch
                |> Map.put("details", batch_detail_list)

            #Create Init and Final batches list
            #Include in the batch json
            case create_init_final_batch_list(content, operation) do
                {:ok, init_final_batch_list} ->
                    batch |> Map.put("balances", init_final_batch_list)
                {:error, _} ->
                    batch
                end
        else
            _err -> {:error, err :template_not_found}
        end
    end

    defp create_init_final_batch_list(content, operation) do
        with {:ok, init_batch_json} <- load_json_template(operation, "init_batch"),
             {:ok, final_batch_json} <- load_json_template(operation, "final_batch")
        do
            #Create Init batch and Final Batch json map
            init_batch_list =
                content
                |> extract_fieldset_list_from_batch(:init_batch)
                |> Enum.map(fn init_batch ->
                    create_register(init_batch.fieldset |> serialize_fieldset_map(),
                                           init_batch_json, :init_final_batch)
                end)

            final_batch_list =
                content
                |> extract_fieldset_list_from_batch(:final_batch)
                |> Enum.map(fn final_batch ->
                    create_register(final_batch.fieldset |> serialize_fieldset_map(),
                                           final_batch_json, :init_final_batch)
                end)

            init_final_batch =
                Enum.concat(init_batch_list, final_batch_list)
                |> Enum.group_by(fn register -> register["balance_type"] end)

            {:ok, init_final_batch}
        else
            _err -> {:error, err :template_not_found}
        end
    end

    defp create_detail_batch_list(content, detail_json, operation) do
        _batch_detail_list =
            content
            |> extract_fieldset_list_from_batch(:detail)
            |> chunk_detail_batch_list(first_detail(operation))
            |> List.flatten
            |> Enum.map(fn detail ->
                create_register(detail.fieldset |> serialize_fieldset_map(),
                                       detail_json, :detail)
            end)
    end

    defp chunk_detail_batch_list(detail_batch_list, first_detail) do
        chunk_fun =
            fn element, acc ->
                if element.fieldset
                  |> serialize_fieldset_map
                  |> Map.get("batches_details_segment") == first_detail
                  and Enum.any?(acc, fn x -> x.fieldset |> serialize_fieldset_map
                        |> Map.get("batches_details__segment") == first_detail end)
                do
                    {:cont, Enum.reverse(acc), [element]}
                else
                    {:cont, [element | acc]}
                end
            end
        after_fun = fn
            [] -> {:cont, []}
            acc -> {:cont, Enum.reverse(acc), []}
        end

        detail_batch_list
        |> Enum.chunk_while([], chunk_fun, after_fun)
    end

    # Create a register json according to the template
    defp create_register(register_fieldset, template_json, :detail) do
        template_json
        |> Enum.map(fn {template_key, _template_value} ->
            match_template_with_fieldset(template_key, "batches_details_", register_fieldset)
        end)
        |> serialize_fieldset_map()
    end
    defp create_register(register_fieldset, template_json, :init_final_batch) do
        template_json
        |> Enum.map(fn {template_key, _template_value} ->
            match_template_with_fieldset(template_key, "batches_balances_", register_fieldset)
        end)
        |> serialize_fieldset_map()
    end

    defp extract_fieldset_from_batch(batch_content, type) do
        case batch_content |> Enum.find(fn register -> register.type == type end) do
            nil -> %{}
            value ->
                value
                |> Map.get(:fieldset)
                |> serialize_fieldset_map
        end
    end

    defp extract_fieldset_list_from_batch(batch_content, type) do
        batch_content
        |> Enum.filter(fn register -> register.type == type end)
    end

    defp first_detail(operation) do
        case operation do
            "payment_on_checking" -> "A"
            "statement_for_cash_management" -> "F"
            _ -> nil
        end
    end

    #Fetch a value from the fieldset_map that its key matches
    #with the result of concatenation between template_preffix and template_key
    defp match_template_with_fieldset(template_key, template_preffix, fieldset_map) do
        case Map.fetch(fieldset_map, template_preffix <> template_key) do
            {:ok, value} -> {template_key, value}
            _ -> {template_key, nil}
        end
    end

    #Transform a two element tuple list into a map
    defp serialize_fieldset_map(fieldset) do
        fieldset |> Map.new(fn {a,b} -> {a,b} end)
    end

    #Load json template
    defp load_json_template(folder, name) do
        path = build_template_path(folder, name)

        with {:ok, file} <- File.read(path),
             {:ok, json_map} <- Poison.decode(file)
        do
            {:ok, json_map}
        else
            err -> err
        end
    end

    defp build_template_path(folder, name) do
      template_path =
          @template_path
          |> Path.join("#{folder}")
          |> Path.join("#{name}.json")

      _path =
            :code.priv_dir(:ex_cnab)
            |> Path.join(template_path)
            |> Path.absname
            |> Path.expand()
    end
end
