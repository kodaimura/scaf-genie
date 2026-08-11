module AuthUsecase

include("../../module/account/module.jl")
include("../helper.jl")

using .AccountModule
using .UsecaseHelper
using ScafGenie.Errors
using ScafGenie.Jwt

export signup,
    login,
    refresh,
    update_password

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

end
