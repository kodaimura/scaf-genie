function disable(account_id::Int)::Account
    return AccountModule.disable(get(account_id))
end
