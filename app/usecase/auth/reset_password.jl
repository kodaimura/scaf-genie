struct ResetPasswordInput
    token::String
    new_password::String
end

function reset_password(input::ResetPasswordInput)::Nothing
    raw_token = input.token
    reset_token = PasswordResetTokenModule.get_by_hash(UsecaseHelper.hash_token(raw_token))
    validate_reset_token(reset_token)

    account = AccountModule.get_by_id(reset_token.account_id)
    isnothing(account) && throw(NotFoundError("ACCOUNT_NOT_FOUND"))

    timestamp = Dates.now()
    account.password_hash = UsecaseHelper.hash_password(input.new_password)
    account.token_version += 1
    AccountModule.update(account)

    reset_token.used_at = timestamp
    PasswordResetTokenModule.update(reset_token)
    return nothing
end
