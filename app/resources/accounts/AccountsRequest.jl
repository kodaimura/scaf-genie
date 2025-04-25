module AccountsRequest

using ScafGenie.Validations

export validate_account_signup,
    validate_account_login

function validate_account_signup(request::Dict)
    rules = [
        req -> validate_require(req, "account_name"),
        req -> validate_require(req, "account_password"),
        req -> validate_min_length(req, "account_password", 8)
    ]
    validate_fields(rules, request)
end

function validate_account_login(request::Dict)
    rules = [
        req -> validate_require(req, "account_name"),
        req -> validate_require(req, "account_password")
    ]
    validate_fields(rules, request)
end

end