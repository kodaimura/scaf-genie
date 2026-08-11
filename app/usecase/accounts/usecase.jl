module AccountsUsecase

include("../../module/account/module.jl")
include("../helper.jl")

using .AccountModule
using .UsecaseHelper
using ScafGenie.Errors

export list,
    get,
    get_current,
    create,
    update,
    disable,
    enable

function list()::Vector{Account}
    return AccountModule.get_all()
end

function get(account_id::Int)::Account
    account = AccountModule.get_by_id(account_id)
    isnothing(account) && throw(NotFoundError("ACCOUNT_NOT_FOUND"))
    return account
end

function get_current(account_id::Int)::Account
    return get(account_id)
end

function create(input::Dict)::Account
    login_id = resolve_login_id(Base.get(input, "login_id", nothing), Base.get(input, "email", nothing))
    ensure_unique_login_id(login_id, 0)
    ensure_unique_email(Base.get(input, "email", nothing), 0)

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

function update(account_id::Int, input::Dict)::Account
    account = get(account_id)
    login_id = resolve_login_id(Base.get(input, "login_id", nothing), Base.get(input, "email", nothing))
    ensure_unique_login_id(login_id, account.id.value)
    ensure_unique_email(Base.get(input, "email", nothing), account.id.value)

    account.login_id = login_id
    account.email = Base.get(input, "email", nothing)
    account.first_name = input["first_name"]
    account.last_name = input["last_name"]
    if haskey(input, "password") && !isnothing(input["password"]) && !isempty(string(input["password"]))
        account.password_hash = UsecaseHelper.hash_password(input["password"])
        account.token_version += 1
    end

    return AccountModule.update(account)
end

function disable(account_id::Int)::Account
    return AccountModule.disable(get(account_id))
end

function enable(account_id::Int)::Account
    return AccountModule.enable(get(account_id))
end

function ensure_unique_login_id(login_id::String, except_id)::Nothing
    existing = AccountModule.get_by_login_id(login_id)
    if !isnothing(existing) && existing.id.value != except_id
        throw(ConflictError("LOGIN_ID_ALREADY_EXISTS"))
    end
    return nothing
end

function ensure_unique_email(email, except_id)::Nothing
    if isnothing(email) || isempty(strip(string(email)))
        return nothing
    end
    existing = AccountModule.get_by_email(string(email))
    if !isnothing(existing) && existing.id.value != except_id
        throw(ConflictError("EMAIL_ALREADY_EXISTS"))
    end
    return nothing
end

end
