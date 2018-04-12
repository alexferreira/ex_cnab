# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ex_cnab,
  cnab_fieldset_templates: "/ex_cnab/fieldsets/",
  structure: %{
    register_types: [
      header_file: 0,
      header_batch: 1,
      init_batch: 2,
      detail: 3,
      final_batch: 4,
      trailer_batch: 5,
      trailer_file: 9
    ]
  }

config :logger, level: :warn

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :ex_cnab, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:ex_cnab, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
