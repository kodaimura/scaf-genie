module AccountsService

include("Accounts.jl")

using SearchLight
import SHA
import Base64
import Dates

import .Accounts: Account
using ScafGenie.Errors

export signup, login

function signup(account_name::String, account_password::String)
    account = SearchLight.findone(Account, account_name=account_name)
    if !isnothing(account)
        throw(ConflictError())
    end
    account = Account(
        account_name=account_name,
        account_password=hash_password(account_password),
    )
    SearchLight.save!(account)
end

function login(account_name::String, account_password::String)::Account
    account = SearchLight.findone(Account, account_name=account_name)
    if isnothing(account)
        throw(UnauthorizedError())
    end
    if hash_password(account_password) != account.account_password
        throw(UnauthorizedError())
    end
    return account
end

function hash_password(password::String)
    return Base64.base64encode(SHA.sha256(password))
end

end
