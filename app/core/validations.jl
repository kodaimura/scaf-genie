module Validations

import ..Errors: ValidationError

export validate_require,
    validate_min_length,
    validate_max_length,
    validate_email_format,
    validate_matches_regex,
    validate_numeric,
    validate_integer,
    validate_positive,
    validate_in_set,
    validate_equals,
    validate_not_equals,
    validate_fields

function validate_require(request::Dict, field::String)
    value = Base.get(request, field, nothing)
    (isnothing(value) || isempty(strip(string(value)))) ? [(field => "is required")] : []
end

function validate_min_length(request::Dict, field::String, min::Int)
    raw = Base.get(request, field, nothing)
    isnothing(raw) && return []
    value = string(raw)
    isempty(value) && return []
    length(value) < min ? [(field => "must be at least $min characters")] : []
end

function validate_max_length(request::Dict, field::String, max::Int)
    raw = Base.get(request, field, nothing)
    isnothing(raw) && return []
    value = string(raw)
    isempty(value) && return []
    length(value) > max ? [(field => "must be at most $max characters")] : []
end

function validate_email_format(request::Dict, field::String)
    raw = Base.get(request, field, nothing)
    isnothing(raw) && return []
    value = string(raw)
    isempty(value) && return []
    pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
    !occursin(pattern, value) ? [(field => "must be a valid email")] : []
end

function validate_matches_regex(request::Dict, field::String, pattern::Regex)
    value = Base.get(request, field, "")
    !occursin(pattern, value) ? [(field => "has invalid format")] : []
end

function validate_numeric(request::Dict, field::String)
    value = Base.get(request, field, "")
    try
        parse(Float64, value)
        return []
    catch
        return [(field => "must be a number")]
    end
end

function validate_integer(request::Dict, field::String)
    value = Base.get(request, field, "")
    try
        parse(Int, value)
        return []
    catch
        return [(field => "must be an integer")]
    end
end

function validate_positive(request::Dict, field::String)
    value = Base.get(request, field, 0)
    try
        parsed = parse(Float64, value)
        parsed <= 0 ? [(field => "must be positive")] : []
    catch
        return [(field => "must be a positive number")]
    end

end

function validate_in_set(request::Dict, field::String, allowed::Vector)
    value = Base.get(request, field, "")
    !(value in allowed) ? [(field => "must be one of: $(join(allowed, ", "))")] : []
end

function validate_equals(request::Dict, field::String, expected)
    value = Base.get(request, field, "")
    value != expected ? [(field => "must be equal to $expected")] : []
end

function validate_not_equals(request::Dict, field::String, unexpected)
    value = Base.get(request, field, "")
    value == unexpected ? [(field => "must not be $unexpected")] : []
end

function validate_fields(validators::Vector{Function}, request::Dict)
    errors = Pair{String,String}[]
    for validator in validators
        append!(errors, validator(request))
    end
    if !isempty(errors)
        details = [Dict{String,Any}("field" => error.first, "message" => error.second) for error in errors]
        throw(ValidationError(; details=details))
    end
end

end
