module AccountModule

include("model.jl")

import Dates: now
import SearchLight
using .AccountModel
using ScafGenie.Database

export Account,
    account_response,
    create,
    update,
    get_all,
    get_by_id,
    get_by_email,
    get_by_login_id,
    disable,
    enable

const Account = AccountModel.Account
const account_response = AccountModel.account_response

function create(account::Account)::Account
    Database.with_connection() do
        SearchLight.save!(account)
    end
    return account
end

function update(account::Account)::Account
    account.updated_at = now()
    Database.with_connection() do
        SearchLight.save!(account)
    end
    return account
end

function get_all()::Vector{Account}
    accounts = Database.with_connection() do
        SearchLight.find(Account)
    end
    return sort(
        filter(account -> isnothing(account.deleted_at), accounts),
        by = account -> account.id.value,
    )
end

function get_by_id(account_id)::Union{Account,Nothing}
    account = Database.with_connection() do
        SearchLight.findone(Account, id=account_id)
    end
    if isnothing(account) || !isnothing(account.deleted_at)
        return nothing
    end
    return account
end

function get_by_email(email::AbstractString)::Union{Account,Nothing}
    account = Database.with_connection() do
        SearchLight.findone(Account, email=string(email))
    end
    if isnothing(account) || !isnothing(account.deleted_at)
        return nothing
    end
    return account
end

function get_by_login_id(login_id::AbstractString)::Union{Account,Nothing}
    account = Database.with_connection() do
        SearchLight.findone(Account, login_id=string(login_id))
    end
    if isnothing(account) || !isnothing(account.deleted_at)
        return nothing
    end
    return account
end

function disable(account::Account)::Account
    account.disabled_at = now()
    account.token_version += 1
    return update(account)
end

function enable(account::Account)::Account
    account.disabled_at = nothing
    return update(account)
end

end
