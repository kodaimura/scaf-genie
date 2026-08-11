module Crypto

import Base64
import Random
import SHA

export hash_password,
    verify_password,
    generate_token,
    hash_token

function hash_password(password::String)::String
    iterations = 210_000
    salt = Random.rand(UInt8, 16)
    derived = pbkdf2_sha256(Vector{UInt8}(codeunits(password)), salt, iterations, 32)
    return join([
        "pbkdf2_sha256",
        string(iterations),
        base64url_encode(salt),
        base64url_encode(derived),
    ], "\$")
end

function verify_password(plain::String, hashed::String)::Bool
    if startswith(hashed, "pbkdf2_sha256\$")
        parts = split(hashed, "\$")
        length(parts) == 4 || return false
        iterations = tryparse(Int, parts[2])
        isnothing(iterations) && return false
        salt = base64url_decode(parts[3])
        expected = base64url_decode(parts[4])
        actual = pbkdf2_sha256(Vector{UInt8}(codeunits(plain)), salt, iterations, length(expected))
        return constant_time_equals(actual, expected)
    end
    return constant_time_equals(Vector{UInt8}(codeunits(bytes2hex(SHA.sha256(plain)))), Vector{UInt8}(codeunits(hashed)))
end

function generate_token(byte_length::Int = 48)::String
    raw = Random.rand(UInt8, byte_length)
    return replace(Base64.base64encode(raw), "+" => "-", "/" => "_", "=" => "")
end

function hash_token(token::String)::String
    return bytes2hex(SHA.sha256(token))
end

function pbkdf2_sha256(password::Vector{UInt8}, salt::Vector{UInt8}, iterations::Int, key_length::Int)::Vector{UInt8}
    iterations > 0 || error("iterations must be positive")
    blocks = ceil(Int, key_length / 32)
    derived = UInt8[]
    for block_index in 1:blocks
        block = vcat(salt, UInt8[
            (block_index >> 24) & 0xff,
            (block_index >> 16) & 0xff,
            (block_index >> 8) & 0xff,
            block_index & 0xff,
        ])
        u = SHA.hmac_sha256(password, block)
        t = copy(u)
        for _ in 2:iterations
            u = SHA.hmac_sha256(password, u)
            for i in eachindex(t)
                t[i] = xor(t[i], u[i])
            end
        end
        append!(derived, t)
    end
    return derived[1:key_length]
end

function constant_time_equals(a::Vector{UInt8}, b::Vector{UInt8})::Bool
    length(a) == length(b) || return false
    diff = UInt8(0)
    for i in eachindex(a)
        diff |= xor(a[i], b[i])
    end
    return diff == 0
end

function base64url_encode(data::Vector{UInt8})::String
    return replace(Base64.base64encode(data), "+" => "-", "/" => "_", "=" => "")
end

function base64url_decode(data::AbstractString)::Vector{UInt8}
    padded = data * repeat("=", (4 - length(data) % 4) % 4)
    return Base64.base64decode(replace(padded, "-" => "+", "_" => "/"))
end

end
