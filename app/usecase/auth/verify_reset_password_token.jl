function verify_reset_password_token(input::Dict)::Nothing
    UsecaseValidation.validate_verify_reset_password_token(input)

    token = get_reset_token(input)
    reset_token = PasswordResetTokenModule.get_by_hash(UsecaseHelper.hash_token(token))
    validate_reset_token(reset_token)
    return nothing
end
