module AccountsRequest

using ScafGenie.Validations

export validate_signup,
    validate_login

function validate_signup(request::Dict)
    rules = [
        req -> validate_require(req, "name"),
        req -> validate_require(req, "password"),
        req -> validate_min_length(req, "password", 8)
    ]
    validate_fields(rules, request)
end

function validate_login(request::Dict)
    rules = [
        req -> validate_require(req, "name"),
        req -> validate_require(req, "password")
    ]
    validate_fields(rules, request)
end

end