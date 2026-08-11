struct SignupInput
    login_id::Union{Nothing,String}
    email::Union{Nothing,String}
    password::String
    first_name::String
    last_name::String
end

function signup(input::SignupInput)::Account
    Base.get(ENV, "ENABLE_SIGNUP", "true") == "true" || throw(ForbiddenError("FORBIDDEN"))

    login_id = resolve_login_id(input.login_id, input.email)
    ensure_unique_login_id(login_id)
    ensure_unique_email(input.email)

    account = Account(
        login_id = login_id,
        email = input.email,
        password_hash = UsecaseHelper.hash_password(input.password),
        token_version = 1,
        first_name = input.first_name,
        last_name = input.last_name,
    )
    return AccountModule.create(account)
end
