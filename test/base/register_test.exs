defmodule ExCnab.Test.Base.RegisterTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support.Fixtures

  setup :payment_json

  test "New register", context do
    config = Application.get_env(:ex_cnab, :structure)

    assert {:ok, _} =
             context.payment_json
             |> Register.new(config, register_type())
  end

  defp register_type() do
    Faker.Helper.pick([
      :detail,
      :final_batch,
      :header_batch,
      :header_file,
      :init_batch,
      :trailer_batch,
      :trailer_file
    ])
  end
end
