defmodule ExCnab.Test.CNAB.DecoderTest do
    use ExCnab.Test.Support

    import ExCnab.Test.Support.Factory, only: [cnab_document: 0]

    test "Do: Decode CNAB" do
        assert _cnab = CNAB.Decoder.decode(cnab_document())
    end
end
