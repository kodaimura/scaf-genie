struct CreateAccountInput
    login_id::Union{Nothing,String}
    email::Union{Nothing,String}
    password::String
    first_name::String
    last_name::String
end

function create(input::CreateAccountInput)::Account
    login_id = UsecaseHelper.resolve_login_id(input.login_id, input.email)
    ensure_unique_login_id(login_id, 0)
    ensure_unique_email(input.email, 0)

    account = Account(
        login_id = login_id,
        email = input.email,
        password_hash = hash_password(input.password),
        token_version = 1,
        first_name = input.first_name,
        last_name = input.last_name,
    )
    return AccountModule.create(account)
end
