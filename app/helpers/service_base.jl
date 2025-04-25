module ServiceBase

import Genie.Requests as Requests
using Logging
using ..Errors

export handle_exception

# Handles and logs exceptions, throwing appropriate errors.
function handle_exception(e::Exception)
    if e isa AppError
        if e isa ExpectedError
            @debug "$e"
        else
            @error Requests.request()
            @error "$e"
        end
        throw(e)
    end
    @error Requests.request()
    @error "$e"
    throw(InternalServerError())
end

end