function refresh(payload)::String
    isnothing(payload) && throw(UnauthorizedError("REFRESH_INVALID"))
    (!haskey(payload, "sub") || !haskey(payload, "token_version")) && throw(UnauthorizedError("AUTH_INVALID_PAYLOAD"))

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
