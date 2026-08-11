module AuthHandler

include("../usecase/auth/usecase.jl")
include("validation.jl")

import Genie.Requests as Requests
import Genie.Router as Router

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
    update_password,
    forgot_password,
    verify_reset_password_token,
    reset_password

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
        remember_me = Base.get(request, "remember_me", false) == true
        refresh_token_max_age = remember_me ?
            parse(Int, Base.get(ENV, "REFRESH_TOKEN_REMEMBER_ME_EXPIRES_SECONDS", "2592000")) :
            parse(Int, Base.get(ENV, "REFRESH_TOKEN_EXPIRES_SECONDS", "43200"))
        return json_success(
            Dict(
                "account" => AuthUsecase.AccountModule.account_response(account),
                "access_token" => access_token,
            );
            status=200,
            headers=Dict("Set-Cookie" => refresh_token_cookie_header(refresh_token, options="Max-Age=$refresh_token_max_age")),
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

function forgot_password()
    request = Requests.jsonpayload()
    try
        validate_forgot_password(request)
        AuthUsecase.forgot_password(request)
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

function verify_reset_password_token()
    request = Dict("token" => Router.params(:token, ""))
    try
        validate_verify_reset_password_token(request)
        AuthUsecase.verify_reset_password_token(request)
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

function reset_password()
    request = Requests.jsonpayload()
    try
        validate_reset_password(request)
        AuthUsecase.reset_password(request)
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

end
