module AccountsDto

using ScafGenie.Validations

struct AccountRequest
    login_id::Union{Nothing,String}
    email::Union{Nothing,String}
    password::String
    first_name::String
    last_name::String
end

struct UpdateAccountRequest
    login_id::Union{Nothing,String}
    email::Union{Nothing,String}
    password::Union{Nothing,String}
    first_name::String
    last_name::String
end

function account_request(payload::Dict)::AccountRequest
    validate_account(payload)
    return AccountRequest(
        optional_string(payload, "login_id"),
        optional_string(payload, "email"),
        string(payload["password"]),
        string(payload["first_name"]),
        string(payload["last_name"]),
    )
end

function update_account_request(payload::Dict)::UpdateAccountRequest
    validate_update_account(payload)
    return UpdateAccountRequest(
        optional_string(payload, "login_id"),
        optional_string(payload, "email"),
        optional_string(payload, "password"),
        string(payload["first_name"]),
        string(payload["last_name"]),
    )
end

function validate_account(request::Dict)
    validate_fields([
        req -> validate_require(req, "first_name"),
        req -> validate_require(req, "last_name"),
        req -> validate_require(req, "password"),
        req -> validate_max_length(req, "login_id", 255),
        req -> validate_max_length(req, "email", 255),
        req -> validate_email_format(req, "email"),
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
        req -> validate_email_format(req, "email"),
        req -> validate_max_length(req, "first_name", 100),
        req -> validate_max_length(req, "last_name", 100),
        req -> haskey(req, "password") && !isempty(string(req["password"])) ? validate_min_length(req, "password", 8) : [],
        req -> validate_max_length(req, "password", 255),
    ], request)
end

function account_response(account)::Dict{String,Any}
    return Dict(
        "id" => account.id.value,
        "email" => account.email,
        "login_id" => account.login_id,
        "first_name" => account.first_name,
        "last_name" => account.last_name,
        "disabled_at" => account.disabled_at,
        "created_at" => account.created_at,
        "updated_at" => account.updated_at,
    )
end

function accounts_response(accounts)::Dict{String,Any}
    return Dict("accounts" => [account_response(account) for account in accounts])
end

function account_payload(account)::Dict{String,Any}
    return Dict("account" => account_response(account))
end

function optional_string(payload::Dict, key::String)::Union{Nothing,String}
    value = Base.get(payload, key, nothing)
    isnothing(value) && return nothing
    text = strip(string(value))
    return isempty(text) ? nothing : text
end

end
