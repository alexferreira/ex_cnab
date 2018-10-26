defmodule ExCnab.Test.CNAB.TemplateTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_several

  test "Open template", %{payment_several: json} do
    assert {:ok, _} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))
  end

  test "Open template by regex" do
    assert {:ok, _} = ExCnab.CNAB.Template.load_json_config_by_regex("{{header_file}}")
  end

  test "Don't open template" do
    assert {:error, _} = ExCnab.CNAB.Template.load_json_config(Faker.Name.first_name())
  end
end
