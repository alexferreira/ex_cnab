defmodule ExCnab.Test.Base.DocumentTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_json

  test "Not new document", %{payment_json: json} do
    assert {:ok, template} = ExCnab.CNAB.load_json_config(Map.get(json, "operation"))

    config = Application.get_env(:ex_cnab, :structure)

    json = CNAB.prepare_json(json)
    assert {:ok, _doc} = Document.new(config, template, json)
  end

  test "Not get new document" do
    config = Application.get_env(:ex_cnab, :structure)

    assert {:error, _} = Document.new(config, %{}, %{})
  end
end
