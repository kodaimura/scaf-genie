function update(account_id::Int, input::Dict)::Account
    account = get(account_id)
    login_id = resolve_login_id(Base.get(input, "login_id", nothing), Base.get(input, "email", nothing))
    ensure_unique_login_id(login_id, account.id.value)
    ensure_unique_email(Base.get(input, "email", nothing), account.id.value)

    account.login_id = login_id
    account.email = Base.get(input, "email", nothing)
    account.first_name = input["first_name"]
    account.last_name = input["last_name"]
    if haskey(input, "password") && !isnothing(input["password"]) && !isempty(string(input["password"]))
        account.password_hash = UsecaseHelper.hash_password(input["password"])
        account.token_version += 1
    end

    return AccountModule.update(account)
end
