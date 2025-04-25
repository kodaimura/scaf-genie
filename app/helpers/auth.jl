module Auth

import Genie.Requests as Requests
import Genie.Cookies as Cookies

using ..Jwt

export authenticated, is_authenticated

# Verifies the access token and returns user data if valid, or nothing if invalid.
function authenticated()::Union{Dict{String,Any},Nothing}
    token = get_access_token()
    isnothing(token) && return nothing
    try
        return Jwt.verify(token)
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

end