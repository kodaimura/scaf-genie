module Cors

import Genie
import Genie.Requests as Requests
import HTTP

using ..Config

export setup_cors!, preflight_response

const CORS_ALLOW_METHODS = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
const CORS_ALLOW_HEADERS = "Content-Type, Authorization"

function setup_cors!()::Nothing
    Genie.config.cors_allowed_origins = Config.frontend_origins()
    Genie.config.cors_headers["Access-Control-Allow-Origin"] = ""
    Genie.config.cors_headers["Access-Control-Expose-Headers"] = ""
    Genie.config.cors_headers["Access-Control-Allow-Methods"] = CORS_ALLOW_METHODS
    Genie.config.cors_headers["Access-Control-Allow-Headers"] = CORS_ALLOW_HEADERS
    Genie.config.cors_headers["Access-Control-Allow-Credentials"] = "true"
    Genie.config.cors_headers["Vary"] = "Origin"
    return nothing
end

function preflight_response()::HTTP.Response
    response = HTTP.Response(200, Genie.config.cors_headers, body="Success")
    origin = request_origin()
    allowed_origin = resolve_allowed_origin(origin)
    if !isnothing(allowed_origin)
        HTTP.setheader(response.headers, "Access-Control-Allow-Origin" => allowed_origin)
        HTTP.setheader(response.headers, "Vary" => "Origin")
    end
    return response
end

function request_origin()::Union{String,Nothing}
    for (key, value) in Requests.request().headers
        if lowercase(string(key)) == "origin"
            origin = strip(string(value))
            return isempty(origin) ? nothing : origin
        end
    end
    return nothing
end

function resolve_allowed_origin(origin::Union{String,Nothing})::Union{String,Nothing}
    isnothing(origin) && return nothing
    origins = Config.frontend_origins()
    origin in origins && return origin
    "*" in origins && return origin
    return nothing
end

end
