module Validations

import ..Errors: BadRequestError

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
    (!haskey(request, field) || isempty(request[field])) ? (key => "is required") : []
end

function validate_min_length(request::Dict, field::String, min::Int)
    value = get(request, field, "")
    length(value) < min ? [(field => "must be at least $min characters")] : []
end

function validate_max_length(request::Dict, field::String, max::Int)
    value = get(request, field, "")
    length(value) > max ? [(field => "must be at most $max characters")] : []
end

function validate_email_format(request::Dict, field::String)
    value = get(request, field, "")
    pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
    !ismatch(pattern, value) ? [(field => "must be a valid email")] : []
end

function validate_matches_regex(request::Dict, field::String, pattern::Regex)
    value = get(request, field, "")
    !ismatch(pattern, value) ? [(field => "has invalid format")] : []
end

function validate_numeric(request::Dict, field::String)
    value = get(request, field, "")
    try
        parse(Float64, value)
        return []
    catch
        return [(field => "must be a number")]
    end
end

function validate_integer(request::Dict, field::String)
    value = get(request, field, "")
    try
        parse(Int, value)
        return []
    catch
        return [(field => "must be an integer")]
    end
end

function validate_positive(request::Dict, field::String)
    value = get(request, field, 0)
    try
        parsed = parse(Float64, value)
        parsed <= 0 ? [(field => "must be positive")] : []
    catch
        return [(field => "must be a positive number")]
    end

end

function validate_in_set(request::Dict, field::String, allowed::Vector)
    value = get(request, field, "")
    !(value in allowed) ? [(field => "must be one of: $(join(allowed, ", "))")] : []
end

function validate_equals(request::Dict, field::String, expected)
    value = get(request, field, "")
    value != expected ? [(field => "must be equal to $expected")] : []
end

function validate_not_equals(request::Dict, field::String, unexpected)
    value = get(request, field, "")
    value == unexpected ? [(field => "must not be $unexpected")] : []
end

function validate_fields(validators::Vector{Function}, request::Dict)
    errors = Pair{String,String}[]
    for validator in validators
        append!(errors, validator(request))
    end
    if !isempty(errors)
        throw(BadRequestError(; details=errors))
    end
end

end
