import Config

config :krug, 
  author: "Daniel Augusto Krug"

config :bcrypt_elixir,
  log_rounds: 15
  

import_config "#{Mix.env()}.exs"
