struct VerifyResetPasswordTokenInput
    token::String
end

function verify_reset_password_token(input::VerifyResetPasswordTokenInput)::Nothing
    token = get_reset_token(input.token)
    reset_token = PasswordResetTokenModule.get_by_hash(hash_token(token))
    validate_reset_token(reset_token)
    return nothing
end
