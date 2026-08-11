function signup(input::Dict)::Account
    UsecaseValidation.validate_signup(input)
    Base.get(ENV, "ENABLE_SIGNUP", "true") == "true" || throw(ForbiddenError("FORBIDDEN"))

    login_id = resolve_login_id(Base.get(input, "login_id", nothing), Base.get(input, "email", nothing))
    ensure_unique_login_id(login_id)
    ensure_unique_email(Base.get(input, "email", nothing))

    account = Account(
        login_id = login_id,
        email = Base.get(input, "email", nothing),
        password_hash = UsecaseHelper.hash_password(input["password"]),
        token_version = 1,
        first_name = input["first_name"],
        last_name = input["last_name"],
    )
    return AccountModule.create(account)
end
