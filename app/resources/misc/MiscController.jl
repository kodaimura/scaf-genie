module MiscController

import Genie.Requests as Requests

using ScafGenie.Responses
using ScafGenie.Exceptions

export index

function index(payload::Dict{String,Any})
    try
        return html_success(:misc, :index, account_name=payload["account_name"])
    catch e
        app_error = handle_exception(e)
        return html_fail(app_error)
    end
end

end