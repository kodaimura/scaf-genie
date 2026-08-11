module Mailer

import Sockets
import Base64
import MbedTLS

using ..Errors
using ..Config

export send_mail

function send_mail(; to, subject, body)::Nothing
    to = string(to)
    subject = string(subject)
    body = string(body)
    isempty(strip(to)) && return nothing

    provider = Config.mail_provider()
    if provider == "mailhog"
        send_smtp(
            host = "mailhog",
            port = 1025,
            from = Config.mail_from(),
            to = to,
            subject = subject,
            body = body,
            use_tls = false,
            username = "",
            password = "",
        )
        return nothing
    end

    if provider == "smtp"
        host = Config.smtp_host()
        isempty(host) && throw(ServiceUnavailableError("SMTP_HOST_REQUIRED"))
        send_smtp(
            host = host,
            port = Config.smtp_port(),
            from = Config.mail_from(),
            to = to,
            subject = subject,
            body = body,
            use_tls = Config.smtp_use_tls(),
            username = Config.smtp_username(),
            password = Config.smtp_password(),
        )
        return nothing
    end

    throw(ServiceUnavailableError("MAIL_PROVIDER_UNSUPPORTED"))
end

function send_smtp(; host, port::Int, from, to, subject, body, use_tls::Bool, username::String, password::String)::Nothing
    host = string(host)
    from = string(from)
    to = string(to)
    subject = string(subject)
    body = string(body)
    socket = Sockets.connect(host, port)
    io = socket
    try
        read_response(io)
        send_command(io, "EHLO localhost")
        if use_tls
            send_command(io, "STARTTLS")
            tls = MbedTLS.SSLContext()
            MbedTLS.setup!(tls, MbedTLS.SSLConfig(true))
            MbedTLS.associate!(tls, socket)
            MbedTLS.handshake!(tls)
            io = tls
            send_command(io, "EHLO localhost")
        end
        if !isempty(username) || !isempty(password)
            isempty(username) && throw(ServiceUnavailableError("SMTP_USERNAME_REQUIRED"))
            isempty(password) && throw(ServiceUnavailableError("SMTP_PASSWORD_REQUIRED"))
            send_command(io, "AUTH PLAIN $(smtp_plain_auth(username, password))")
        end
        send_command(io, "MAIL FROM:<$from>")
        send_command(io, "RCPT TO:<$to>")
        send_command(io, "DATA")
        write(io, compose_message(from, to, subject, body))
        read_response(io)
        send_command(io, "QUIT")
    finally
        close(socket)
    end
    return nothing
end

function send_command(socket, command::String)
    write(socket, command * "\r\n")
    return read_response(socket)
end

function read_response(socket)::String
    lines = String[]
    while true
        line = readline(socket)
        push!(lines, line)
        if length(line) < 4 || line[4] != '-'
            break
        end
    end
    line = last(lines)
    if isempty(line) || !(startswith(line, "2") || startswith(line, "3"))
        throw(ServiceUnavailableError("MAIL_SEND_FAILED"))
    end
    return join(lines, "\n")
end

function compose_message(from::String, to::String, subject::String, body::String)::String
    normalized_body = replace(body, "\n" => "\r\n")
    return join([
        "From: $from",
        "To: $to",
        "Subject: $subject",
        "MIME-Version: 1.0",
        "Content-Type: text/plain; charset=UTF-8",
        "",
        escape_smtp_body(normalized_body),
        ".",
        "",
    ], "\r\n")
end

function escape_smtp_body(body::String)::String
    return replace(body, r"(?m)^\." => "..")
end

function smtp_plain_auth(username::String, password::String)::String
    return Base64.base64encode("\0$username\0$password")
end

end
