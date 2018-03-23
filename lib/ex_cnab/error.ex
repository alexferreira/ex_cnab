defmodule ExCnab.Error do
  def err(error_key, opts \\ "") do
    case error_key do
      :operation_not_found  -> "Operation not found!"
      :config_not_loaded    -> "Configuration not loaded"
      :fieldset_not_found   -> "Fieldset not found"
      :unrecognized_type    -> "Unrecognized type"
      :unrecognized_format  -> "Unrecognized format"
      :empty_json           -> "Json is empty"
      :not_found            -> "#{opts} Not found"
      :not_parse_inheritance-> "Not parse inheritance on template"
    end
  end
end
