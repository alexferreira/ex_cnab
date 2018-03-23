defmodule ExCnab.Test.Base.RegisterTest do
    use ExCnab.Test.Support

    import ExCnab.Test.Support.Fixtures

    setup :payment_json

    test "Do: New register", %{payment_json: json} do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

        register_type = register_type()
        batch = json["batches"] |> List.first
        batch = %{batch | "payments" => batch["payments"] |> List.first}
        json = %{json | "batches" => batch} |> CNAB.prepare_json()

        assert {:ok, _} =
            template
            |> Register.new(json, register_type |> elem(0),
            register_type |> elem(1))
    end

    test "Do: New register with header file inside",  %{payment_json: json} do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(json, "operation"))

        batch = json["batches"] |> List.first
        batch = %{batch | "payments" => batch["payments"] |> List.first}
        json = %{json | "batches" => batch} |> CNAB.prepare_json()

        {:ok, header_file} = CNAB.Template.load_json_config_by_regex("{{header_file}}")
        {:ok, trailer_file} = CNAB.Template.load_json_config_by_regex("{{trailer_file}}")

        template = %{template | "header_file" => header_file}
        template = %{template | "trailer_file" => trailer_file}

        assert {:ok, _} = Register.new(template, json, :header_file , 0)
        assert {:ok, _} = Register.new(template, json, :trailer_file , 9)
    end

    test "Do: New  register detail", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_json, "operation"))
        json = context.payment_json |> ExCnab.CNAB.prepare_json()
        batch = json["batches"] |> List.first
        batch = %{batch | "payments" => batch["payments"] |> List.first}
        json = %{json | "batches" => batch} |> CNAB.prepare_json()
        assert {:ok, _register} = template |> Register.new(json, :detail, 3)
    end

    test "Do not: New register init_batch, Why? Not enough missing fields", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_json, "operation"))

        temp = %{"init_batch" => template["header_batch"]}
        assert {:error, _register} = temp |> Register.new(context.payment_json, :init_batch, 2)
    end

    test "Do not: New register final_batch, Why? Not enough missing fields", context do
        assert {:ok, template} = ExCnab.CNAB.Template.load_json_config(Map.get(context.payment_json, "operation"))

        temp = %{"final_batch" => template["trailer_batch"]}
        assert {:error, _register} = temp |> Register.new(context.payment_json, :final_batch, 4)
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
