module CreateTableAccounts

import SearchLight.Migrations: create_table, column, columns, pk, add_index, drop_table, add_indices

function up()
    create_table(:accounts) do
        [
            pk()
            column("email", :string, "UNIQUE", limit=255)
            column("login_id", :string, "UNIQUE", limit=255, not_null=true)
            column("password_hash", :string, limit=255, not_null=true)
            column("token_version", :integer, default=1, not_null=true)
            column("first_name", :string, limit=100, not_null=true)
            column("last_name", :string, limit=100, not_null=true)
            column("disabled_at", :timestamp)
            column("deleted_at", :timestamp)
            column("created_at", :timestamp, not_null=true)
            column("updated_at", :timestamp, not_null=true)
        ]
    end
end

function down()
    drop_table(:accounts)
end

end
