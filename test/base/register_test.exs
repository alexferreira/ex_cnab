defmodule ExCnab.Test.Base.RegisterTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_json

  test "New register", context do
    config = Application.get_env(:ex_cnab, :structure)
    register_type = register_type()
    assert {:ok, _} =
             context.payment_json
             |> Register.new(config, register_type |> elem(0) , register_type |> elem(1))

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
