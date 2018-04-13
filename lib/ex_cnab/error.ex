defmodule ExCnab.Error do
  def err(error_key, opts \\ "") do
    case error_key do
      :operation_not_found  -> "Operation not found!"
      :config_not_loaded    -> "Configuration not loaded"
      :fieldset_not_found   -> "Fieldset not found"
      :unrecognized_type    -> "Unrecognized type"
      :unrecognized_format  -> "Unrecognized format #{opts}"
      :empty_json           -> "Json is empty"
      :not_found            -> "#{opts} Not found"
      :not_found_context    -> "#{opts} Not found in context"
      :not_parse_inheritance-> "Not parse inheritance on template"
      :invalid_path         -> "Path to create CNAB does not exist"
      :empty_json           -> "Json is empty"
    end
  end
end
