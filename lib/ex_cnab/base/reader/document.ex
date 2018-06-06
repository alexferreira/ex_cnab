defmodule ExCnab.Base.Reader.Document do
    @moduledoc false

    @header_file_batch_number "0000"
    @trailer_file_batch_number "9999"

    defstruct type: nil,
              content: %{
                  header_file: nil,
                  batches: [],
                  trailer_file: nil
              }

    def new(cnab) do
        type = :retorno

        header_file =
            cnab
            |> Enum.find(fn {k, _v} -> k == @header_file_batch_number end)
            |> Tuple.to_list
            |> Enum.at(1)


        trailer_file =
            cnab
            |> Enum.find(fn {k, _v} -> k == @trailer_file_batch_number end)
            |> Tuple.to_list
            |> Enum.at(1)

        batches =
            cnab
            |> Enum.reject(fn {k, _v} -> k == @header_file_batch_number end)
            |> Enum.reject(fn {k, _v} -> k == @trailer_file_batch_number end)
            |> Enum.map(fn {_k, v} -> v end)

        %__MODULE__{
            type: type,
            content: %{
                header_file: header_file,
                batches: batches,
                trailer_file: trailer_file
            }
        }
    end
end
