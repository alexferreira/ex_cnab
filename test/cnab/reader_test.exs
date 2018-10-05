defmodule ExCnab.Test.CNAB.ReaderTest do

    use ExCnab.Test.Support

    [:ted_payment, :payment_several]
    |> Enum.each(fn payment_type ->
        test "Do: read a cnab #{payment_type} file" do
            cnab_path = :code.priv_dir(:ex_cnab) |> Path.join("cnabs/cnab_#{unquote(payment_type)}")
            assert {:ok, _data} = CNAB.Reader.read_cnab(cnab_path)
        end
    end)

    test "Do: read a statement cnab file" do
        statement_cnab_path = :code.priv_dir(:ex_cnab) |> Path.join("cnabs/statement_cnab")
        assert {:ok, _data} = CNAB.Reader.read_cnab(statement_cnab_path)
    end
end
