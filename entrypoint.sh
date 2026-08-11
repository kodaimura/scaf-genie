#!/bin/sh
set -e

julia -e "
using Pkg; 
Pkg.activate(\".\"); 
Pkg.instantiate();
using SearchLight, SearchLightPostgreSQL;
SearchLight.Configuration.load();
SearchLight.connect();
SearchLight.query(\"CREATE TABLE IF NOT EXISTS schema_migrations (version varchar(30))\");
SearchLight.Migration.up();
"

exec julia -e "
using Pkg; 
Pkg.activate(\".\"); 
using Genie; 
Genie.loadapp(); 
up(host = \"0.0.0.0\", async = false);
"
