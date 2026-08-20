function disable(account_id::Int)::Account
    account = AccountModule.get_by_id(account_id)
    isnothing(account) && throw(NotFoundError("ACCOUNT_NOT_FOUND"))
    return AccountModule.disable(account)
end
