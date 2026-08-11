module CreateTablePasswordResetToken

import SearchLight

function up()
    SearchLight.query("""
    CREATE TABLE IF NOT EXISTS password_reset_token (
        id SERIAL PRIMARY KEY,
        account_id INTEGER NOT NULL REFERENCES accounts(id),
        token_hash TEXT NOT NULL UNIQUE,
        expires_at TIMESTAMP NOT NULL,
        used_at TIMESTAMP,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL
    )
    """)
    SearchLight.query("""
    CREATE INDEX IF NOT EXISTS ix_password_reset_token_account_id
    ON password_reset_token (account_id)
    """)
end

function down()
    SearchLight.query("DROP TABLE IF EXISTS password_reset_token")
end

end
