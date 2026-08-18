module ScafGenie

using Genie

include("../app/core/config.jl")
include("../app/core/database.jl")
include("../app/core/errors.jl")
include("../app/core/logger.jl")
include("../app/core/cors.jl")
include("../app/core/crypto.jl")
include("../app/core/jwt.jl")
include("../app/core/mailer.jl")
include("../app/core/validations.jl")
include("../app/core/responses.jl")
include("../app/core/exceptions.jl")
include("../app/core/auth.jl")

const up = Genie.up
export up

function __init__()
    Config.validate_config!()
end

function main()
    Config.validate_config!()
    Genie.genie(; context=@__MODULE__)
end

end
