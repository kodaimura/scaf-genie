using Genie.Router
using Genie.Renderer

include("app/handler/auth.jl")
include("app/handler/accounts.jl")

using ScafGenie.Auth
using ScafGenie.Errors
using ScafGenie.Exceptions
using ScafGenie.Responses

using .AuthHandler
using .AccountsHandler

frontend_origins = split(Base.get(ENV, "FRONTEND_ORIGINS", "http://localhost:3000,http://localhost:5173"), ",")
Genie.config.cors_headers["Access-Control-Allow-Origin"] = strip(first(frontend_origins))
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

route("/api/accounts/:target_account_id/password", method="PUT") do
    with_api_auth() do account_id
        target_account_id = string(params(:target_account_id))
        target_account_id == "me" || throw(BadRequestError("INVALID_STATE"))
        return AuthHandler.update_password(account_id)
    end
end

route("/api/accounts/:target_account_id/disable", method="PUT") do
    with_api_auth() do account_id
        return AccountsHandler.disable(parse(Int, string(params(:target_account_id))))
    end
end

route("/api/accounts/:target_account_id/enable", method="PUT") do
    with_api_auth() do account_id
        return AccountsHandler.enable(parse(Int, string(params(:target_account_id))))
    end
end

route("/api/accounts/:target_account_id", method="GET") do
    with_api_auth() do account_id
        target_account_id = string(params(:target_account_id))
        if target_account_id == "me"
            return AccountsHandler.get_current(account_id)
        end
        return AccountsHandler.get(parse(Int, target_account_id))
    end
end

route("/api/accounts/:target_account_id", method="PUT") do
    with_api_auth() do account_id
        target_account_id = string(params(:target_account_id))
        if target_account_id == "me"
            return AccountsHandler.update(account_id)
        end
        return AccountsHandler.update(parse(Int, target_account_id))
    end
end

###################################################################################################

function with_api_auth(f::Function)
    try
        jwt_payload = authenticated()
        isnothing(jwt_payload) && throw(UnauthorizedError("AUTH_MISSING"))

        account_id = parse(Int, string(jwt_payload["sub"]))
        account = AccountsHandler.AccountsUsecase.get_current(account_id)
        if !isnothing(account.disabled_at)
            throw(UnauthorizedError("ACCOUNT_DISABLED"))
        end
        if jwt_payload["token_version"] != account.token_version
            throw(UnauthorizedError("AUTH_TOKEN_REVOKED"))
        end

        return f(account_id)
    catch e
        return json_fail(handle_exception(e))
    end
end

###################################################################################################
