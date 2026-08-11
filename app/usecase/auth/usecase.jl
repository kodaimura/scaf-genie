module AuthUsecase

include("../../module/account/module.jl")
include("../../module/password_reset_token/module.jl")
include("../helper.jl")
include("../validation.jl")

using .AccountModule
using .PasswordResetTokenModule
using .UsecaseHelper
using .UsecaseValidation
import Dates
import HTTP
using ScafGenie.Errors
using ScafGenie.Jwt
using ScafGenie.Mailer

export signup,
    login,
    refresh,
    validate_access_token_account,
    update_password,
    forgot_password,
    verify_reset_password_token,
    reset_password

include("helper.jl")
include("signup.jl")
include("login.jl")
include("refresh.jl")
include("validate_access_token_account.jl")
include("update_password.jl")
include("forgot_password.jl")
include("verify_reset_password_token.jl")
include("reset_password.jl")

end
