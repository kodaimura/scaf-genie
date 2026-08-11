module AuthUsecase

include("../../module/account/module.jl")
include("../../module/password_reset_token/module.jl")
include("../helper.jl")

using .AccountModule
using .PasswordResetTokenModule
using .UsecaseHelper
import Dates
import HTTP
using ScafGenie.Errors
using ScafGenie.Jwt
using ScafGenie.Mailer

export signup,
    login,
    refresh,
    update_password,
    forgot_password,
    verify_reset_password_token,
    reset_password

function signup(input::Dict)::Account
    login_id = resolve_login_id(Base.get(input, "login_id", nothing), Base.get(input, "email", nothing))
    ensure_unique_login_id(login_id)
    ensure_unique_email(Base.get(input, "email", nothing))

    account = Account(
        login_id = login_id,
        email = Base.get(input, "email", nothing),
        password_hash = UsecaseHelper.hash_password(input["password"]),
        token_version = 1,
        first_name = input["first_name"],
        last_name = input["last_name"],
    )
    return AccountModule.create(account)
end

function login(input::Dict)::Tuple{Account,String,String}
    account = AccountModule.get_by_login_id(input["login_id"])
    if isnothing(account) || !UsecaseHelper.verify_password(input["password"], account.password_hash)
        throw(UnauthorizedError("INVALID_CREDENTIALS"))
    end
    if !isnothing(account.disabled_at)
        throw(UnauthorizedError("ACCOUNT_DISABLED"))
    end

    payload = Dict{String,Any}(
        "sub" => string(account.id.value),
        "token_version" => account.token_version,
    )
    access_token = Jwt.create_access_token(copy(payload))
    refresh_token = Jwt.create_refresh_token(copy(payload))
    return account, access_token, refresh_token
end

function refresh(payload::Dict)::String
    account_id = parse(Int, string(payload["sub"]))
    account = AccountModule.get_by_id(account_id)
    if isnothing(account)
        throw(UnauthorizedError("AUTH_NOT_FOUND"))
    end
    if !isnothing(account.disabled_at)
        throw(UnauthorizedError("ACCOUNT_DISABLED"))
    end
    if payload["token_version"] != account.token_version
        throw(UnauthorizedError("AUTH_TOKEN_REVOKED"))
    end

    return Jwt.create_access_token(Dict{String,Any}(
        "sub" => string(account.id.value),
        "token_version" => account.token_version,
    ))
end

function update_password(account_id::Int, input::Dict)::Nothing
    account = AccountModule.get_by_id(account_id)
    isnothing(account) && throw(NotFoundError("ACCOUNT_NOT_FOUND"))

    if !UsecaseHelper.verify_password(input["old_password"], account.password_hash)
        throw(UnauthorizedError("CURRENT_PASSWORD_INCORRECT"))
    end

    account.password_hash = UsecaseHelper.hash_password(input["new_password"])
    account.token_version += 1
    AccountModule.update(account)
    return nothing
end

function forgot_password(input::Dict)::Nothing
    email = strip(string(input["email"]))
    account = AccountModule.get_by_email(email)
    if isnothing(account) || !isnothing(account.disabled_at)
        return nothing
    end

    timestamp = Dates.now()
    latest = PasswordResetTokenModule.find_latest_by_account_id(account.id.value)
    resend_minutes = parse(Int, Base.get(ENV, "PASSWORD_RESET_RESEND_INTERVAL_MINUTES", "5"))
    if !isnothing(latest) && latest.created_at > timestamp - Dates.Minute(resend_minutes)
        return nothing
    end

    PasswordResetTokenModule.invalidate_active_tokens(account.id.value)

    raw_token = UsecaseHelper.generate_token()
    expires_minutes = parse(Int, Base.get(ENV, "PASSWORD_RESET_TOKEN_EXPIRES_MINUTES", "30"))
    PasswordResetTokenModule.create(PasswordResetToken(
        account_id = account.id.value,
        token_hash = UsecaseHelper.hash_token(raw_token),
        expires_at = timestamp + Dates.Minute(expires_minutes),
        created_at = timestamp,
        updated_at = timestamp,
    ))

    reset_url = build_reset_url(raw_token)
    body = build_password_reset_mail_body(
        "$(account.last_name) $(account.first_name)",
        reset_url,
        expires_minutes,
    )
    send_mail(to=email, subject="Password reset", body=body)
    return nothing
end

function verify_reset_password_token(input::Dict)::Nothing
    token = get_reset_token(input)
    reset_token = PasswordResetTokenModule.get_by_hash(UsecaseHelper.hash_token(token))
    validate_reset_token(reset_token)
    return nothing
end

function reset_password(input::Dict)::Nothing
    raw_token = string(input["token"])
    reset_token = PasswordResetTokenModule.get_by_hash(UsecaseHelper.hash_token(raw_token))
    validate_reset_token(reset_token)

    account = AccountModule.get_by_id(reset_token.account_id)
    isnothing(account) && throw(NotFoundError("ACCOUNT_NOT_FOUND"))

    timestamp = Dates.now()
    account.password_hash = UsecaseHelper.hash_password(input["new_password"])
    account.token_version += 1
    AccountModule.update(account)

    reset_token.used_at = timestamp
    PasswordResetTokenModule.update(reset_token)
    return nothing
end

function ensure_unique_login_id(login_id::String)::Nothing
    existing = AccountModule.get_by_login_id(login_id)
    !isnothing(existing) && throw(ConflictError("LOGIN_ID_ALREADY_EXISTS"))
    return nothing
end

function ensure_unique_email(email)::Nothing
    if isnothing(email) || isempty(strip(string(email)))
        return nothing
    end
    existing = AccountModule.get_by_email(string(email))
    !isnothing(existing) && throw(ConflictError("EMAIL_ALREADY_EXISTS"))
    return nothing
end

function validate_reset_token(token)::Nothing
    isnothing(token) && throw(BadRequestError("TOKEN_INVALID"))
    !isnothing(token.used_at) && throw(BadRequestError("TOKEN_ALREADY_USED"))
    token.expires_at <= Dates.now() && throw(BadRequestError("TOKEN_EXPIRED"))
    return nothing
end

function get_reset_token(input::Dict)::String
    token = strip(string(Base.get(input, "token", "")))
    isempty(token) && throw(BadRequestError("TOKEN_INVALID"))
    return token
end

function build_reset_url(token::String)::String
    base_url = Base.get(ENV, "PASSWORD_RESET_URL_BASE", "http://localhost:3000/reset-password")
    separator = occursin("?", base_url) ? "&" : "?"
    return "$(base_url)$(separator)token=$(HTTP.URIs.escapeuri(token))"
end

function build_password_reset_mail_body(name::String, reset_url::String, expires_minutes::Int)::String
    return join([
        "Hello $name,",
        "",
        "We received a request to reset your password.",
        "Open the link below to set a new password.",
        "",
        reset_url,
        "",
        "This link expires in $expires_minutes minutes.",
        "If you did not request this, you can ignore this email.",
    ], "\n")
end

end
