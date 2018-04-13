defmodule ExCnab.Test.CNAB.ReaderTest do

    use ExCnab.Test.Support

    test "Do: read a cnab file" do
        cnab_path = :code.priv_dir(:ex_cnab) |> Path.join("cnabs/cnab")
        assert {:ok, _data} = CNAB.Reader.read_cnab(cnab_path)
    end
end
