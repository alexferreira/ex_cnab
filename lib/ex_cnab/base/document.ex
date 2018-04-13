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

    def new_header_file(template, json) when is_map(json) do
        case not(Enum.empty?(template)) and not(Enum.empty?(json)) do
            true ->
                {:ok, %__MODULE__{
                type: :header_file,
                content: load_content(template, json)}}

            false -> {:error, err :empty_json}
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
        total_batches = Enum.count(json["batches"])
        context = %{total_batches: total_batches, total_registers: 0}
        batch_maker(json, template, total_batches - 1, context)
    end

    defp batch_maker(json, template, counter, context, acc \\ []) do
        mod_json = Access.get_and_update(json, "batches", fn n -> {n, Enum.at(n, counter)} end)
                        |> elem(1)
                        |> ExCnab.CNAB.Encoder.prepare_json()

        payment_counter = Enum.count(mod_json["batches_payments"])
        context = Map.merge(context, %{number_of_payments: payment_counter,
                    batch_number: counter + 1})

        {:ok, details, context} = detail_maker(mod_json, template, payment_counter - 1, context)

        {:ok, header_batch} = ExCnab.Base.Register.new(template, mod_json, :header_batch, 1, context)
        {:ok, trailer_batch} = ExCnab.Base.Register.new(template, mod_json, :trail_batch, 5, context)

        acc = [header_batch] ++ details ++ [trailer_batch] ++ acc
        counter(counter, json, template, acc, :batch, context)
    end

    defp detail_maker(json, template, counter, context,  acc \\ []) do
        mod_json = Access.get_and_update(json, "batches_payments", fn n -> {n, Enum.at(n, counter)} end)
                   |> elem(1)
                   |> ExCnab.CNAB.Encoder.prepare_json()

        context = Map.merge(%{context | total_registers: context.total_registers + 1},
                            %{payment_number: counter + 1})

        {:ok, register} = ExCnab.Base.Register.new(template, mod_json, :detail, 3, context)
        acc = Enum.concat(register, acc)
        counter(counter, json, template, acc, :detail, context)
    end

    def counter(0, _json, _template, acc, _fun, context), do: {:ok, acc, context}
    def counter(counter, json, template, acc, :detail, context), do: detail_maker(json, template, counter - 1, context, acc)
    def counter(counter, json, template, acc, :batch, context), do: batch_maker(json, template, counter - 1, context, acc)

    defp trailer_file(template, json, context), do: ExCnab.Base.Register.new(template, json, :trailer_file, 9, context)
end
