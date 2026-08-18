struct ResetPasswordInput
    token::String
    new_password::String
end

function reset_password(input::ResetPasswordInput)::Nothing
    Database.transaction() do
        token_hash = hash_token(input.token)
        reset_token = PasswordResetTokenModule.get_by_hash(token_hash)
        validate_reset_token(reset_token)
        PasswordResetTokenModule.mark_used_if_unused(token_hash) ||
            throw(BadRequestError("TOKEN_ALREADY_USED"))

        account = AccountModule.get_by_id(reset_token.account_id)
        isnothing(account) && throw(NotFoundError("ACCOUNT_NOT_FOUND"))

        account.password_hash = hash_password(input.new_password)
        account.token_version += 1
        AccountModule.update(account)
    end
    return nothing
end
