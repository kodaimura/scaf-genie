module Accounts

import Dates: DateTime, now
import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Account

@kwdef mutable struct Account <: AbstractModel
    id::DbId = DbId()
    name::String = ""
    password::String = ""
    created_at::DateTime = now()
    updated_at::DateTime = now()
end

end
