module HandlerValidation

using ScafGenie.Validations

export validate_signup,
    validate_login,
    validate_account,
    validate_update_account,
    validate_update_password

function validate_signup(request::Dict)
    validate_account(request)
end

function validate_login(request::Dict)
    validate_fields([
        req -> validate_require(req, "login_id"),
        req -> validate_require(req, "password"),
        req -> validate_max_length(req, "login_id", 255),
        req -> validate_max_length(req, "password", 255),
    ], request)
end

function validate_account(request::Dict)
    validate_fields([
        req -> validate_require(req, "first_name"),
        req -> validate_require(req, "last_name"),
        req -> validate_require(req, "password"),
        req -> validate_max_length(req, "login_id", 255),
        req -> validate_max_length(req, "email", 255),
        req -> validate_max_length(req, "first_name", 100),
        req -> validate_max_length(req, "last_name", 100),
        req -> validate_min_length(req, "password", 8),
        req -> validate_max_length(req, "password", 255),
    ], request)
end

function validate_update_account(request::Dict)
    validate_fields([
        req -> validate_require(req, "first_name"),
        req -> validate_require(req, "last_name"),
        req -> validate_max_length(req, "login_id", 255),
        req -> validate_max_length(req, "email", 255),
        req -> validate_max_length(req, "first_name", 100),
        req -> validate_max_length(req, "last_name", 100),
        req -> haskey(req, "password") && !isempty(string(req["password"])) ? validate_min_length(req, "password", 8) : [],
        req -> validate_max_length(req, "password", 255),
    ], request)
end

function validate_update_password(request::Dict)
    validate_fields([
        req -> validate_require(req, "old_password"),
        req -> validate_require(req, "new_password"),
        req -> validate_min_length(req, "new_password", 8),
        req -> validate_max_length(req, "new_password", 255),
    ], request)
end

end
