defmodule ExCnab.Logger do
    defmacro __using__(_opts) do
        quote do
            require Logger

            defp info(message) do
                Logger.info("[#{Module.split(__MODULE__) |> List.last}] " <> message)
            end
        end
    end
end
