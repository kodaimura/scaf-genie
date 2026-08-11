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
    if isnothing(account) || !verify_password(input.password, account.password_hash)
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
    refresh_token = Jwt.create_refresh_token(copy(payload); remember_me=input.remember_me)
    refresh_token_max_age = input.remember_me ?
        Config.refresh_token_remember_me_expires_seconds() :
        Config.refresh_token_expires_seconds()
    return LoginResult(account, access_token, refresh_token, refresh_token_max_age)
end
