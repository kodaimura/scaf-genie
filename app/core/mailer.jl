module Mailer

import Sockets

using ..Errors

export send_mail

function send_mail(; to, subject, body)::Nothing
    to = string(to)
    subject = string(subject)
    body = string(body)
    isempty(strip(to)) && return nothing

    provider = lowercase(strip(Base.get(ENV, "MAIL_PROVIDER", "mailhog")))
    if provider == "mailhog"
        send_smtp(
            host = "mailhog",
            port = 1025,
            from = Base.get(ENV, "MAIL_FROM", "no-reply@example.local"),
            to = to,
            subject = subject,
            body = body,
        )
        return nothing
    end

    if provider == "smtp"
        use_tls = lowercase(strip(Base.get(ENV, "SMTP_USE_TLS", "false"))) == "true"
        if use_tls || !isempty(strip(Base.get(ENV, "SMTP_USERNAME", ""))) || !isempty(strip(Base.get(ENV, "SMTP_PASSWORD", "")))
            throw(ServiceUnavailableError("SMTP_TLS_OR_AUTH_UNSUPPORTED"))
        end

        host = strip(Base.get(ENV, "SMTP_HOST", ""))
        isempty(host) && throw(ServiceUnavailableError("SMTP_HOST_REQUIRED"))
        port = parse(Int, Base.get(ENV, "SMTP_PORT", "25"))
        send_smtp(
            host = host,
            port = port,
            from = Base.get(ENV, "MAIL_FROM", "no-reply@example.local"),
            to = to,
            subject = subject,
            body = body,
        )
        return nothing
    end

    throw(ServiceUnavailableError("MAIL_PROVIDER_UNSUPPORTED"))
end

function send_smtp(; host, port::Int, from, to, subject, body)::Nothing
    host = string(host)
    from = string(from)
    to = string(to)
    subject = string(subject)
    body = string(body)
    socket = Sockets.connect(host, port)
    try
        read_response(socket)
        send_command(socket, "HELO localhost")
        send_command(socket, "MAIL FROM:<$from>")
        send_command(socket, "RCPT TO:<$to>")
        send_command(socket, "DATA")
        write(socket, compose_message(from, to, subject, body))
        read_response(socket)
        send_command(socket, "QUIT")
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
    line = readline(socket)
    if isempty(line) || !(startswith(line, "2") || startswith(line, "3"))
        throw(ServiceUnavailableError("MAIL_SEND_FAILED"))
    end
    return line
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

end
