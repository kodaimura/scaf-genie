module PasswordResetTokenModel

import Dates: DateTime, now
import SearchLight: AbstractModel, DbId
import SearchLight
import TimeZones: ZonedDateTime
import Base: @kwdef

export PasswordResetToken

@kwdef mutable struct PasswordResetToken <: AbstractModel
    id::DbId = DbId()
    account_id::Int = 0
    token_hash::String = ""
    expires_at::DateTime = now()
    used_at::Union{Nothing,DateTime} = nothing
    created_at::DateTime = now()
    updated_at::DateTime = now()
end

SearchLight.table(::Type{PasswordResetToken}) = "password_reset_token"

function SearchLight.Callbacks.on_find(token::PasswordResetToken, field::Symbol, value::String)
    setfield!(token, field, value)
    return token
end

function SearchLight.Callbacks.on_find(token::PasswordResetToken, field::Symbol, value::DateTime)
    setfield!(token, field, value)
    return token
end

function SearchLight.Callbacks.on_find(token::PasswordResetToken, field::Symbol, value::ZonedDateTime)
    setfield!(token, field, DateTime(value))
    return token
end

end
