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
