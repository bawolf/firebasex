use Mix.Config

config :firebasex,
  project_id: "sample-project-id"

config :syringe, injector_strategy: AliasInjectingStrategy

import_config "#{Mix.env()}.exs"
