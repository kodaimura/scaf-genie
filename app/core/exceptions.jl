module Exceptions

import Genie.Requests as Requests
using Logging
using ..Errors

export handle_exception

# Handles and logs exceptions, return AppError.
function handle_exception(e::Exception)::AppError
    req = Requests.request()
    if e isa AppError
        if e isa ExpectedError
            @debug "$(typeof(e)): $e | Request: $req"
        else
            @error "$(typeof(e)): $e | Request: $req"
        end
        return e
    end
    @error "$(typeof(e)): $e | Request: $req"
    return InternalServerError()
end

end