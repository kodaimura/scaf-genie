module Responses

import Genie
using ..Errors

export json_success,
    json_fail,
    json_badrequest,
    json_unauthorized,
    json_forbidden,
    json_notfound,
    json_conflict,
    json_internal,
    json_unavailable,
    html_success,
    html_fail,
    redirect_login

# Returns a JSON response for successful operations.
# Allows optional status code and headers.
function json_success(data::Dict=Dict(); status=200, headers=nothing)
    if isnothing(headers)
        return Genie.Renderer.Json.json(data; status=status)
    end
    return Genie.Renderer.Json.json(data; status=status, headers=headers)
end

# Returns a JSON error response based on the given AppError.
# Optional overrides for status, message, and details.
function json_fail(e::AppError; status=nothing, message=nothing, details=nothing)
    status = isnothing(status) ? get_code(e) : status
    message = isnothing(message) ? get_message(e) : message
    details = isnothing(details) ? get_details(e) : details
    return Genie.Renderer.Json.json(
        Dict("message" => message, "details" => details);
        status=status,
    )
end

# Shortcut for 400 Bad Request
function json_badrequest(message::String = "Bad Request", details = Pair{String,String}[])
    json_fail(BadRequestError(message; details=details))
end

# Shortcut for 401 Unauthorized
function json_unauthorized(message::String = "Unauthorized")
    json_fail(UnauthorizedError(message))
end

# Shortcut for 403 Forbidden
function json_forbidden(message::String = "Forbidden")
    json_fail(ForbiddenError(message))
end

# Shortcut for 404 Not Found
function json_notfound(message::String = "Not Found")
    json_fail(NotFoundError(message))
end

# Shortcut for 409 Conflict
function json_conflict(message::String = "Conflict")
    json_fail(ConflictError(message))
end

# Shortcut for 500 Internal Server Error
function json_internal(message::String = "Internal Server Error")
    json_fail(InternalServerError(message))
end

# Shortcut for 503 Service Unavailable
function json_unavailable(message::String = "Service Unavailable")
    json_fail(ServiceUnavailableError(message))
end

# Returns an HTML success page based on the given template.
# Allows optional overrides for layout and additional variables.
function html_success(resources::Symbol, template::Symbol; layout::Union{Symbol,Nothing}=nothing, vars...)
    return Genie.Renderer.Html.html(resources, template; layout=layout, vars...)
end

# Returns an HTML error page based on the given AppError.
# Optional overrides for status, message, and details.
function html_fail(e::AppError; status=nothing, message=nothing)
    status = isnothing(status) ? get_code(e) : status
    message = isnothing(message) ? get_message(e) : message
    if status == 401
        return redirect_login()
    elseif status == 404
        return Genie.Renderer.Html.serve_error_file(status, message)
    else
        return Genie.Renderer.Html.serve_error_file(500, message)
    end
end

# Redirects to the login page (useful for unauthorized access handling)
function redirect_login()
    Genie.Renderer.redirect("login")
end

end