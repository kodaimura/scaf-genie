module Auth

import Genie.Requests as Requests
import Genie.Cookies as Cookies

using ..Jwt

export authenticated, is_authenticated

function authenticated()::Union{Dict{String,Any},Nothing}
    token = get_access_token()
    isnothing(token) && return nothing
    try
        return Jwt.verify(token)
    catch e
        return nothing
    end
end

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