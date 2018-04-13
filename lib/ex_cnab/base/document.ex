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

        with {:ok, mod_json, context} <- validation(json, context, counter, :batche_maker),
             {:ok, details, context} <- detail_maker(mod_json, template, context.number_of_payments - 1, context),
             {:ok, header_batch} <- ExCnab.Base.Register.new(template, mod_json, :header_batch, 1, context),
             {:ok, trailer_batch} <- ExCnab.Base.Register.new(template, mod_json, :trail_batch, 5, context)
        do
            acc = [header_batch] ++ details ++ [trailer_batch] ++ acc
            counter(counter, json, template, acc, :batch, context)
        else
            err -> err
        end
    end

    defp detail_maker(json, template, counter, context,  acc \\ []) do
        context = Map.merge(%{context | total_registers: context.total_registers + 1}, %{payment_number: counter + 1})

        with {:ok, mod_json} <- modify_json(json, counter, "batches_payments"),
             {:ok, register} <- ExCnab.Base.Register.new(template, mod_json, :detail, 3, context)
        do
            acc = Enum.concat(register, acc)
            counter(counter, json, template, acc, :detail, context)
        else
            err -> err
        end
    end

    def counter(0, _json, _template, acc, _fun, context), do: {:ok, acc, context}
    def counter(counter, json, template, acc, :detail, context), do: detail_maker(json, template, counter - 1, context, acc)
    def counter(counter, json, template, acc, :batch, context), do: batch_maker(json, template, counter - 1, context, acc)

    defp modify_json(json, counter, key) do
        {:ok,
            mod_json =
                Access.get_and_update(json, key, fn n -> {n, Enum.at(n, counter)} end)
                |> elem(1)
                |> ExCnab.CNAB.Encoder.prepare_json()}
    end

    defp check_key(json, key) do
        case Map.fetch(json, key) do
            {:ok, content} -> {:ok, content}
            :error -> {:error, err(:not_found, key)}
        end
    end

    defp validation(json, atom)
    defp validation(json, :batches) do
        case check_key(json, "batches") do
            {:ok, batches} ->
                {:ok, %{total_batches: Enum.count(batches),
                        total_registers: 0}}

            {:error, message} -> {:error, message}
        end
    end


    defp validation(json, context, counter, :batche_maker) do
        with {:ok, mod_json} <- modify_json(json, counter, "batches"),
             {:ok, payments} <- check_key(mod_json, "batches_payments")
        do
            {:ok,
                mod_json,
                    Map.merge(context,
                     %{number_of_payments: Enum.count(payments),
                       batch_number: counter + 1})}
        else
            err -> err
        end
    end

    defp trailer_file(template, json, context), do: ExCnab.Base.Register.new(template, json, :trailer_file, 9, context)
end
