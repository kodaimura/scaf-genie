using Genie, Logging

Genie.Configuration.config!(
  server_port                     = 8000,
  server_host                     = "127.0.0.1",
  log_level                       = Logging.Debug,
  log_to_file                     = true,
  server_handle_static_files      = true,

  #Custom
  autoload                        = [:initializers, :resources, :plugins, :routes, :app],
)

ENV["JULIA_REVISE"] = "off"
