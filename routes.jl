using Genie.Router
using Genie.Renderer

include("app/usecase/auth/usecase.jl")
include("app/usecase/accounts/usecase.jl")
include("app/handler/dto/auth.jl")
include("app/handler/dto/accounts.jl")
include("app/handler/auth.jl")
include("app/handler/accounts.jl")

using ScafGenie.Auth
using ScafGenie.Errors
using ScafGenie.Exceptions
using ScafGenie.Responses

import .AuthUsecase
import .AuthHandler
import .AccountsHandler

frontend_origins = ScafGenie.Config.frontend_origins()
Genie.config.cors_headers["Access-Control-Allow-Origin"] = first(frontend_origins)
Genie.config.cors_headers["Access-Control-Allow-Credentials"] = "true"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"

route("/health") do
    return json_success(Dict("status" => "ok"))
end

route("/api/auth/signup", method="POST") do
    return AuthHandler.signup()
end

route("/api/auth/login", method="POST") do
    return AuthHandler.login()
end

route("/api/auth/refresh", method="POST") do
    return AuthHandler.refresh()
end

route("/api/auth/logout", method="POST") do
    return AuthHandler.logout()
end

route("/api/auth/forgot-password", method="POST") do
    return AuthHandler.forgot_password()
end

route("/api/auth/reset-password/verify", method="GET") do
    return AuthHandler.verify_reset_password_token()
end

route("/api/auth/reset-password", method="POST") do
    return AuthHandler.reset_password()
end

route("/api/accounts", method="GET") do
    with_api_auth() do account_id
        return AccountsHandler.list()
    end
end

route("/api/accounts", method="POST") do
    with_api_auth() do account_id
        return AccountsHandler.create()
    end
end

route("/api/accounts/me", method="GET") do
    with_api_auth() do account_id
        return AccountsHandler.get_current(account_id)
    end
end

route("/api/accounts/me/password", method="PUT") do
    with_api_auth() do account_id
        return AuthHandler.update_password(account_id)
    end
end

route("/api/accounts/:target_account_id::Int#\\d+/disable", method="PUT") do
    with_api_auth() do account_id
        return AccountsHandler.disable(parse_account_id_param())
    end
end

route("/api/accounts/:target_account_id::Int#\\d+/enable", method="PUT") do
    with_api_auth() do account_id
        return AccountsHandler.enable(parse_account_id_param())
    end
end

route("/api/accounts/:target_account_id::Int#\\d+", method="GET") do
    with_api_auth() do account_id
        return AccountsHandler.get(parse_account_id_param())
    end
end

route("/api/accounts/:target_account_id::Int#\\d+", method="PUT") do
    with_api_auth() do account_id
        return AccountsHandler.update(parse_account_id_param())
    end
end

###################################################################################################

function with_api_auth(f::Function)
    try
        account_id = AuthUsecase.validate_access_token_account(required_access_payload())
        return f(account_id)
    catch e
        return json_fail(handle_exception(e))
    end
end

function parse_account_id_param()::Int
    account_id = tryparse(Int, string(params(:target_account_id)))
    isnothing(account_id) && throw(BadRequestError("BAD_REQUEST"))
    return account_id
end

###################################################################################################
