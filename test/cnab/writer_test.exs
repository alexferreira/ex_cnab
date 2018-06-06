defmodule ExCnab.Test.CNAB.WriterTest do

    use ExCnab.Test.Support

    import ExCnab.Test.Support.Fixtures

    setup :payment_json
    setup :statement_json

    test "Do: write a payment cnab file", context do
        path = Application.get_env(:ex_cnab, :cnab_writing_path) |> Kernel.<>("cnab") |> Path.expand
        assert {:ok, _} = CNAB.Writer.write_cnab(context.payment_json, "cnab")
        assert {:ok, string} = File.read(path)
        assert string != ""
        assert n_lines = String.split(string, "\n") |> Enum.filter(fn n -> n != "" end) |> Enum.count
        assert String.length(string) == n_lines * 241
    end

    test "Do: write a statement cnab file", context do
        path = Application.get_env(:ex_cnab, :cnab_writing_path) |> Kernel.<>("cnab") |> Path.expand
        assert {:ok, _} = CNAB.Writer.write_cnab(context.statement_json, "statement_cnab")
        assert {:ok, string} = File.read(path)
        assert string != ""
        assert n_lines = String.split(string, "\n") |> Enum.filter(fn n -> n != "" end) |> Enum.count
        assert String.length(string) == n_lines * 241
    end

    test "Do not: write a cnab file, Why? Json input empty" do
        assert {:error, _} = CNAB.Writer.write_cnab(%{})
    end

    test "Do: write a cnab statement file", context do
        assert {:ok, path} = CNAB.Writer.write_cnab(context.statement_json)
        assert :ok = File.rm(path)
    end

    test "Do not: write a cnab statement file Why? path not valid", context do
        env = Application.get_env(:ex_cnab, :cnab_writing_path)
        Application.put_env(:ex_cnab, :cnab_writing_path, env <> "cnab")
        assert {:error, _message} = CNAB.Writer.write_cnab(context.statement_json)
        Application.put_env(:ex_cnab, :cnab_writing_path, env)
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
