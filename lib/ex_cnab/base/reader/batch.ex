defmodule ExCnab.Base.Reader.Batch do
    @moduledoc false

    defstruct operation: nil,
              batch_number: nil,
              content: []

    def new(operation, batch_number, content) do
        %__MODULE__{
            operation: operation,
            batch_number: batch_number,
            content: content}
    end
end
