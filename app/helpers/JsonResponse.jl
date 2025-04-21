module JsonResponse

import Genie.Renderer.Json

function success(data::Dict=Dict(); status=200, headers=nothing)
    if isnothing(headers)
        return Genie.Renderer.Json.json(data; status=status)
    end
    return Genie.Renderer.Json.json(data; status=status, headers=headers)
end

function fail(e::Exception; status=nothing, message=nothing, details=nothing)
    status = isnothing(status) ? get_code(e) : status
    message = isnothing(message) ? get_message(e) : message
    details = isnothing(details) ? get_details(e) : details
    return Genie.Renderer.Json.json(Dict("message" => message, "details" => details); status=status)
end

end