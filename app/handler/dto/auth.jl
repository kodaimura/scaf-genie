module AuthDto

using ScafGenie.Validations

struct SignupRequest
    login_id::Union{Nothing,String}
    email::Union{Nothing,String}
    password::String
    first_name::String
    last_name::String
end

struct LoginRequest
    login_id::String
    password::String
    remember_me::Bool
end

struct ForgotPasswordRequest
    email::String
end

struct VerifyResetPasswordTokenRequest
    token::String
end

struct ResetPasswordRequest
    token::String
    new_password::String
end

struct UpdatePasswordRequest
    old_password::String
    new_password::String
end

function signup_request(payload::Dict)::SignupRequest
    validate_signup(payload)
    return SignupRequest(
        optional_string(payload, "login_id"),
        optional_string(payload, "email"),
        string(payload["password"]),
        string(payload["first_name"]),
        string(payload["last_name"]),
    )
end

function login_request(payload::Dict)::LoginRequest
    validate_login(payload)
    return LoginRequest(
        string(payload["login_id"]),
        string(payload["password"]),
        Base.get(payload, "remember_me", false) == true,
    )
end

function forgot_password_request(payload::Dict)::ForgotPasswordRequest
    validate_forgot_password(payload)
    return ForgotPasswordRequest(string(payload["email"]))
end

function verify_reset_password_token_request(payload::Dict)::VerifyResetPasswordTokenRequest
    validate_verify_reset_password_token(payload)
    return VerifyResetPasswordTokenRequest(string(payload["token"]))
end

function reset_password_request(payload::Dict)::ResetPasswordRequest
    validate_reset_password(payload)
    return ResetPasswordRequest(string(payload["token"]), string(payload["new_password"]))
end

function update_password_request(payload::Dict)::UpdatePasswordRequest
    validate_update_password(payload)
    return UpdatePasswordRequest(string(payload["old_password"]), string(payload["new_password"]))
end

function validate_signup(request::Dict)
    validate_fields([
        req -> validate_require(req, "first_name"),
        req -> validate_require(req, "last_name"),
        req -> validate_require(req, "password"),
        req -> validate_max_length(req, "login_id", 255),
        req -> validate_max_length(req, "email", 255),
        req -> validate_email_format(req, "email"),
        req -> validate_max_length(req, "first_name", 100),
        req -> validate_max_length(req, "last_name", 100),
        req -> validate_min_length(req, "password", 8),
        req -> validate_max_length(req, "password", 255),
    ], request)
end

function validate_login(request::Dict)
    validate_fields([
        req -> validate_require(req, "login_id"),
        req -> validate_require(req, "password"),
        req -> validate_max_length(req, "login_id", 255),
        req -> validate_max_length(req, "password", 255),
    ], request)
end

function validate_forgot_password(request::Dict)
    validate_fields([
        req -> validate_require(req, "email"),
        req -> validate_max_length(req, "email", 255),
        req -> validate_email_format(req, "email"),
    ], request)
end

function validate_verify_reset_password_token(request::Dict)
    validate_fields([
        req -> validate_require(req, "token"),
        req -> validate_max_length(req, "token", 500),
    ], request)
end

function validate_reset_password(request::Dict)
    validate_fields([
        req -> validate_require(req, "token"),
        req -> validate_require(req, "new_password"),
        req -> validate_max_length(req, "token", 500),
        req -> validate_min_length(req, "new_password", 8),
        req -> validate_max_length(req, "new_password", 255),
    ], request)
end

function validate_update_password(request::Dict)
    validate_fields([
        req -> validate_require(req, "old_password"),
        req -> validate_require(req, "new_password"),
        req -> validate_min_length(req, "new_password", 8),
        req -> validate_max_length(req, "new_password", 255),
    ], request)
end

function signup_response(account_response::Dict)::Dict{String,Any}
    return Dict("account" => account_response)
end

function login_response(account_response::Dict, access_token::String)::Dict{String,Any}
    return Dict("account" => account_response, "access_token" => access_token)
end

function refresh_response(access_token::String)::Dict{String,Any}
    return Dict("access_token" => access_token)
end

function optional_string(payload::Dict, key::String)::Union{Nothing,String}
    value = Base.get(payload, key, nothing)
    isnothing(value) && return nothing
    text = strip(string(value))
    return isempty(text) ? nothing : text
end

end
