function enable(account_id::Int)::Account
    return AccountModule.enable(get(account_id))
end
