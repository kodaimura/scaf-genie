module PasswordResetTokenModule

include("model.jl")

import Dates: now
import SearchLight
using .PasswordResetTokenModel
using ScafGenie.Database

export PasswordResetToken,
    create,
    update,
    get_by_hash,
    mark_used_if_unused,
    find_latest_by_account_id,
    invalidate_active_tokens

const PasswordResetToken = PasswordResetTokenModel.PasswordResetToken

function create(token::PasswordResetToken)::PasswordResetToken
    Database.with_connection() do
        SearchLight.save!(token)
    end
    return token
end

function update(token::PasswordResetToken)::PasswordResetToken
    token.updated_at = now()
    Database.with_connection() do
        SearchLight.save!(token)
    end
    return token
end

function get_by_hash(token_hash::AbstractString)::Union{PasswordResetToken,Nothing}
    return Database.with_connection() do
        SearchLight.findone(PasswordResetToken, token_hash=string(token_hash))
    end
end

function mark_used_if_unused(token_hash::AbstractString)::Bool
    escaped_hash = SearchLight.escape_value(string(token_hash))
    result = Database.with_connection() do
        SearchLight.query("""
            UPDATE password_reset_token
            SET used_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
            WHERE token_hash = $escaped_hash AND used_at IS NULL
            RETURNING id
        """)
    end
    return !isempty(result)
end

function find_latest_by_account_id(account_id::Int)::Union{PasswordResetToken,Nothing}
    tokens = Database.with_connection() do
        SearchLight.find(PasswordResetToken, account_id=account_id)
    end
    isempty(tokens) && return nothing
    return first(sort(tokens, by = token -> token.created_at, rev = true))
end

function invalidate_active_tokens(account_id::Int)::Nothing
    timestamp = now()
    tokens = Database.with_connection() do
        SearchLight.find(PasswordResetToken, account_id=account_id)
    end
    for token in tokens
        if isnothing(token.used_at) && token.expires_at > timestamp
            token.used_at = timestamp
            update(token)
        end
    end
    return nothing
end

end
