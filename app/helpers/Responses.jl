module Responses

import Genie
using ScafGenie.Errors

export json_success, json_fail

function json_success(data::Dict = Dict(); status = 200, headers = nothing)
    if isnothing(headers)
        return Genie.Renderer.Json.json(data; status = status)
    end
    return Genie.Renderer.Json.json(data; status = status, headers = headers)
end

function json_fail(e::Exception; status = nothing, message = nothing, details = nothing)
    status = isnothing(status) ? get_code(e) : status
    message = isnothing(message) ? get_message(e) : message
    details = isnothing(details) ? get_details(e) : details
    return Genie.Renderer.Json.json(
        Dict("message" => message, "details" => details);
        status = status,
    )
end

end