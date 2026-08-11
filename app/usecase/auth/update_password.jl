function update_password(account_id::Int, target_account_id::String, input::Dict)::Nothing
    target_account_id == "me" || throw(BadRequestError("INVALID_STATE"))
    UsecaseValidation.validate_update_password(input)

    account = AccountModule.get_by_id(account_id)
    isnothing(account) && throw(NotFoundError("ACCOUNT_NOT_FOUND"))

    if !UsecaseHelper.verify_password(input["old_password"], account.password_hash)
        throw(UnauthorizedError("CURRENT_PASSWORD_INCORRECT"))
    end

    account.password_hash = UsecaseHelper.hash_password(input["new_password"])
    account.token_version += 1
    AccountModule.update(account)
    return nothing
end
