defmodule ExCnab.Test.CNAB.EncoderTest do
    use ExCnab.Test.Support

    import ExCnab.Test.Support.Fixtures

    setup :payment_several

    test "Do: Encode CNAB", context do
        assert {:ok, _cnab} = CNAB.Encoder.encode(context.payment_several)
    end

    test "Do not: Encode CNAB. Why? invalid json" do
        assert {:error, _} = CNAB.Encoder.encode(%{})
    end

    test "Do not: Encode CNAB. Why? invalid operation", context do
        json = Map.put(context.payment_several, "operation", "invalid_operation")
        assert {:error, _} = CNAB.Encoder.encode(json)
    end

    test "Do: prepare json", %{payment_several: json} do
        assert map = CNAB.Encoder.prepare_json(json)
        assert Map.get(map, "company_address_state") == json |> Map.get("company") |> Map.get("address") |> Map.get("state")
        assert Enum.all?(map, fn {_k, v} -> not is_map v end)
    end

    test "Do not: prepare json Why?  Json is empty" do
        assert CNAB.Encoder.prepare_json(%{}) == %{}
    end
end
