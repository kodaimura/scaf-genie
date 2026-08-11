struct LoginInput
    login_id::String
    password::String
    remember_me::Bool
end

struct LoginResult
    account::Account
    access_token::String
    refresh_token::String
    refresh_token_max_age::Int
end

function login(input::LoginInput)::LoginResult
    account = AccountModule.get_by_login_id(input.login_id)
    if isnothing(account) || !UsecaseHelper.verify_password(input.password, account.password_hash)
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
    refresh_token_max_age = input.remember_me ?
        parse(Int, Base.get(ENV, "REFRESH_TOKEN_REMEMBER_ME_EXPIRES_SECONDS", "2592000")) :
        parse(Int, Base.get(ENV, "REFRESH_TOKEN_EXPIRES_SECONDS", "43200"))
    return LoginResult(account, access_token, refresh_token, refresh_token_max_age)
end
