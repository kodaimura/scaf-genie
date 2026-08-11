module UsecaseHelper

using ScafGenie.Errors

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

end
