defmodule ExCnab.CNAB.Writer do
    @moduledoc false

    import ExCnab.Error

    alias ExCnab.CNAB

    def write_cnab(json) do
        {:ok, document} = CNAB.Encoder.encode(json)
        cnab_path = :code.priv_dir(:ex_cnab) |> Path.join("cnabs/cnab")
        Enum.filter(document.content, fn(n)-> is_nil(n) == false end)
        |> Enum.map(fn n -> n.fieldset end)
        |> Enum.map(fn n when not(is_nil(n))-> Enum.map(n, fn i -> i.content end)end)
        |> file_writer(cnab_path)
    end

    defp file_writer(list, cnab_path) do
        lines = Enum.reduce(list, "", fn(x, acc) ->
            Enum.join(
            [acc, Enum.join(
            [Enum.join(x), "\n"])]
            ) end)
        File.open(cnab_path, [:write], fn file -> IO.binwrite(file, lines)
        File.close(file) end)
    end
end
