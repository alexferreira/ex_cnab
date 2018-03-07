defmodule ExCnab.Error do
  def err(error_key) do
    case error_key do
      :operation_not_found -> "Operation not found!"
      :config_not_loaded   -> "Configuration not loaded"
      :fieldset_not_found  -> "Fieldset not found"
      :unrecognized_type  -> "Unrecognized type"
      :unrecognized_format  -> "Unrecognized format"
    end
  end
end
