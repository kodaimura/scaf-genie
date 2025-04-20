module Jwt

import SHA: hmac_sha256
import Base64: base64encode, base64decode
import JSON
import Dates
using Logging

export create, decode_payload, verify

function base64url_encode(data::Vector{UInt8})::AbstractString
    return replace(base64encode(String(data)), r"\+" => "-", "/" => "_", "=" => "")
end

function base64url_decode(data::AbstractString)::Vector{UInt8}
    padded = data * repeat("=", (4 - length(data) % 4) % 4)
    return base64decode(replace(padded, "-" => "+", "_" => "/"))
end

function create(payload::Dict{String, Any})::String
    header = Dict("alg" => "HS256", "typ" => "JWT")
    if !haskey(payload, "exp")
        exp_seconds = tryparse(Int, get(ENV, "AUTH_EXPIRES_SECONDS", "3600"))
        exp_seconds = isnothing(exp_seconds) ? 3600 : exp_seconds
        payload["exp"] = string(Dates.now() + Dates.Second(exp_seconds))
    end

    header_encoded = base64url_encode(Vector{UInt8}(codeunits(JSON.json(header))))
    payload_encoded = base64url_encode(Vector{UInt8}(codeunits(JSON.json(payload))))
    secret_key = Vector{UInt8}(codeunits(ENV["JWT_SECRET"]))
    signature = hmac_sha256(secret_key, "$header_encoded.$payload_encoded")
    signature_encoded = base64url_encode(signature)
    return "$header_encoded.$payload_encoded.$signature_encoded"
end

function decode_payload(token::AbstractString)::Union{Dict{String, Any}, Nothing}
    parts = split(token, ".")
    if length(parts) != 3
        return nothing
    end
    _, payload_encoded, _ = parts
    try
        payload = JSON.parse(String(base64url_decode(payload_encoded)))
        return payload
    catch e
        @warn "Failed to decode JWT payload: $e"
        return nothing
    end
end

function verify(token::AbstractString)::Bool
    parts = split(token, ".")
    if length(parts) != 3
        return false
    end

    header_encoded, payload_encoded, signature_encoded = parts

    try
        header = JSON.parse(String(base64url_decode(header_encoded)))
        if get(header, "alg", "") != "HS256"
            return false
        end

        secret_key = Vector{UInt8}(ENV["JWT_SECRET"])
        expected_signature = hmac_sha256(secret_key, "$header_encoded.$payload_encoded")
        expected_signature_encoded = base64url_encode(expected_signature)
        if signature_encoded != expected_signature_encoded
            return false
        end

        payload = JSON.parse(String(base64url_decode(payload_encoded)))
        if haskey(payload, "exp")
            exp = payload["exp"]
            if Dates.now() > Dates.DateTime(exp)
                return false
            end
        end

        return true
    catch e
        @error "JWT verification error: $e"
        return false
    end
end

end
