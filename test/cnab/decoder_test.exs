defmodule ExCnab.Test.CNAB.DecoderTest do
    use ExCnab.Test.Support

    import ExCnab.Test.Support.Factory, only: [cnab: 1]

    @payment_several :cnab_payment_several
    @ted_payment :cnab_ted_payment

    [@payment_several, @ted_payment]
    |> Enum.each(fn payment_type ->
        test "Do: Decode CNAB #{payment_type}" do
            assert _cnab = CNAB.Decoder.decode(cnab(unquote(payment_type)))
        end
    end)
end
