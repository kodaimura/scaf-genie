module Auth

import Genie.Requests as Requests
import Genie.Cookies as Cookies
import Genie.Response

using ..Jwt

export authenticated, 
    is_authenticated, 
    refreshable,
    is_refreshable,
    access_token_cookie_header,
    refresh_token_cookie_header

# Verifies the access token and returns user data if valid, or nothing if invalid.
function authenticated()::Union{Dict{String,Any},Nothing}
    token = get_access_token()
    isnothing(token) && return nothing
    try
        return Jwt.verify_access_token(token)
    catch e
        return nothing
    end
end

# Returns true if the user is authenticated, false otherwise.
function is_authenticated()::Bool
    return !isnothing(authenticated())
end

function get_access_token()::Union{String,Nothing}
    cookies = Cookies.getcookies(Requests.request())
    for cookie in cookies
        if cookie.name == "access_token"
            return cookie.value
        end
    end
    return nothing
end

# Verifies the refresh token and returns user data if valid, or nothing if invalid.
function refreshable()::Union{Dict{String,Any},Nothing}
    token = get_refresh_token()
    isnothing(token) && return nothing
    try
        return Jwt.verify_refresh_token(token)
    catch e
        return nothing
    end
end

# Returns true if the user is refreshable, false otherwise.
function is_refreshable()::Bool
    return !isnothing(refreshable())
end

function get_refresh_token()::Union{String,Nothing}
    cookies = Cookies.getcookies(Requests.request())
    for cookie in cookies
        if cookie.name == "refresh_token"
            return cookie.value
        end
    end
    return nothing
end

function access_token_cookie_header(access_token::String; options::String = "")::String
    secure = tryparse(Bool, get(ENV, "COOKIE_ACCESS_SECURE", "true")) ? "Secure" : ""
    httponly = tryparse(Bool, get(ENV, "COOKIE_ACCESS_HTTPONLY", "true")) ? "HttpOnly" : ""
    return "access_token=$access_token; Path=/; $secure; $httponly; SameSite=Lax; $options"
end

function refresh_token_cookie_header(refresh_token::String; options::String = "")::String
    secure = tryparse(Bool, get(ENV, "COOKIE_REFRESH_SECURE", "true")) ? "Secure" : ""
    httponly = tryparse(Bool, get(ENV, "COOKIE_REFRESH_HTTPONLY", "true")) ? "HttpOnly" : ""
    return "refresh_token=$refresh_token; Path=/; $secure; $httponly; SameSite=Lax; $options"
end

end