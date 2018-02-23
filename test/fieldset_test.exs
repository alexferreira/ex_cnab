defmodule ExCnab.Entity.FieldsetTest do
  use ExCnab.Test.Support

  import ExCnab.Test.Support, only: [private_setup: 2]
  import ExCnab.Test.Support.Factory, only: [field: 1]

  test "Do: create nil fieldset" do
    fieldset = %Fieldset{}

    assert is_nil(fieldset.id)
    assert length(fieldset.fields) == 0
    assert is_nil(fieldset.parent)
  end

  test "Do: create filled fieldset", context do
    fields = create_collection_fields(context, :rand.uniform(10))

    fieldset = %Fieldset{
      id: Faker.Name.name(),
      fields: fields
    }

    assert fieldset.fields |> length() > 0
  end

  def create_collection_fields(context, qty \\ 2) do
    Enum.map(0..qty, fn(_) ->
      create_field(context)
    end)
  end

  defp create_field(context) do
    context |> private_setup(:field) |> Map.fetch!(:field)
  end
end
