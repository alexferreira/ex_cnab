defmodule ExCnab.Test.Base.DocumentTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_json

  test "Do: create new document", %{payment_json: json} do
    assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

    config = Application.get_env(:ex_cnab, :structure)

    json = ExCnab.CNAB.Encoder.prepare_json(json)
    assert {:ok, _doc} = Document.new(config, template, json)
  end

  test "Do not: create new document", %{payment_json: json} do
    assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

    template = template |> Map.drop(["header_file"])

    config = Application.get_env(:ex_cnab, :structure)

    json = ExCnab.CNAB.Encoder.prepare_json(json)
    assert {:error, _doc} = Document.new(config, template, json)
  end

  test "Do not: get new document" do
    config = Application.get_env(:ex_cnab, :structure)

    assert {:error, _} = Document.new(config, %{}, %{})
  end
end
