module AccountsController

include("../core/Validation.jl")
include("AccountsService.jl")

import Genie.Renderer.Json as RendererJson
import Genie.Requests as Requests

using .Validation
using .AccountsService

export signup, login, logout

function signup(ctx::Dict{String, Any})
    request = Requests.jsonpayload()
    try
        validate_signup(request)
        account_name = request["account_name"]
        account_password = request["account_password"]

        AccountsService.signup(account_name, account_password)
        return RendererJson.json(Dict(); status=201)
    catch e
        return json_error_response(e, Requests.request())
    end
end

function validate_signup(request::Dict{String, Any})
    require_keys(request, ["account_name", "account_password"])
    account_name = request["account_name"]
    account_password = request["account_password"]

    validate_not_empty(account_name, "account_name")
    validate_not_empty(account_password, "account_password")
    validate_min_length(account_password, "account_password", 8)
end

function login(ctx::Dict{String, Any})
    request = Requests.jsonpayload()
    try
        validate_login(request)
        account_name = request["account_name"]
        account_password = request["account_password"]
        
        account = AccountsService.login(account_name, account_password)
        if isnothing(account)
            throw(UnauthorizedError())
        end
        token = AccountsService.create_jwt(account)
        cookie_header = "access_token=$token; Path=/; HttpOnly; Secure; SameSite=Lax"
        return RendererJson.json(Dict("access_token" => token); status=200, headers=Dict("Set-Cookie" => cookie_header))
    catch e
        return json_error_response(e, Requests.request())
    end
end

function validate_login(request::Dict{String, Any})
    require_keys(request, ["account_name", "account_password"])
    account_name = request["account_name"]
    account_password = request["account_password"]

    validate_not_empty(account_name, "account_name")
    validate_not_empty(account_password, "account_password")
end

function logout(ctx::Dict{String, Any})
    try
        cookie_header = "access_token=; Path=/; HttpOnly; Secure; SameSite=Lax; Expires=Thu, 01 Jan 1970 00:00:00 GMT"
        return RendererJson.json(Dict(); status=200, headers=Dict("Set-Cookie" => cookie_header))
    catch e
        return json_error_response(e, Requests.request())
    end
end

end
