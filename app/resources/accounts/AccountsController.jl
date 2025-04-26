module AccountsController

include("AccountsService.jl")
include("AccountsRequest.jl")

import Genie.Requests as Requests

import .AccountsService
using .AccountsRequest
using ScafGenie.Responses
using ScafGenie.Errors
using ScafGenie.Auth
using ScafGenie.Jwt

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
        access_token = Jwt.create_access_token(Dict(
            "id" => account.id.value, 
            "account_name" => account.account_name
        ))
        refresh_token = Jwt.create_refresh_token(Dict(
            "id" => account.id.value, 
            "account_name" => account.account_name
        ))

        cookies = [
            access_token_cookie_header(access_token),
            refresh_token_cookie_header(refresh_token)
        ]
        return json_success(
            Dict("access_token" => access_token, "refresh_token" => refresh_token);
            status=200, headers=Dict("Set-Cookie" => join(cookies, "\nSet-Cookie: "))
        )
    catch e
        return json_fail(e)
    end
end

function logout()
    try
        cookies = [
            access_token_cookie_header(""; options="Expires=-1"),
            refresh_token_cookie_header(""; options="Expires=-1")
        ]
        return json_success(;status=200, headers=Dict("Set-Cookie" => join(cookies, "\nSet-Cookie: ")))
    catch e
        return json_fail(e)
    end
end

function refresh()
    try
        refresh_token = get_refresh_token()
        isnothing(refresh_token) && throw(UnauthorizedError("invalid or expired refresh token"))
        
        payload = Jwt.verify_refresh_token(refresh_token)
        isnothing(payload) && throw(UnauthorizedError("invalid or expired refresh token"))

        access_token = Jwt.create_access_token(Dict(
            "id" => payload["id"], 
            "account_name" => payload["account_name"]
        ))
        cookies = [access_token_cookie_header(access_token)]
        return json_success(;status=200, headers=Dict("Set-Cookie" => join(cookies, "\nSet-Cookie: ")))
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
