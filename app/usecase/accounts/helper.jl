function ensure_unique_login_id(login_id::String, except_id)::Nothing
    existing = AccountModule.get_by_login_id(login_id)
    if !isnothing(existing) && existing.id.value != except_id
        throw(ConflictError("LOGIN_ID_ALREADY_EXISTS"))
    end
    return nothing
end

function ensure_unique_email(email, except_id)::Nothing
    if isnothing(email) || isempty(strip(string(email)))
        return nothing
    end
    existing = AccountModule.get_by_email(string(email))
    if !isnothing(existing) && existing.id.value != except_id
        throw(ConflictError("EMAIL_ALREADY_EXISTS"))
    end
    return nothing
end
