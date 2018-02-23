defmodule ExCnab.Test.Support do
    @moduledoc false

    defmacro __using__(_) do
        quote do
            use ExUnit.Case

            alias FakerElixir, as: Faker
            alias ExCnab.{Field, Fieldset}
        end
    end

    defmacro private_setup(context, func, args \\ []) when is_atom(func) do
        quote do
            ctx = unquote(context)
            ctx |> unquote(func)(unquote_splicing(args)) |> Enum.into(ctx)
        end
    end
end
