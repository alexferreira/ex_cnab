defmodule ExCnab.Test.CNAB.WriterTest do

    use ExCnab.Test.Support

    import ExCnab.Test.Support.Fixtures

    setup :payment_json

    test "Do: write a cnab file", context do
        path = Application.get_env(:ex_cnab, :cnab_writing_path) |> Kernel.<>("cnab") |> Path.expand
        assert {:ok, _} = CNAB.Writer.write_cnab(context.payment_json, "cnab")
        assert {:ok, string} = File.read(path)
        assert string != ""
        assert n_lines = String.split(string, "\n") |> Enum.filter(fn n -> n != "" end) |> Enum.count
        assert String.length(string) == n_lines * 241
    end

    test "Do not: write a cnab file, Why? Json input empty" do
        assert {:error, _} = CNAB.Writer.write_cnab(%{})
    end

    test "Do: write a cnab file ", context do
        assert {:ok, _} = CNAB.Writer.write_cnab(context.payment_json)
    end

    test "Do not: write a cnab file, Why? Json input not valid", context do
        context.payment_json
        |> Map.keys()
        |> Enum.map(fn n ->
            json = Map.drop(context.payment_json, [n])
            assert {:error, _} = CNAB.Writer.write_cnab(json)
           end)
    end

end
