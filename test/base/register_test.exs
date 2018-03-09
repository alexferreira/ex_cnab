defmodule ExCnab.Test.Base.RegisterTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_json

  test "New register", context do
    assert {:ok, template} = ExCnab.CNAB.load_json_config(Map.get(context.payment_json, "operation"))
    register_type = register_type()
    assert {:ok, _} =
             template
             |> Register.new(context.payment_json, register_type |> elem(0) ,
                                                   register_type |> elem(1))

  end

  test "New  register detail", context do
    assert {:ok, template} = ExCnab.CNAB.load_json_config(Map.get(context.payment_json, "operation"))
    json = context.payment_json |> ExCnab.CNAB.prepare_json()
    assert {:ok, register} = template |> Register.new(json, :detail, 3)
  end

  defp register_type() do
    Faker.Helper.pick([
      header_file: 0,
      header_batch: 1,
      init_batch: 2,
      detail: 3,
      final_batch: 4,
      trailer_batch: 5,
      trailer_file: 9
    ])
  end
end
