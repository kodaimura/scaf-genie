module Validation

export require_keys,
       validate_not_empty,
       validate_min_length,
       validate_max_length,
       validate_email_format,
       validate_matches_regex,
       validate_numeric,
       validate_integer,
       validate_positive,
       validate_in_set,
       validate_equals,
       validate_not_equals

function require_keys(request::Dict, keys::Vector{String})
    missing = [k for k in keys if !haskey(request, k)]
    !isempty(missing) && throw(BadRequestError("Missing keys: $(join(missing, ", "))"))
end

function validate_not_empty(value::String, field::String)
    isempty(strip(value)) && throw(BadRequestError("$field must not be empty"))
end

function validate_min_length(value::String, field::String, min::Int)
    length(value) < min && throw(BadRequestError("$field must be at least $min characters"))
end

function validate_max_length(value::String, field::String, max::Int)
    length(value) > max && throw(BadRequestError("$field must be at most $max characters"))
end

function validate_email_format(value::String, field::String)
    pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
    !ismatch(pattern, value) && throw(BadRequestError("$field must be a valid email"))
end

function validate_matches_regex(value::String, field::String, pattern::Regex)
    !ismatch(pattern, value) && throw(BadRequestError("$field has invalid format"))
end

function validate_numeric(value::String, field::String)
    try
        parse(Float64, value)
    catch
        throw(BadRequestError("$field must be a number"))
    end
end

function validate_integer(value::String, field::String)
    try
        parse(Int, value)
    catch
        throw(BadRequestError("$field must be an integer"))
    end
end

function validate_positive(value::Number, field::String)
    value <= 0 && throw(BadRequestError("$field must be positive"))
end

function validate_in_set(value, field::String, allowed::Vector)
    !(value in allowed) && throw(BadRequestError("$field must be one of: $(join(allowed, ", "))"))
end

function validate_equals(value, field::String, expected)
    value != expected && throw(BadRequestError("$field must be equal to $expected"))
end

function validate_not_equals(value, field::String, unexpected)
    value == unexpected && throw(BadRequestError("$field must not be $unexpected"))
end

end
