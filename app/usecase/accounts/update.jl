struct UpdateAccountInput
    login_id::Union{Nothing,String}
    email::Union{Nothing,String}
    password::Union{Nothing,String}
    first_name::String
    last_name::String
end

function update(account_id::Int, input::UpdateAccountInput)::Account
    account = AccountModule.get_by_id(account_id)
    isnothing(account) && throw(NotFoundError("ACCOUNT_NOT_FOUND"))
    login_id = UsecaseHelper.resolve_login_id(input.login_id, input.email)
    ensure_unique_login_id(login_id, account.id.value)
    ensure_unique_email(input.email, account.id.value)

    account.login_id = login_id
    account.email = input.email
    account.first_name = input.first_name
    account.last_name = input.last_name
    if !isnothing(input.password) && !isempty(input.password)
        account.password_hash = hash_password(input.password)
        account.token_version += 1
    end

    return AccountModule.update(account)
end
