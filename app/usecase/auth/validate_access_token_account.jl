function validate_access_token_account(payload)::Int
    isnothing(payload) && throw(UnauthorizedError("AUTH_MISSING"))
    (!haskey(payload, "sub") || !haskey(payload, "token_version")) && throw(UnauthorizedError("AUTH_INVALID_PAYLOAD"))

    account_id = try
        parse(Int, string(payload["sub"]))
    catch
        throw(UnauthorizedError("AUTH_INVALID_SUBJECT"))
    end

    account = AccountModule.get_by_id(account_id)
    isnothing(account) && throw(UnauthorizedError("AUTH_NOT_FOUND"))
    !isnothing(account.disabled_at) && throw(UnauthorizedError("ACCOUNT_DISABLED"))
    payload["token_version"] != account.token_version && throw(UnauthorizedError("AUTH_TOKEN_REVOKED"))

    return account.id.value
end
