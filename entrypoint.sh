#!/bin/bash
set -e

if [ ! -f "/app/migration_initialized" ]; then
  julia -e "using Pkg; 
    Pkg.activate(\".\"); 
    Pkg.instantiate();
    using SearchLight, SearchLightPostgreSQL;
    SearchLight.Configuration.load();
    SearchLight.connect();
    SearchLight.Migration.init();"
    
  touch /app/migration_initialized
fi

julia -e "
using Pkg; 
Pkg.activate(\".\"); 
Pkg.instantiate();
using SearchLight, SearchLightPostgreSQL;
SearchLight.Configuration.load();
SearchLight.connect();
SearchLight.Migration.up();
"

exec julia -e "
using Pkg; 
Pkg.activate(\".\"); 
using Genie; 
Genie.loadapp(); 
up(host = \"0.0.0.0\", async = false);
"