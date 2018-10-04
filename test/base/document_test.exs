defmodule ExCnab.Test.Base.DocumentTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_several

  test "Do: create new document", %{payment_several: json} do
    assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

    config = ExCnab.Table.structure()

    json = ExCnab.CNAB.Encoder.prepare_json(json)
    assert {:ok, _doc} = Document.new(config, template, json)
  end

  test "Do not: create new document", %{payment_several: json} do
    assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

    template = template |> Map.drop(["header_file"])

    config = ExCnab.Table.structure()

    json = ExCnab.CNAB.Encoder.prepare_json(json)
    assert {:error, _doc} = Document.new(config, template, json)
  end

  test "Do not: get new document. Why? Json or template missing", %{payment_several: json} do
    config = ExCnab.Table.structure()
    assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

    assert {:error, _} = Document.new(config, template, %{})
    assert {:error, _} = Document.new(config, %{}, json |> ExCnab.CNAB.Encoder.prepare_json)
    assert {:error, _} = Document.new(config, %{}, %{})
  end

  test "Do not: get new document. Why? Missing keys in json", %{payment_several: json} do
    config = ExCnab.Table.structure()
    assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))
    json = json |> ExCnab.CNAB.Encoder.prepare_json

    Map.keys(json)
    |> List.delete("operation")
    |> Enum.map(fn n ->
        json = Map.drop(json, [n])
        assert {:error, _message} = Document.new(config, template, json)
    end)
  end

  test "Do not: get new document. Why? Missing keys in template", %{payment_several: json} do
    config = ExCnab.Table.structure()
    assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))
    json = json |> ExCnab.CNAB.Encoder.prepare_json

    Map.keys(template)
    |> List.delete("batch_id")
    |> List.delete("operation_id")
    |> Enum.map(fn n ->
        template = Map.drop(template, [n])
        assert {:error, _message} = Document.new(config, template, json)
    end)
  end
end
