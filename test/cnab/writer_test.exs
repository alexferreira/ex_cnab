defmodule ExCnab.Test.CNAB.WriterTest do

    use ExCnab.Test.Support

    import ExCnab.Test.Support.Fixtures

    setup :payment_json

    test "Do: write a cnab file", context do
        path = :code.priv_dir(:ex_cnab) |> Path.join("cnabs/cnab")
        assert {:ok, _} = CNAB.Writer.write_cnab(context.payment_json)
        assert File.exists?(path)
        assert {:ok, string} = File.read(path)
        assert string != ""
        assert String.length(string) == 482
    end

end
