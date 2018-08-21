defmodule ExCnab.Base.Document do
  @moduledoc false
  import ExCnab.Error

    defstruct type: nil,
                content: nil

    def new(_config, template, json) when is_map(json) do
        with true <- not(Enum.empty?(template)) and not(Enum.empty?(json)),
             {:ok, content} <- load_content(template, json)
        do
            {:ok, %__MODULE__{
            type: json["operation"],
            content: content}}
        else
            false -> {:error, err :empty_json}
            {:error, message} -> {:error, message}
        end
    end

    def load_content(template, json) do
        with {:ok, header_file} <- header_file(template, json),
             {:ok, batches, context} <- batches(template, json),
             {:ok, trailer} <- trailer_file(template, json, context)
        do
            {:ok, [header_file] ++ batches ++ [trailer]}
        else
            err -> err
        end
    end

    defp header_file(template, json), do: ExCnab.Base.Register.new(template, json, :header_file, 0)

    defp batches(template, json) do
        with {:ok, context} <- validation(json, :batches),
             {:ok, batches, context} <- batch_maker(json, template, context.total_batches - 1, context)
        do
             {:ok, batches, context}
        else
            err -> err
        end
    end


    defp batch_maker(json, template, counter, context, acc \\ []) do
        with {:ok, mod_json, context} <- validation(json, context, counter, :batch_maker),
             {:ok, details, context} <- detail_maker(mod_json, template, context.number_of_details - 1, context),
             {:ok, header_batch} <- ExCnab.Base.Register.new(template, mod_json, :header_batch, 1, context),
             {:ok, trailer_batch} <- ExCnab.Base.Register.new(template, mod_json, :trailer_batch, 5, context),
             {:ok, init_batch, _} <- init_final_batch_maker(mod_json, template, context.total_balances - 1, :init_batch, 2, context),
             {:ok, final_batch, _} <- init_final_batch_maker(mod_json, template, context.total_balances - 1, :final_batch, 4, context)
        do
            acc = [header_batch] ++ init_batch ++ details ++ final_batch ++ [trailer_batch] ++ acc
            counter(counter, json, template, acc, :batch, context)
        else
            {:error, message} -> {:error, message}
        end
    end

    defp detail_maker(json, template, counter, context,  acc \\ []) do
        context = Map.merge(%{context | total_details: context.total_details + 1}, %{detail_number: counter + 1})

        with {:ok, mod_json} <- modify_json(json, counter, "batches_details"),
             {:ok, register} <- ExCnab.Base.Register.new(template, mod_json, :detail, 3, context)
        do
            acc = Enum.concat(register, acc)
            counter(counter, json, template, acc, :detail, context)
        else
            err -> err
        end
    end

    defp init_final_batch_maker(json, template, counter, register_name, register_code, context, acc \\ []) do
        with true <- json["operation"] == "statement_for_cash_management",
             {:ok, mod_json} <- modify_json(json, counter, "batches_balances"),
             {:ok, register} <- ExCnab.Base.Register.new(template, mod_json, register_name, register_code, context)
        do
            acc = Enum.concat([register], acc)
            counter(counter, json, template, acc, register_name, register_code, context)
        else
            false -> {:ok, [], context}
            err -> err
        end
    end

    def counter(0, _json, _template, acc, _fun, context), do: {:ok, acc, context}
    def counter(counter, json, template, acc, :detail, context), do: detail_maker(json, template, counter - 1, context, acc)
    def counter(counter, json, template, acc, :batch, context), do: batch_maker(json, template, counter - 1, context, acc)

    def counter(0, _json, _template, acc, _register_name, _register_code, context), do: {:ok, acc, context}
    def counter(counter, json, template, acc, register_name, register_code, context), do: init_final_batch_maker(json, template, counter - 1, register_name, register_code, context, acc)

    defp modify_json(json, counter, key) do
        {:ok,
            _mod_json =
                Access.get_and_update(json, key, fn n -> {n, Enum.at(n, counter)} end)
                |> elem(1)
                |> ExCnab.CNAB.Encoder.prepare_json()}
    end

    defp check_and_count_key(json, key) do
        cond do
            Map.fetch(json, key) == :error and
                json["operation"] != "statement_for_cash_management" and
                key == "batches_balances" ->
                    1

            key == "batches_balances" ->
                Map.fetch(json, key)
                |> elem(1)
                |> Enum.count()

            Map.fetch(json, key) == :error ->
                {:error, err(:not_found, key)}

            true ->
                {:ok,
                    Map.fetch(json, key)
                    |> elem(1)
                    |> Enum.count()}
        end
    end

    defp validation(json, atom)
    defp validation(json, :batches) do
        case check_and_count_key(json, "batches") do
            {:ok, batches} ->
                {:ok, %{total_batches: batches,
                        total_details: 0}}

            {:error, message} -> {:error, message}
        end
    end


    defp validation(json, context, counter, :batch_maker) do
        with {:ok, mod_json} <- modify_json(json, counter, "batches"),
             {:ok, details} <- check_and_count_key(mod_json, "batches_details")
        do
            {:ok,
                mod_json,
                    Map.merge(context,
                     %{number_of_details: details,
                       number_of_registers_in_batch: details + 2,
                       batch_number: counter + 1,
                       total_balances: check_and_count_key(mod_json, "batches_balances")})}
        else
            err -> err
        end
    end

    defp trailer_file(template, json, context) do
        total_register_map = %{total_registers: (context.total_batches*2) + context.total_details + 2}
        context = Map.merge(context, total_register_map)
        ExCnab.Base.Register.new(template, json, :trailer_file, 9, context)
    end
end
