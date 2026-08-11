module AccountModel

import Dates: DateTime, now
import SearchLight: AbstractModel, DbId
import SearchLight
import Base: @kwdef

export Account, account_response

@kwdef mutable struct Account <: AbstractModel
    id::DbId = DbId()
    email::Union{Nothing,String} = nothing
    login_id::String = ""
    password_hash::String = ""
    token_version::Int = 1
    first_name::String = ""
    last_name::String = ""
    disabled_at::Union{Nothing,DateTime} = nothing
    deleted_at::Union{Nothing,DateTime} = nothing
    created_at::DateTime = now()
    updated_at::DateTime = now()
end

function SearchLight.Callbacks.on_find(account::Account, field::Symbol, value::String)
    setfield!(account, field, value)
    return account
end

function SearchLight.Callbacks.on_find(account::Account, field::Symbol, value::DateTime)
    setfield!(account, field, value)
    return account
end

function account_response(account::Account)::Dict{String,Any}
    return Dict(
        "id" => account.id.value,
        "email" => account.email,
        "login_id" => account.login_id,
        "first_name" => account.first_name,
        "last_name" => account.last_name,
        "disabled_at" => account.disabled_at,
        "created_at" => account.created_at,
        "updated_at" => account.updated_at,
    )
end

end
