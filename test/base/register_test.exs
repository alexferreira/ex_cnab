defmodule ExCnab.Test.Base.RegisterTest do
    use ExCnab.Test.Support

    import ExCnab.Test.Support.Fixtures

    setup :payment_json

    test "Do: New register", %{payment_json: json} do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

        batch = json["batches"] |> List.first
        batch = %{batch | "details" => batch["details"] |> List.first}
        json = %{json | "batches" => batch} |> CNAB.Encoder.prepare_json()

        context = %{number_of_details: Faker.Number.digit(),
                    batch_number: Faker.Number.digit(),
                    detail_number: Faker.Number.digit(),
                    total_batches: Faker.Number.digit(),
                    total_registers: Faker.Number.digit()}

        assert {:ok, _} =
            template
            |> Register.new(json, register_type(), context)
    end

    test "Do: New register without inheritance file inside",  %{payment_json: json} do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

        batch = json["batches"] |> List.first
        batch = %{batch | "details" => batch["details"] |> List.first}
        json = %{json | "batches" => batch} |> CNAB.Encoder.prepare_json()

        {:ok, header_file} = CNAB.Template.load_json_config_by_regex("{{header_file}}")
        {:ok, header_batch} = CNAB.Template.load_json_config_by_regex("{{payment_on_checking_header_batch}}")
        {:ok, _detail_a} = CNAB.Template.load_json_config_by_regex("{{payment_on_checking_detail_a}}")
        {:ok, trailer_batch} = CNAB.Template.load_json_config_by_regex("{{payment_on_checking_trailer_batch}}")
        {:ok, trailer_file} = CNAB.Template.load_json_config_by_regex("{{trailer_file}}")

        template = %{template | "header_file" => header_file}
        template = %{template | "header_batch" => header_batch}
        template = %{template | "trailer_batch" => trailer_batch}
        template = %{template | "trailer_file" => trailer_file}

        context = %{number_of_details: Faker.Number.digit(),
                    batch_number: Faker.Number.digit(),
                    detail_number: Faker.Number.digit(),
                    total_batches: Faker.Number.digit(),
                    total_registers: Faker.Number.digit()}

        assert {:ok, _} = Register.new(template, json, :header_file)
        assert {:ok, _} = Register.new(template, json, :header_batch, context)
        assert {:ok, _} = Register.new(template, json, :detail, context)
        assert {:ok, _} = Register.new(template, json, :trailer_batch, context)
        assert {:ok, _} = Register.new(template, json, :trailer_file, context)
    end

    test "Do: New  register detail", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_json, "operation"))

        json = context.payment_json |> ExCnab.CNAB.Encoder.prepare_json()
        batch = json["batches"] |> List.first
        batch = %{batch | "details" => batch["details"] |> List.first}
        json = %{json | "batches" => batch} |>  ExCnab.CNAB.Encoder.prepare_json()
        in_context = %{number_of_details: Faker.Number.digit(),
                    batch_number: Faker.Number.digit(),
                    detail_number: Faker.Number.digit()
                    }

        assert {:ok, _register} = template |> Register.new(json, :detail, in_context)
    end

    test "Do not: New register init_batch, Why? Not enough missing fields", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_json, "operation"))

        {:ok, header_file} = CNAB.Template.load_json_config_by_regex("{{header_file}}")

        temp = %{"init_batch" => template["header_batch"]}
        temp_1 = %{"init_batch" => header_file}
        assert {:error, _register} = temp |> Register.new(context.payment_json, :init_batch)
        assert {:error, _register} = temp_1 |> Register.new(context.payment_json, :init_batch)
    end

    test "Do not: New register final_batch, Why? Not enough fields", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_json, "operation"))

        {:ok, trailer_file} = CNAB.Template.load_json_config_by_regex("{{trailer_file}}")

        temp = %{"final_batch" => template["header_batch"]}
        temp_1 = %{"final_batch" => trailer_file}

        assert {:error, _register} = temp |> Register.new(context.payment_json, :final_batch)
        assert {:error, _register} = temp_1 |> Register.new(context.payment_json, :final_batch)
    end

    defp register_type() do
      Faker.Helper.pick([
        :header_file,
        :header_batch,
        :detail,
        :trailer_batch,
        :trailer_file
        ])
    end
end
