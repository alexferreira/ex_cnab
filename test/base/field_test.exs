defmodule ExCnab.Test.Base.FieldTest do
    use ExCnab.Test.Support

    test "Do: create nil field" do
        field = %Field{}

        assert is_nil(field.id)
        assert is_nil(field.length)
        assert is_nil(field.format)
        assert is_nil(field.default)
    end

    test "Do not: create field Why? Invalid formart" do
        template = %{
            "id" => Faker.Name.name(),
            "length" => Faker.Number.between(8..18),
            "format" => "anything",
            "default" => false
        }
        assert {:error, _} = Field.from_template(template, "something", %{})
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

    test "Do: create date field" do
        {:ok, date} = Faker.Date.birthday |> NaiveDateTime.from_iso8601()
        date = date |> NaiveDateTime.to_date() |> Date.to_string()

        field = %Field{
            id: Faker.Name.name(),
            length: Faker.Number.between(8..18),
            format: "date",
            default: false}

        assert {:ok, _field} = Field.enforce_format(field, date)

        date_1 = String.replace(date,"/","-")

        field_1 = %Field{
                id: Faker.Name.name(),
                length: Faker.Number.between(8..18),
                format: "date",
                default: false}

        assert {:ok, _field} = Field.enforce_format(field_1, date_1)
    end

    test "Do: enforce field format" do
        {:ok, date} = Faker.Date.birthday |> NaiveDateTime.from_iso8601()
        date = date |> NaiveDateTime.to_date() |> Date.to_string()
        int = Faker.Number.between(100..1500)
        dec = FakerElixir.Helper.numerify("####,##")
        str = Faker.Name.name
        tp = [Faker.Number.between(5..15), Faker.Number.between(2..5)]
        len = Faker.Number.between(5..20)

        Enum.map([{"date", date, len}, {"int", "#{int}", len}, {"decimal", "#{dec}", tp}, {"string", str, len}],
        fn {f, v, l} ->
            field = %Field{
                id: Faker.Name.name(),
                length: l,
                format: f,
                default: Faker.Helper.pick([" ", "0"])
                }
            assert {:ok, _field} = Field.enforce_format(field, v)
        end)
    end

    test "Do: get a content from context" do
        number = Faker.Number.digit() |> Integer.to_string()
        length = Faker.Number.between(1..9)
        template = %{
            "id" => Faker.Name.name(),
            "length" => length,
            "format" => "int",
            "default" => "@any_counter"
        }
        assert {:ok, content} = Field.from_template(template, nil, %{any_counter: number}) |> Map.fetch(:content)
        assert String.length(content) == length
        assert String.to_integer(content) |> Integer.to_string() == number
    end

    test "Do not: get a content from context Why? Content not found" do
        template = %{
            "id" => Faker.Name.name(),
            "length" => Faker.Number.between(1..9),
            "format" => "int",
            "default" => "@any_counter"
        }
        assert {:error, _content} = Field.from_template(template, nil, %{})
    end
end
