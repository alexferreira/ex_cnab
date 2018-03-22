defmodule ExCnab.Test.CNAB.EncoderTest do
    use ExCnab.Test.Support

    import ExCnab.Test.Support.Fixtures

    setup :payment_json

    test "Do: Encode CNAB", context do
        assert {:ok, _cnab} = CNAB.encode(context.payment_json)
    end

    test "Do not: Encode CNAB. Why? invalid json" do
        assert {:error, _} = CNAB.encode(%{})
    end

    test "Do not: Encode CNAB. Why? invalid operation", context do
        json = Map.put(context.payment_json, "operation", "invalid_operation")
        assert {:error, _} = CNAB.encode(json)
    end

    test "Do: prepare json", %{payment_json: json} do
        assert map = CNAB.prepare_json(json)
        assert Map.get(map, "company_address_state") == json |> Map.get("company") |> Map.get("address") |> Map.get("state")
        assert Enum.all?(map, fn {_k, v} -> not is_map v end)
    end

    test "Do not: prepare json Why?  Json is empty" do
        assert CNAB.prepare_json(%{}) == %{}
    end
end
