module AccountsController

include("AccountsService.jl")

import Genie.Requests as Requests

import .AccountsService
using ScafGenie.Responses
using ScafGenie.Errors
using ScafGenie.Validations

export signup, login, logout

function signup(ctx::Dict{String, Any})
    request = Requests.jsonpayload()
    try
        validate_fields([
            () -> validate_require(request, "account_name")
            () -> validate_require(request, "account_password")
            () -> validate_min_length(request, "account_password", 8)
        ])
        account_name = request["account_name"]
        account_password = request["account_password"]

        AccountsService.signup(account_name, account_password)
        return json_success(; status=201)
    catch e
        return json_fail(e)
    end
end

function login(ctx::Dict{String, Any})
    request = Requests.jsonpayload()
    try
        validate_fields([
            () -> validate_require(request, "account_name")
            () -> validate_require(request, "account_password")
        ])
        account_name = request["account_name"]
        account_password = request["account_password"]
        
        account = AccountsService.login(account_name, account_password)
        if isnothing(account)
            throw(UnauthorizedError())
        end
        token = AccountsService.create_jwt(account)
        headers = Dict("Set-Cookie" => "access_token=$token; Path=/; HttpOnly; Secure; SameSite=Lax")
        return json_success(Dict("access_token" => token); status=200, headers=headers)
    catch e
        return json_fail(e)
    end
end

function logout(ctx::Dict{String, Any})
    try
        headers = Dict("Set-Cookie" => "access_token=; Path=/; HttpOnly; Secure; SameSite=Lax; Expires=Thu, 01 Jan 1970 00:00:00 GMT")
        return json_success(; status=200, headers=headers)
    catch e
        return json_fail(e)
    end
end

end
