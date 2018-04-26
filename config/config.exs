# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ex_cnab,
      cnab_writing_path: "./priv/cnabs/",
# The replace_code_to_string config replaces all output codes to it's corresponde
# string in ExCnab.Table when is set as true
      replace_code_to_string: false


config :logger, level: :warn
