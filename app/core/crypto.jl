module Crypto

import Base64
import Random
import SHA

export hash_password,
    verify_password,
    generate_token,
    hash_token

function hash_password(password::String)::String
    return bytes2hex(SHA.sha256(password))
end

function verify_password(plain::String, hashed::String)::Bool
    return hash_password(plain) == hashed
end

function generate_token(byte_length::Int = 48)::String
    raw = Random.rand(UInt8, byte_length)
    return replace(Base64.base64encode(raw), "+" => "-", "/" => "_", "=" => "")
end

function hash_token(token::String)::String
    return bytes2hex(SHA.sha256(token))
end

end
