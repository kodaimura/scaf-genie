module Errors

export AppError,
    ExpectedError,
    UnexpectedError,
    BadRequestError,
    UnauthorizedError,
    ForbiddenError,
    NotFoundError,
    ConflictError,
    InternalServerError,
    ServiceUnavailableError

export get_code, get_message, get_details

abstract type AppError <: Exception end

abstract type ExpectedError <: AppError end
abstract type UnexpectedError <: AppError end

mutable struct BadRequestError <: ExpectedError
    code::Int
    message::String
    details::Vector{Pair{String,String}}
    BadRequestError(msg::String = "Bad Request"; details = Pair{String,String}[]) =
        new(400, msg, details)
end

mutable struct UnauthorizedError <: ExpectedError
    code::Int
    message::String
    UnauthorizedError(msg::String = "Unauthorized") = new(401, msg)
end

mutable struct ForbiddenError <: ExpectedError
    code::Int
    message::String
    ForbiddenError(msg::String = "Forbidden") = new(403, msg)
end

mutable struct NotFoundError <: ExpectedError
    code::Int
    message::String
    NotFoundError(msg::String = "Not Found") = new(404, msg)
end

mutable struct ConflictError <: ExpectedError
    code::Int
    message::String
    ConflictError(msg::String = "Conflict") = new(409, msg)
end

mutable struct InternalServerError <: UnexpectedError
    code::Int
    message::String
    InternalServerError(msg::String = "Internal Server Error") = new(500, msg)
end

mutable struct ServiceUnavailableError <: UnexpectedError
    code::Int
    message::String
    ServiceUnavailableError(msg::String = "Service Unavailable") = new(503, msg)
end

function get_code(e::Exception)
    if e isa AppError
        return e.code
    else
        return 500
    end
end

function get_message(e::Exception)
    if e isa AppError
        return e.message
    else
        return "Unknown error."
    end
end

function get_details(e::Exception)
    if e isa BadRequestError
        return e.details
    else
        return []
    end
end

end
