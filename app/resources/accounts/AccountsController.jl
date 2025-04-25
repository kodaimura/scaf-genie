module AccountsController

include("AccountsService.jl")
include("AccountsRequest.jl")

import Genie.Requests as Requests

import .AccountsService
using .AccountsRequest
using ScafGenie.Responses
using ScafGenie.Errors

export signup, login, logout, me

function signup()
    request = Requests.jsonpayload()
    try
        validate_account_signup(request)
        account_name = request["account_name"]
        account_password = request["account_password"]

        AccountsService.signup(account_name, account_password)
        return json_success(; status=201)
    catch e
        return json_fail(e)
    end
end

function login()
    request = Requests.jsonpayload()
    try
        validate_account_login(request)
        account_name = request["account_name"]
        account_password = request["account_password"]

        account = AccountsService.login(account_name, account_password)
        if isnothing(account)
            throw(UnauthorizedError())
        end
        token = AccountsService.create_jwt(account)
        headers = Dict(
            "Set-Cookie" => "access_token=$token; Path=/; HttpOnly; Secure; SameSite=Lax",
        )
        return json_success(Dict("access_token" => token); status=200, headers=headers)
    catch e
        return json_fail(e)
    end
end

function logout()
    try
        headers = Dict(
            "Set-Cookie" => "access_token=; Path=/; HttpOnly; Secure; SameSite=Lax; Expires=Thu, 01 Jan 1970 00:00:00 GMT",
        )
        return json_success(; status=200, headers=headers)
    catch e
        return json_fail(e)
    end
end

function me(payload::Dict{String,Any})
    try
        return json_success(Dict(
            "id" => payload["id"],
            "account_name" => payload["account_name"]
        ))
        return json_success(; status=200, headers=headers)
    catch e
        return json_fail(e)
    end
end

end
