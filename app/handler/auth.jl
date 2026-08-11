module AuthHandler

include("../usecase/auth/usecase.jl")
include("validation.jl")

import Genie.Requests as Requests

using .AuthUsecase
using .HandlerValidation
using ScafGenie.Auth
using ScafGenie.Errors
using ScafGenie.Exceptions
using ScafGenie.Responses

export signup,
    login,
    refresh,
    logout,
    update_password

function signup()
    request = Requests.jsonpayload()
    try
        Base.get(ENV, "ENABLE_SIGNUP", "true") == "true" || throw(ForbiddenError("FORBIDDEN"))
        validate_signup(request)
        account = AuthUsecase.signup(request)
        return json_success(Dict("account" => AuthUsecase.AccountModule.account_response(account)); status=201)
    catch e
        return json_fail(handle_exception(e))
    end
end

function login()
    request = Requests.jsonpayload()
    try
        validate_login(request)
        account, access_token, refresh_token = AuthUsecase.login(request)
        return json_success(
            Dict(
                "account" => AuthUsecase.AccountModule.account_response(account),
                "access_token" => access_token,
            );
            status=200,
            headers=Dict("Set-Cookie" => refresh_token_cookie_header(refresh_token)),
        )
    catch e
        return json_fail(handle_exception(e))
    end
end

function refresh()
    try
        payload = refreshable()
        isnothing(payload) && throw(UnauthorizedError("REFRESH_INVALID"))
        access_token = AuthUsecase.refresh(payload)
        return json_success(Dict("access_token" => access_token); status=200)
    catch e
        return json_fail(handle_exception(e))
    end
end

function logout()
    try
        return json_no_content(headers=Dict("Set-Cookie" => delete_refresh_token_cookie_header()))
    catch e
        return json_fail(handle_exception(e))
    end
end

function update_password(account_id::Int)
    request = Requests.jsonpayload()
    try
        validate_update_password(request)
        AuthUsecase.update_password(account_id, request)
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

end
