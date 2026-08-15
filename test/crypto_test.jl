using Test, Main.ScafGenie.Crypto

@testset "Authentication crypto" begin
    password_hash = hash_password("Password123!")
    @test password_hash != "Password123!"
    @test verify_password("Password123!", password_hash)
    @test !verify_password("WrongPassword", password_hash)

    token = generate_token()
    @test !isempty(token)
    @test hash_token(token) == hash_token(token)
    @test hash_token(token) != hash_token("another-token")
end
