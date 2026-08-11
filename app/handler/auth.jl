module AuthHandler

import Genie.Router as Router
import Genie.Requests as Requests

import ..AccountsDto
import ..AuthDto
import ..AuthUsecase
using ScafGenie.Auth
using ScafGenie.Exceptions
using ScafGenie.Responses

function signup()
    try
        request = AuthDto.signup_request(Requests.jsonpayload())
        input = AuthUsecase.SignupInput(
            request.login_id,
            request.email,
            request.password,
            request.first_name,
            request.last_name,
        )
        account = AuthUsecase.signup(input)
        return json_success(AuthDto.signup_response(AccountsDto.account_response(account)); status=201)
    catch e
        return json_fail(handle_exception(e))
    end
end

function login()
    try
        request = AuthDto.login_request(Requests.jsonpayload())
        result = AuthUsecase.login(AuthUsecase.LoginInput(
            request.login_id,
            request.password,
            request.remember_me,
        ))
        return json_success(
            AuthDto.login_response(AccountsDto.account_response(result.account), result.access_token);
            status=200,
            headers=Dict("Set-Cookie" => refresh_token_cookie_header(result.refresh_token, options="Max-Age=$(result.refresh_token_max_age)")),
        )
    catch e
        return json_fail(handle_exception(e))
    end
end

function refresh()
    try
        result = AuthUsecase.refresh(required_refresh_payload())
        return json_success(AuthDto.refresh_response(result.access_token); status=200)
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
    try
        request = AuthDto.update_password_request(Requests.jsonpayload())
        AuthUsecase.update_password(
            account_id,
            AuthUsecase.UpdatePasswordInput(request.old_password, request.new_password),
        )
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

function forgot_password()
    try
        request = AuthDto.forgot_password_request(Requests.jsonpayload())
        AuthUsecase.forgot_password(AuthUsecase.ForgotPasswordInput(request.email))
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

function verify_reset_password_token()
    try
        request = AuthDto.verify_reset_password_token_request(Dict("token" => Router.params(:token, "")))
        AuthUsecase.verify_reset_password_token(AuthUsecase.VerifyResetPasswordTokenInput(request.token))
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

function reset_password()
    try
        request = AuthDto.reset_password_request(Requests.jsonpayload())
        AuthUsecase.reset_password(AuthUsecase.ResetPasswordInput(request.token, request.new_password))
        return json_no_content()
    catch e
        return json_fail(handle_exception(e))
    end
end

end
