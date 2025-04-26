module Jwt

import SHA: hmac_sha256
import Base64: base64encode, base64decode
import JSON
import Dates

export create_access_token, 
    create_refresh_token, 
    verify_access_token, 
    verify_refresh_token

# Generates a JWT token by encoding the header, payload, and secret key.
function create_access_token(payload::Dict{String,Any})::String
    expires_seconds = tryparse(Int, ENV["ACCESS_TOKEN_EXPIRES_SECONDS"])
    secret = ENV["ACCESS_TOKEN_SECRET"]
    return create_token(payload, secret, expires_seconds)
end

# Generates a JWT token by encoding the header, payload, and secret key.
function create_refresh_token(payload::Dict{String,Any})::String
    expires_seconds = tryparse(Int, ENV["REFRESH_TOKEN_EXPIRES_SECONDS"])
    secret = ENV["REFRESH_TOKEN_SECRET"]
    return create_token(payload, secret, expires_seconds)
end

function create_token(payload::Dict{String,Any}, secret::String, expires_seconds::Int)::String
    header = Dict("alg" => "HS256", "typ" => "JWT")
    if !haskey(payload, "exp")
        payload["exp"] = string(Dates.now() + Dates.Second(expires_seconds))
    end
    header_encoded = base64url_encode(Vector{UInt8}(codeunits(JSON.json(header))))
    payload_encoded = base64url_encode(Vector{UInt8}(codeunits(JSON.json(payload))))
    secret_key = Vector{UInt8}(codeunits(secret))
    signature = hmac_sha256(secret_key, "$header_encoded.$payload_encoded")
    signature_encoded = base64url_encode(signature)
    return "$header_encoded.$payload_encoded.$signature_encoded"
end

# Verifies a JWT token and returns the payload if valid, or nothing if invalid.
function verify_access_token(token::AbstractString)::Union{Dict{String,Any},Nothing}
    secret = ENV["ACCESS_TOKEN_SECRET"]
    return verify_token(token, secret)
end

# Verifies a JWT token and returns the payload if valid, or nothing if invalid.
function verify_refresh_token(token::AbstractString)::Union{Dict{String,Any},Nothing}
    secret = ENV["REFRESH_TOKEN_SECRET"]
    return verify_token(token, secret)
end

function verify_token(token::AbstractString, secret::String)::Union{Dict{String,Any},Nothing}
    parts = split(token, ".")
    if length(parts) != 3
        return nothing
    end

    header_encoded, payload_encoded, signature_encoded = parts

    try
        header = JSON.parse(String(base64url_decode(header_encoded)))
        if get(header, "alg", "") != "HS256"
            return nothing
        end

        secret_key = Vector{UInt8}(secret)
        expected_signature = hmac_sha256(secret_key, "$header_encoded.$payload_encoded")
        expected_signature_encoded = base64url_encode(expected_signature)
        if signature_encoded != expected_signature_encoded
            return nothing
        end

        payload = JSON.parse(String(base64url_decode(payload_encoded)))
        if haskey(payload, "exp")
            exp = payload["exp"]
            if Dates.now() > Dates.DateTime(exp)
                return nothing
            end
        end

        return payload
    catch e
        return nothing
    end
end

function base64url_encode(data::Vector{UInt8})::AbstractString
    return replace(base64encode(String(data)), r"\+" => "-", "/" => "_", "=" => "")
end

function base64url_decode(data::AbstractString)::Vector{UInt8}
    padded = data * repeat("=", (4 - length(data) % 4) % 4)
    return base64decode(replace(padded, "-" => "+", "_" => "/"))
end

end
