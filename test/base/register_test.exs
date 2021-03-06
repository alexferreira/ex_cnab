defmodule ExCnab.Test.Base.RegisterTest do
    use ExCnab.Test.Support

    import ExCnab.Test.Support.Fixtures

    setup :payment_several

    test "Do: New register", %{payment_several: json} do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

        register_type = register_type()
        batch = json["batches"] |> List.first
        batch = %{batch | "details" => batch["details"] |> List.first}
        json = %{json | "batches" => batch} |> CNAB.Encoder.prepare_json()

        context = %{number_of_details: Faker.Number.digit(),
                    batch_number: Faker.Number.digit(),
                    detail_number: Faker.Number.digit(),
                    total_batches: Faker.Number.digit(),
                    number_of_registers_in_batch: Faker.Number.digit(),
                    total_registers: Faker.Number.digit()}

        assert {:ok, _} =
            template
            |> Register.new(json, register_type |> elem(0),
            register_type |> elem(1), context)
    end

    test "Do: New register without inheritance file inside",  %{payment_several: json} do
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
                    number_of_registers_in_batch: Faker.Number.digit(),
                    total_batches: Faker.Number.digit(),
                    total_registers: Faker.Number.digit()}

        assert {:ok, _} = Register.new(template, json, :header_file , 0)
        assert {:ok, _} = Register.new(template, json, :header_batch , 1, context)
        assert {:ok, _} = Register.new(template, json, :detail , 3, context)
        assert {:ok, _} = Register.new(template, json, :trailer_batch , 5, context)
        assert {:ok, _} = Register.new(template, json, :trailer_file , 9, context)
    end

    test "Do: New  register detail", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_several, "operation"))

        json = context.payment_several |> ExCnab.CNAB.Encoder.prepare_json()
        batch = json["batches"] |> List.first
        batch = %{batch | "details" => batch["details"] |> List.first}
        json = %{json | "batches" => batch} |>  ExCnab.CNAB.Encoder.prepare_json()
        in_context = %{number_of_details: Faker.Number.digit(),
                    batch_number: Faker.Number.digit(),
                    detail_number: Faker.Number.digit()
                    }

        assert {:ok, _register} = template |> Register.new(json, :detail, 3, in_context)
    end

    test "Do not: New register init_batch, Why? Not enough missing fields", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_several, "operation"))

        {:ok, header_file} = CNAB.Template.load_json_config_by_regex("{{header_file}}")

        temp = %{"init_batch" => template["header_batch"]}
        temp_1 = %{"init_batch" => header_file}
        assert {:error, _register} = temp |> Register.new(context.payment_several, :init_batch, 2)
        assert {:error, _register} = temp_1 |> Register.new(context.payment_several, :init_batch, 2)
    end

    test "Do not: New register final_batch, Why? Not enough fields", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_several, "operation"))

        {:ok, trailer_file} = CNAB.Template.load_json_config_by_regex("{{trailer_file}}")

        temp = %{"final_batch" => template["header_batch"]}
        temp_1 = %{"final_batch" => trailer_file}

        assert {:error, _register} = temp |> Register.new(context.payment_several, :final_batch, 4)
        assert {:error, _register} = temp_1 |> Register.new(context.payment_several, :final_batch, 4)
    end

    defp register_type() do
      Faker.Helper.pick([
        header_file: 0,
        header_batch: 1,
        detail: 3,
        trailer_batch: 5,
        trailer_file: 9
        ])
    end
end
