module PasswordResetTokenModule

include("model.jl")

import Dates: now
import SearchLight
using .PasswordResetTokenModel

export PasswordResetToken,
    create,
    update,
    get_by_hash,
    find_latest_by_account_id,
    invalidate_active_tokens

const PasswordResetToken = PasswordResetTokenModel.PasswordResetToken

function create(token::PasswordResetToken)::PasswordResetToken
    SearchLight.save!(token)
    return token
end

function update(token::PasswordResetToken)::PasswordResetToken
    token.updated_at = now()
    SearchLight.save!(token)
    return token
end

function get_by_hash(token_hash::AbstractString)::Union{PasswordResetToken,Nothing}
    return SearchLight.findone(PasswordResetToken, token_hash=string(token_hash))
end

function find_latest_by_account_id(account_id::Int)::Union{PasswordResetToken,Nothing}
    tokens = SearchLight.find(PasswordResetToken, account_id=account_id)
    isempty(tokens) && return nothing
    return first(sort(tokens, by = token -> token.created_at, rev = true))
end

function invalidate_active_tokens(account_id::Int)::Nothing
    timestamp = now()
    tokens = SearchLight.find(PasswordResetToken, account_id=account_id)
    for token in tokens
        if isnothing(token.used_at) && token.expires_at > timestamp
            token.used_at = timestamp
            update(token)
        end
    end
    return nothing
end

end
