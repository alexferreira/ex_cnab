defmodule ExCnab.CNAB.Writer do
    @moduledoc false

    import ExCnab.Error

    alias ExCnab.CNAB

    def write_cnab(json, cnab_name \\ cnab_random_name_gen())
    def write_cnab(json, _cnab_name) when json == %{}, do: {:error, err :empty_json}
    def write_cnab(json, cnab_name) do
        with {:ok, document} <- CNAB.Encoder.encode(json),
             {:ok, cnab_path} <- Application.get_env(:ex_cnab, :cnab_writing_path) |> Path.expand |> build_cnab_path(cnab_name)
        do
            Enum.filter(document.content, fn(n)-> is_nil(n) == false end)
            |> Enum.map(fn n -> n.fieldset end)
            |> Enum.map(fn n when not(is_nil(n))-> Enum.map(n, fn i -> i.content end)end)
            |> file_writer(cnab_path)
        else
            err -> err
        end
    end

    defp cnab_random_name_gen(), do: NaiveDateTime.utc_now() |> NaiveDateTime.to_string() |> Kernel.<>("_cnab")

    defp build_cnab_path(cnab_path, cnab_name) do
        if cnab_path |> File.exists?() do
            {:ok, Path.join([cnab_path, cnab_name])}
        else
            {:error, err :invalid_path}
        end
    end

    defp file_writer(list, cnab_path) do
        list
        |> create_cnab_string()
        |> write_in_file(cnab_path)
    end

    defp create_cnab_string(list) do
        list |> Enum.map_join(&(&1 |> Enum.join() |> Kernel.<>("\n")))
    end

    defp write_in_file(cnab_string, cnab_path) do
        case File.open(cnab_path, [:write]) do
            {:ok, file} ->
                IO.write(file, cnab_string)
                File.close(file)
                {:ok, cnab_path}

            {:error, message} ->
                {:error, err(message, :earlang_file)}
        end
    end
end
