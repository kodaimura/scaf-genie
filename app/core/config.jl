module Config

import HTTP
import Logging

export app_env,
    genie_env,
    log_level,
    enable_signup,
    auth_login_id_mode,
    frontend_origins,
    database_settings,
    access_token_secret,
    access_token_expires_seconds,
    refresh_token_secret,
    refresh_token_expires_seconds,
    refresh_token_remember_me_expires_seconds,
    password_reset_url_base,
    password_reset_token_expires_minutes,
    password_reset_resend_interval_minutes,
    mail_provider,
    mail_from,
    smtp_host,
    smtp_port,
    smtp_username,
    smtp_password,
    smtp_use_tls,
    validate_config!

function env_string(key::String, default::String = "")::String
    return strip(Base.get(ENV, key, default))
end

function env_lower(key::String, default::String)::String
    return lowercase(env_string(key, default))
end

function env_bool(key::String, default::Bool)::Bool
    value = env_lower(key, string(default))
    if value in ["true", "1", "yes", "on"]
        return true
    end
    if value in ["false", "0", "no", "off"]
        return false
    end
    error("$key must be a boolean")
end

function env_int(key::String, default::Int)::Int
    value = env_string(key, string(default))
    parsed = tryparse(Int, value)
    isnothing(parsed) && error("$key must be an integer")
    return parsed
end

function app_env()::String
    return env_lower("APP_ENV", "dev")
end

function genie_env()::String
    return env_lower("GENIE_ENV", app_env() == "production" ? "prod" : app_env())
end

function log_level()::Logging.LogLevel
    value = env_lower("LOG_LEVEL", "info")
    value == "debug" && return Logging.Debug
    value == "info" && return Logging.Info
    value == "warn" && return Logging.Warn
    value == "error" && return Logging.Error
    error("LOG_LEVEL must be one of: debug, info, warn, error")
end

enable_signup()::Bool = env_bool("ENABLE_SIGNUP", true)
auth_login_id_mode()::String = env_lower("AUTH_LOGIN_ID_MODE", "email")

function frontend_origins()::Vector{String}
    origins = [strip(origin) for origin in split(env_string("FRONTEND_ORIGINS", "http://localhost:3000,http://localhost:5173"), ",")]
    return filter(!isempty, origins)
end

function database_url()::String
    default = "postgresql://$(env_string("POSTGRES_USER", "postgres")):$(env_string("POSTGRES_PASSWORD", "postgres"))@db:5432/$(env_string("POSTGRES_DB", "project_db"))?sslmode=disable"
    return env_string("DATABASE_URL", default)
end

function database_settings()::Dict{String,Any}
    uri = HTTP.URI(database_url())
    if !(uri.scheme in ["postgresql", "postgres"])
        error("DATABASE_URL must use postgresql://")
    end

    userinfo = split(string(uri.userinfo), ":", limit=2)
    username = isempty(userinfo) ? "" : HTTP.URIs.unescapeuri(userinfo[1])
    password = length(userinfo) < 2 ? "" : HTTP.URIs.unescapeuri(userinfo[2])
    database = HTTP.URIs.unescapeuri(lstrip(string(uri.path), '/'))
    port = isnothing(uri.port) ? 5432 : uri.port

    isempty(uri.host) && error("DATABASE_URL host is required")
    isempty(database) && error("DATABASE_URL database is required")
    isempty(username) && error("DATABASE_URL username is required")

    return Dict{String,Any}(
        "adapter" => "PostgreSQL",
        "host" => string(uri.host),
        "port" => port,
        "database" => database,
        "username" => username,
        "password" => password,
        "config" => Dict{String,Any}(),
        "options" => Dict{String,String}(),
    )
end

access_token_secret()::String = env_string("ACCESS_TOKEN_SECRET", "randomstring")
access_token_expires_seconds()::Int = env_int("ACCESS_TOKEN_EXPIRES_SECONDS", 900)
refresh_token_secret()::String = env_string("REFRESH_TOKEN_SECRET", "randomstring")
refresh_token_expires_seconds()::Int = env_int("REFRESH_TOKEN_EXPIRES_SECONDS", 43200)
refresh_token_remember_me_expires_seconds()::Int = env_int("REFRESH_TOKEN_REMEMBER_ME_EXPIRES_SECONDS", 2592000)

password_reset_url_base()::String = env_string("PASSWORD_RESET_URL_BASE", "http://localhost:3000/reset-password")
password_reset_token_expires_minutes()::Int = env_int("PASSWORD_RESET_TOKEN_EXPIRES_MINUTES", 30)
password_reset_resend_interval_minutes()::Int = env_int("PASSWORD_RESET_RESEND_INTERVAL_MINUTES", 5)

mail_provider()::String = env_lower("MAIL_PROVIDER", "mailhog")
mail_from()::String = env_string("MAIL_FROM", "no-reply@example.local")
smtp_host()::String = env_string("SMTP_HOST", "")
smtp_port()::Int = env_int("SMTP_PORT", 587)
smtp_username()::String = env_string("SMTP_USERNAME", "")
smtp_password()::String = env_string("SMTP_PASSWORD", "")
smtp_use_tls()::Bool = env_bool("SMTP_USE_TLS", true)

function validate_choice(key::String, value::String, allowed::Vector{String})::Nothing
    value in allowed || error("$key must be one of: $(join(allowed, ", "))")
    return nothing
end

function validate_production_secret(key::String, value::String)::Nothing
    normalized = lowercase(strip(value))
    if isempty(normalized) || normalized == "randomstring" || startswith(normalized, "change-me")
        error("$key must be changed before production startup")
    end
    return nothing
end

function validate_production_origins(origins::Vector{String})::Nothing
    for origin in origins
        uri = HTTP.URI(origin)
        if origin == "*" || isempty(uri.scheme) || isempty(uri.host) || uri.host in ["localhost", "127.0.0.1", "::1"]
            error("FRONTEND_ORIGINS must not contain local or invalid origin in production: $origin")
        end
    end
    return nothing
end

function validate_config!()::Nothing
    validate_choice("APP_ENV", app_env(), ["dev", "production", "test"])
    validate_choice("GENIE_ENV", genie_env(), ["dev", "prod", "test"])
    validate_choice("AUTH_LOGIN_ID_MODE", auth_login_id_mode(), ["email", "login_id"])
    validate_choice("MAIL_PROVIDER", mail_provider(), ["mailhog", "smtp"])
    isempty(frontend_origins()) && error("FRONTEND_ORIGINS must contain at least one origin")

    if mail_provider() == "smtp" && isempty(smtp_host())
        error("SMTP_HOST is required when MAIL_PROVIDER=smtp")
    end

    database_settings()
    log_level()

    if app_env() == "production"
        validate_production_secret("ACCESS_TOKEN_SECRET", access_token_secret())
        validate_production_secret("REFRESH_TOKEN_SECRET", refresh_token_secret())
        validate_production_origins(frontend_origins())
    end

    return nothing
end

end
