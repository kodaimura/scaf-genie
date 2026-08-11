#!/bin/sh
set -e

exec julia -e "
using Pkg;
Pkg.activate(\".\");
Pkg.instantiate();
using Genie;
Genie.loadapp();
up(host = \"0.0.0.0\", async = false);
"
