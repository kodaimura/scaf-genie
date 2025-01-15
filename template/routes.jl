using Genie.Router
using Genie.Requests
using Genie.Cookies
using Genie.Renderer
using Genie.Renderer.Json
using HTTP

route("/") do
  #is_authorized() || return json_unauthorized()
  return serve_static_file("index.html")
end

route("/login") do
  return serve_static_file("login.html")
end

route("/signup") do
  return serve_static_file("signup.html")
end

route("/api/login", method="POST") do
  return AccountsController.login(get_context())
end

route("/api/logout", method="POST") do
  return AccountsController.logout(get_context())
end

route("/api/signup", method="POST") do
  return AccountsController.signup(get_context())
end

route("/api/accounts/me") do
  if is_authorized()
    payload = get_context()["payload"]
    return Genie.Renderer.Json.json(Dict("id" => payload["id"], "account_name" => payload["account_name"]); status=200)
  end
  return Genie.Renderer.Json.json(Dict(); status=401)
end

###################################################################################################
function redirect_login()
  Genie.Renderer.redirect("login")
end

function json_unauthorized()
  Genie.Renderer.Json.json(Dict(); status=401)
end

function get_context()::Dict{String, Any}
  cookie = Genie.Cookies.getcookies(Genie.Requests.request())
  token = get_cookie_value(cookie, "token")
  ctx = Dict{String, Any}()
  if !isnothing(token)
    ctx["payload"] = Jwt.decode_payload(token)
  end
  return ctx
end

function is_authorized()::Bool
  cookie = Genie.Cookies.getcookies(Genie.Requests.request())
  token = get_cookie_value(cookie, "token")
  if isnothing(token)
    return false
  end

  try
    return Jwt.verify(token)
  catch e
    return false
  end
end

function get_cookie_value(cookies::Vector{HTTP.Cookies.Cookie}, name::String)::Union{String, Nothing}
  for cookie in cookies
    if cookie.name == name
      return cookie.value
    end
  end
  return nothing
end
###################################################################################################