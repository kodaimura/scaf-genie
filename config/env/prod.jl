using Genie, Logging

Genie.Configuration.config!(
  server_port                     = 8000,
  server_host                     = (Sys.iswindows() ? "127.0.0.1" : "0.0.0.0"),
  log_level                       = Logging.Error,
  log_to_file                     = true,
  server_handle_static_files      = true, # for best performance set up Nginx or Apache web proxies and set this to false
  path_build                      = "build",
  format_julia_builds             = false,
  format_html_output              = false,

  #Custom
  path_lib                        = "app/libs",
  path_helpers                    = "app/helpers",
  autoload                        = [:initializers, :libs, :helpers, :resources, :plugins, :routes, :app],
)

if Genie.config.server_handle_static_files
  @warn("For performance reasons Genie should not serve static files (.css, .js, .jpg, .png, etc) in production.
         It is recommended to set up Apache or Nginx as a reverse proxy and cache to serve static assets.")
end

ENV["JULIA_REVISE"] = "off"