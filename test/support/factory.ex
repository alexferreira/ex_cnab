defmodule ExCnab.Test.Support.Factory do
    alias FakerElixir, as: Faker
    def field(_context) do
        field = %ExCnab.Field{
            id: Faker.Name.name(),
            length: Faker.Number.between(1..15),
            format: Faker.Helper.pick(["int", "string"]),
            default: Faker.Helper.pick([" ", "0"])
        }
        [field: field]
    end
end
