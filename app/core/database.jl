module Database

import SearchLight

export transaction, with_connection

# SearchLightPostgreSQL exposes one process-wide connection. Serialize access
# so an asynchronous request cannot execute inside another request's transaction.
const CONNECTION_LOCK = ReentrantLock()

function with_connection(f::Function)
    return lock(CONNECTION_LOCK) do
        f()
    end
end

function transaction(f::Function)
    return lock(CONNECTION_LOCK) do
        SearchLight.Transactions.transaction(f)
    end
end

end
