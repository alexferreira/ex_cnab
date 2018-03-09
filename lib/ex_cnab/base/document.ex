defmodule ExCnab.Base.Document do
  @moduledoc false
  import ExCnab.Error

    defstruct type: nil,
                content: nil

    def new(config, template, json) when is_map(json) do
        case not(Enum.empty?(template)) and not(Enum.empty?(json)) do
            true ->
                {:ok, %__MODULE__{
                type: json["operation"],
                content: load_content(template, json)}}

            false -> {:error, err :empty_json}
        end
    end

    def load_content(template, json) do
      [header_file(template, json)] ++ batches(template, json) ++ [trailer_file(template, json)]
    end

    defp header_file(template, json) do
      {:ok, register} = ExCnab.Base.Register.new(template, json, :header_file, 0)
        register
    end

    defp batches(template, json) do
        json = json |> batches_handle()
        batches_count = Enum.count(json["batches"]) -1
        batch_maker(json, template, batches_count)
    end

  defp batch_maker(json, template, counter, acc \\ []) do
        {_, mod_json} = Access.get_and_update(json, "batches", fn n -> {n, Enum.at(n, counter)} end)
        mod_json = ExCnab.CNAB.prepare_json(mod_json)
        payment_counter = Enum.count(mod_json["batches_payments"]) -1
        details = detail_maker(mod_json, template, payment_counter)

        {:ok, header_batch} = ExCnab.Base.Register.new(template, mod_json, :header_batch, 1)
        {:ok, trailer_batch} = ExCnab.Base.Register.new(template, mod_json, :trail_batch, 5)

        acc = acc ++ [header_batch] ++ details ++ [trailer_batch]
        counter(counter, json, template, acc, :batch)
    end

    defp detail_maker(json, template, counter, acc \\ []) do
        {_, mod_json} = Access.get_and_update(json, "batches_payments", fn n -> {n, Enum.at(n, counter)} end)
        mod_json = mod_json |> ExCnab.CNAB.prepare_json()
        {:ok, register} = ExCnab.Base.Register.new(template, mod_json, :detail, 3)
        acc = List.insert_at(acc, 0, register)
        counter(counter, json, template, acc, :detail)
    end

    def counter(0, _json, _template, acc, _fun), do: acc
    def counter(counter, json, template, acc, :detail), do: detail_maker(json, template, counter - 1, acc)
    def counter(counter, json, template, acc, :batch), do: batch_maker(json, template, counter - 1, acc)

    defp batches_handle(json) do
        Access.get_and_update(json, "batches", fn n -> {n,
        Enum.map(n, fn i -> ExCnab.CNAB.prepare_json(i |> payment_handle() |> elem(1)) end)} end)
        |> elem(1)
    end

    defp payment_handle(batch) do
        Access.get_and_update(batch, "payments", fn n -> {n,
        Enum.map(n, fn i -> ExCnab.CNAB.prepare_json(i) end)} end)
    end

    defp trailer_file(template, json) do
        {:ok, register} = ExCnab.Base.Register.new(template, json, :trailer_file, 9)
        register
    end

    defp fill_document(operation, header) do
        document = %__MODULE__{
          type: operation,
          content: %{
          header: header
          }
        }
        {:ok, document}
    end

    defp load_type(json) do
        case Map.fetch(json, "operation") do
            :error ->
                {:error, err(:operation_not_found)}

            operation ->
                operation
        end
    end
end
