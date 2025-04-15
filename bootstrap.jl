(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using Jlat
const UserApp = Jlat
Jlat.main()
