module Responses

import Genie
import HTTP
using ..Errors

export json_success,
    json_no_content,
    json_fail,
    json_badrequest,
    json_unauthorized,
    json_forbidden,
    json_notfound,
    json_conflict,
    json_internal,
    json_unavailable

# Returns a JSON response for successful operations.
# Allows optional status code and headers.
function json_success(data::Dict=Dict(); status=200, headers=nothing)
    if isnothing(headers)
        return Genie.Renderer.Json.json(data; status=status)
    end
    return Genie.Renderer.Json.json(data; status=status, headers=headers)
end

function json_no_content(; headers=nothing)
    if isnothing(headers)
        return HTTP.Response(204)
    end
    return HTTP.Response(204, headers)
end

# Returns a JSON error response based on the given AppError.
# Optional overrides for status, message, and details.
function json_fail(e::AppError; status=nothing, message=nothing, details=nothing)
    status = isnothing(status) ? get_code(e) : status
    message = isnothing(message) ? get_message(e) : message
    details = isnothing(details) ? get_details(e) : details
    if e isa ValidationError
        return Genie.Renderer.Json.json(
            Dict("message" => message, "errors" => details);
            status=status,
        )
    end
    if e isa UnexpectedError
        return Genie.Renderer.Json.json(
            Dict("message" => "Internal server error");
            status=status,
        )
    end
    data = Dict{String,Any}("code" => message)
    if !isempty(details)
        data["details"] = details
    end
    return Genie.Renderer.Json.json(
        data;
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

end
