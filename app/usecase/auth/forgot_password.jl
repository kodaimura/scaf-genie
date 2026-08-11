struct ForgotPasswordInput
    email::String
end

function forgot_password(input::ForgotPasswordInput)::Nothing
    email = strip(input.email)
    account = AccountModule.get_by_email(email)
    if isnothing(account) || !isnothing(account.disabled_at)
        return nothing
    end

    timestamp = Dates.now()
    latest = PasswordResetTokenModule.find_latest_by_account_id(account.id.value)
    resend_minutes = Config.password_reset_resend_interval_minutes()
    if !isnothing(latest) && latest.created_at > timestamp - Dates.Minute(resend_minutes)
        return nothing
    end

    PasswordResetTokenModule.invalidate_active_tokens(account.id.value)

    raw_token = generate_token()
    expires_minutes = Config.password_reset_token_expires_minutes()
    PasswordResetTokenModule.create(PasswordResetToken(
        account_id = account.id.value,
        token_hash = hash_token(raw_token),
        expires_at = timestamp + Dates.Minute(expires_minutes),
        created_at = timestamp,
        updated_at = timestamp,
    ))

    reset_url = build_reset_url(raw_token)
    body = build_password_reset_mail_body(
        "$(account.last_name) $(account.first_name)",
        reset_url,
        expires_minutes,
    )
    send_mail(to=email, subject="Password reset", body=body)
    return nothing
end
