module Auth

import Genie.Requests as Requests
import Genie.Cookies as Cookies
import Genie.Response

using ..Jwt

export authenticated, 
    is_authenticated, 
    refreshable,
    is_refreshable,
    refresh_token_cookie_header,
    delete_refresh_token_cookie_header

# Verifies the access token and returns user data if valid, or nothing if invalid.
function authenticated()::Union{Dict{String,Any},Nothing}
    token = get_bearer_token()
    isnothing(token) && return nothing
    try
        payload = Jwt.verify_access_token(token)
        if isnothing(payload) || Base.get(payload, "type", "") != "access"
            return nothing
        end
        return payload
    catch e
        return nothing
    end
end

# Returns true if the user is authenticated, false otherwise.
function is_authenticated()::Bool
    return !isnothing(authenticated())
end

# Verifies the refresh token and returns user data if valid, or nothing if invalid.
function refreshable()::Union{Dict{String,Any},Nothing}
    token = get_cookie("refresh_token")
    isnothing(token) && return nothing
    try
        payload = Jwt.verify_refresh_token(token)
        if isnothing(payload) || Base.get(payload, "type", "") != "refresh"
            return nothing
        end
        return payload
    catch e
        return nothing
    end
end

# Returns true if the user is refreshable, false otherwise.
function is_refreshable()::Bool
    return !isnothing(refreshable())
end

function refresh_token_cookie_header(refresh_token::String; options::String = "")::String
    parts = [
        "refresh_token=$refresh_token",
        "Path=/",
        "HttpOnly",
        "SameSite=Lax",
    ]
    if Base.get(ENV, "APP_ENV", "dev") == "production"
        push!(parts, "Secure")
    end
    if !isempty(strip(options))
        push!(parts, strip(options))
    end
    return join(parts, "; ")
end

function delete_refresh_token_cookie_header()::String
    return refresh_token_cookie_header("", options="Max-Age=0")
end

function get_bearer_token()
    authorization = nothing
    for (key, value) in Requests.request().headers
        if lowercase(string(key)) == "authorization"
            authorization = string(value)
            break
        end
    end

    isnothing(authorization) && return nothing
    prefix = "Bearer "
    startswith(authorization, prefix) || return nothing
    return strip(authorization[length(prefix)+1:end])
end

function get_cookie(key::String)
    cookies = Cookies.getcookies(Requests.request())
    for cookie in cookies
        if cookie.name == key
            return cookie.value
        end
    end
    return nothing
end

end
