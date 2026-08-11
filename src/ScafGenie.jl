module ScafGenie

using Genie

include("../app/core/errors.jl")
include("../app/core/jwt.jl")
include("../app/core/mailer.jl")
include("../app/core/validations.jl")
include("../app/core/responses.jl")
include("../app/core/exceptions.jl")
include("../app/core/auth.jl")

const up = Genie.up
export up

function main()
    Genie.genie(; context=@__MODULE__)
end

end
