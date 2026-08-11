function verify_reset_password_token(input::Dict)::Nothing
    token = get_reset_token(input)
    reset_token = PasswordResetTokenModule.get_by_hash(UsecaseHelper.hash_token(token))
    validate_reset_token(reset_token)
    return nothing
end
