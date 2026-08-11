module AuthHandler

import Genie.Requests as Requests
import Genie.Router as Router

using ..AuthUsecase
using ScafGenie.Auth
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
        account = AuthUsecase.signup(request)
        return json_success(Dict("account" => AuthUsecase.AccountModule.account_response(account)); status=201)
    catch e
        return json_fail(handle_exception(e))
    end
end

function login()
    request = Requests.jsonpayload()
    try
        account, access_token, refresh_token, refresh_token_max_age = AuthUsecase.login(request)
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
        access_token = AuthUsecase.refresh(refreshable())
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

function update_password(account_id::Int, target_account_id::String)
    request = Requests.jsonpayload()
    try
        AuthUsecase.update_password(account_id, target_account_id, request)
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

function forgot_password()
    request = Requests.jsonpayload()
    try
        AuthUsecase.forgot_password(request)
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

function verify_reset_password_token()
    request = Dict("token" => Router.params(:token, ""))
    try
        AuthUsecase.verify_reset_password_token(request)
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

function reset_password()
    request = Requests.jsonpayload()
    try
        AuthUsecase.reset_password(request)
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

end
