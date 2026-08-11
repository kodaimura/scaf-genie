module UsecaseHelper

using ScafGenie.Errors
import SHA
import Random
import Base64

export resolve_login_id,
    hash_password,
    verify_password,
    generate_token,
    hash_token

function resolve_login_id(login_id, email)::String
    mode = lowercase(strip(Base.get(ENV, "AUTH_LOGIN_ID_MODE", "email")))

    if mode == "email"
        if isnothing(email) || isempty(strip(string(email)))
            throw(BadRequestError("EMAIL_REQUIRED"))
        end
        return strip(string(email))
    end

    if mode == "login_id"
        if isnothing(login_id) || isempty(strip(string(login_id)))
            throw(BadRequestError("LOGIN_ID_REQUIRED"))
        end
        return strip(string(login_id))
    end

    throw(BadRequestError("INVALID_STATE"))
end

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
