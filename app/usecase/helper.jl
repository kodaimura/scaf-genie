module UsecaseHelper

using ScafGenie.Errors
using ScafGenie.Config

function resolve_login_id(login_id, email)::String
    mode = Config.auth_login_id_mode()

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
