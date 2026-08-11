module AccountsHandler

import Genie.Requests as Requests

using ..AccountsUsecase
using ScafGenie.Exceptions
using ScafGenie.Responses

export list,
    create,
    get_current,
    get,
    update,
    disable,
    enable

function list()
    try
        accounts = AccountsUsecase.list()
        return json_success(Dict("accounts" => [AccountsUsecase.AccountModule.account_response(account) for account in accounts]))
    catch e
        return json_fail(handle_exception(e))
    end
end

function create()
    request = Requests.jsonpayload()
    try
        account = AccountsUsecase.create(request)
        return json_success(Dict("account" => AccountsUsecase.AccountModule.account_response(account)); status=201)
    catch e
        return json_fail(handle_exception(e))
    end
end

function get_current(account_id::Int)
    try
        account = AccountsUsecase.get_current(account_id)
        return json_success(Dict("account" => AccountsUsecase.AccountModule.account_response(account)))
    catch e
        return json_fail(handle_exception(e))
    end
end

function get(target_account_id::Int)
    try
        account = AccountsUsecase.get(target_account_id)
        return json_success(Dict("account" => AccountsUsecase.AccountModule.account_response(account)))
    catch e
        return json_fail(handle_exception(e))
    end
end

function update(target_account_id::Int)
    request = Requests.jsonpayload()
    try
        account = AccountsUsecase.update(target_account_id, request)
        return json_success(Dict("account" => AccountsUsecase.AccountModule.account_response(account)))
    catch e
        return json_fail(handle_exception(e))
    end
end

function disable(target_account_id::Int)
    try
        account = AccountsUsecase.disable(target_account_id)
        return json_success(Dict("account" => AccountsUsecase.AccountModule.account_response(account)))
    catch e
        return json_fail(handle_exception(e))
    end
end

function enable(target_account_id::Int)
    try
        account = AccountsUsecase.enable(target_account_id)
        return json_success(Dict("account" => AccountsUsecase.AccountModule.account_response(account)))
    catch e
        return json_fail(handle_exception(e))
    end
end

end
