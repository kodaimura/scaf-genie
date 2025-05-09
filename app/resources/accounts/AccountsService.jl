module AccountsService

include("Accounts.jl")

using SearchLight
import SHA
import Base64
import Dates

import .Accounts: Account
using ScafGenie.Errors

export signup, login

function signup(name::String, password::String)
    account = SearchLight.findone(Account, name=name)
    if !isnothing(account)
        throw(ConflictError())
    end
    account = Account(
        name=name,
        password=hash_password(password),
    )
    SearchLight.save!(account)
end

function login(name::String, password::String)::Account
    account = SearchLight.findone(Account, name=name)
    if isnothing(account)
        throw(UnauthorizedError())
    end
    if hash_password(password) != account.password
        throw(UnauthorizedError())
    end
    return account
end

function hash_password(password::String)
    return Base64.base64encode(SHA.sha256(password))
end

end
