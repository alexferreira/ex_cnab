defmodule ExCnab.Error do

    def err(error_key, :earlang_file) do
        case error_key do
            :enotdir              -> "A component of path is not a directory"
            :eacces               -> "Missing search or write permissions for the parent directories of `path`"
            :eexist               -> "There is already a file or directory named path"
            :enoent               -> "A component of path does not exist"
            :enospc               -> "There is no space left on the device"
            :enomem               -> "There is not enough memory for the contents of the file"
            other                 -> other
        end
    end

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
            :batch_operation_not_found -> "Batch operation not found"
            :template_not_found   -> "Template not found"
        end
    end

end
