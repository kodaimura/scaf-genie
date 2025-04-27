using Genie, Logging

Genie.Configuration.config!(
  server_port                     = 8000,
  server_host                     = "127.0.0.1",
  log_level                       = Logging.Info,
  log_to_file                     = true,
  server_handle_static_files      = true,
  path_build                      = "build",
  format_julia_builds             = true,
  format_html_output              = true,
  watch                           = true,

  #Custom
  path_lib                        = "app/libs",
  path_helpers                    = "app/helpers",
  autoload                        = [:initializers, :libs, :helpers, :resources, :plugins, :routes, :app],
)

ENV["JULIA_REVISE"] = "auto"