defmodule ExCnab.Test.Support.Factory do
  alias FakerElixir, as: Faker

  def field(_context) do
    field = %ExCnab.Base.Field{
      id: Faker.Name.name(),
      length: Faker.Number.between(1..15),
      format: Faker.Helper.pick(["int", "string"]),
      default: Faker.Helper.pick([" ", "0"])
    }

    [field: field]
  end

  def cnab_document() do
      cnab_path = :code.priv_dir(:ex_cnab) |> Path.join("cnabs/cnab_payment_several")
      {:ok, document} = File.read(cnab_path)
      document
  end

end
