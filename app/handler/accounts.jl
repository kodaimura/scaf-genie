module AccountsHandler

import Genie.Requests as Requests

using ..AccountsDto
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
        return json_success(AccountsDto.accounts_response(accounts))
    catch e
        return json_fail(handle_exception(e))
    end
end

function create()
    try
        request = AccountsDto.account_request(Requests.jsonpayload())
        input = AccountsUsecase.CreateAccountInput(
            request.login_id,
            request.email,
            request.password,
            request.first_name,
            request.last_name,
        )
        account = AccountsUsecase.create(input)
        return json_success(AccountsDto.account_payload(account); status=201)
    catch e
        return json_fail(handle_exception(e))
    end
end

function get_current(account_id::Int)
    try
        account = AccountsUsecase.get_current(account_id)
        return json_success(AccountsDto.account_payload(account))
    catch e
        return json_fail(handle_exception(e))
    end
end

function get(target_account_id::Int)
    try
        account = AccountsUsecase.get(target_account_id)
        return json_success(AccountsDto.account_payload(account))
    catch e
        return json_fail(handle_exception(e))
    end
end

function update(target_account_id::Int)
    try
        request = AccountsDto.update_account_request(Requests.jsonpayload())
        input = AccountsUsecase.UpdateAccountInput(
            request.login_id,
            request.email,
            request.password,
            request.first_name,
            request.last_name,
        )
        account = AccountsUsecase.update(target_account_id, input)
        return json_success(AccountsDto.account_payload(account))
    catch e
        return json_fail(handle_exception(e))
    end
end

function disable(target_account_id::Int)
    try
        account = AccountsUsecase.disable(target_account_id)
        return json_success(AccountsDto.account_payload(account))
    catch e
        return json_fail(handle_exception(e))
    end
end

function enable(target_account_id::Int)
    try
        account = AccountsUsecase.enable(target_account_id)
        return json_success(AccountsDto.account_payload(account))
    catch e
        return json_fail(handle_exception(e))
    end
end

end
