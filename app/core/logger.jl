module Logger

import Dates
import JSON
import Logging

using ..Config

export JSONLogger

struct JSONLogger <: Logging.AbstractLogger
    min_level::Logging.LogLevel
end

JSONLogger() = JSONLogger(Config.log_level())

Logging.min_enabled_level(logger::JSONLogger) = logger.min_level
Logging.shouldlog(logger::JSONLogger, level, _module, group, id) = level >= logger.min_level
Logging.catch_exceptions(::JSONLogger) = false

function Logging.handle_message(logger::JSONLogger, level, message, _module, group, id, file, line; kwargs...)
    data = Dict{String,Any}(
        "timestamp" => string(Dates.now(Dates.UTC)),
        "level" => uppercase(string(level)),
        "logger" => string(_module),
        "message" => string(message),
    )
    if file !== nothing
        data["file"] = string(file)
    end
    if line !== nothing
        data["line"] = line
    end
    for (key, value) in kwargs
        data[string(key)] = value
    end
    println(stdout, JSON.json(data))
    flush(stdout)
    return nothing
end

end
