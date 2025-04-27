using Genie.Router
using Genie.Renderer
import Genie.Responses: setheaders!

using ScafGenie.Jwt
using ScafGenie.Auth
using ScafGenie.Responses

frontend_origin = get(ENV, "FRONTEND_ORIGIN", "http://localhost:3000")
Genie.config.cors_headers["Access-Control-Allow-Origin"] = frontend_origin
Genie.config.cors_headers["Access-Control-Allow-Credentials"] = "true"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"

route("/") do
    with_web_auth() do payload
        return MiscController.index(payload)
    end
end

route("/login") do
    return serve_static_file("login.html")
end

route("/signup") do
    return serve_static_file("signup.html")
end

route("/api/accounts/login", method="POST") do
    return AccountsController.login()
end

route("/api/accounts/logout", method="POST") do
    return AccountsController.logout()
end

route("/api/accounts/signup", method="POST") do
    return AccountsController.signup()
end

route("/api/accounts/refresh", method="POST") do
    return AccountsController.refresh()
end

route("/api/accounts/me") do
    with_api_auth() do payload
        return AccountsController.me(payload)
    end
end

###################################################################################################

function with_web_auth(f::Function)
    payload = authenticated()
    if isnothing(payload)
        payload = refreshable()
        isnothing(payload) && return redirect_login()
        access_token = create_access_token(Dict(
            "id" => payload["id"],
            "account_name" => payload["account_name"]
        ))
        payload = verify_access_token(access_token)
        isnothing(payload) && return redirect_login()

        cookie = access_token_cookie_header(access_token)
        return setheaders!(f(payload), Dict("Set-Cookie" => cookie))
    end
    return f(payload)
end

function with_api_auth(f::Function)
    payload = authenticated()
    if isnothing(payload)
        return json_unauthorized()
    end
    return f(payload)
end

###################################################################################################