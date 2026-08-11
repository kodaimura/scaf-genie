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
