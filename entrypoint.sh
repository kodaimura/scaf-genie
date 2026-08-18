#!/bin/sh
set -e

exec julia --project=. -e "
using Genie;
Genie.loadapp();
up(host = \"0.0.0.0\", async = false);
"
