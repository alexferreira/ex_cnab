defmodule ExCnab.Entity.FieldTest do
  use ExCnab.Test.Support

  test "Do: create nil field" do
    field = %Field{}

    assert is_nil(field.id)
    assert is_nil(field.length)
    assert is_nil(field.format)
    assert is_nil(field.default)
  end

  test "Do: create filled field" do
    field = %Field{
        id: Faker.Name.name(),
        length: Faker.Number.between(1..15),
        format: Faker.Helper.pick(["int", "string"]),
        default: Faker.Helper.pick([" ", "0"])
    }

    assert is_binary(field.id)
    assert is_integer(field.length)
    assert is_binary(field.format)
    assert is_binary(field.default)
  end
end
