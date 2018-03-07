defmodule ExCnab.Test.CNAB.EncoderTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_json

  test "Do: Encode CNAB", context do
    assert {:ok, cnab} = CNAB.Encoder.encode(context.payment_json)
    IO.inspect cnab
  end

  test "Do not: Encode CNAB. Why? invalid json" do
    assert {:error, _} = CNAB.Encoder.encode(%{})
  end

  test "Do not: Encode CNAB. Why? invalid operation", context do
    json = Map.put(context.payment_json, "operation", "invalid_operation")
    assert {:error, _} = CNAB.Encoder.encode(json)
  end
end
