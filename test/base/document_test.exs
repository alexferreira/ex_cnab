defmodule ExCnab.Test.Base.DocumentTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_json

  test "Not new document", context do
    config = Application.get_env(:ex_cnab, :structure)

    assert {:ok, _} = Document.new(context.payment_json, config)
  end

  test "Not get new document" do
    assert {:error, _} = Document.new(%{}, %{})
  end
end
