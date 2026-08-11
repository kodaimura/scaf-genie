# scaf-genie-api

Genie backend scaffold.

This template is intended to run through Docker. Local Julia and Node are not
required for normal development.
PostgreSQL is the supported database. The server stores and emits timestamps in
UTC.

## Development

```sh
cp .env.example .env
make build
make up
make migrate
```

Useful commands:

```sh
make logs
make exec
make shell
make check
make smoke
make routes
make migrate
make down_volumes
```

The API runs at `http://localhost:8000/api`.
Health check is available at `http://localhost:8000/health`.
MailHog is available at `http://localhost:8025` by default.
Set `MAILHOG_PORT` when that port is already in use.

## Structure

```text
app/
  handler/  # HTTP request/response handling
  module/   # persistence-oriented domain modules
  query/    # read/query-specific access
  usecase/  # application use cases
db/migrations/ # SearchLight migrations
```

Use production compose settings with `ENV=prod`.

```sh
cp .env.example .env
# Edit production secrets and database settings in .env.
make build ENV=prod
make migrate ENV=prod
make up ENV=prod
```

The development database is stored in the Docker named volume
`scaf-genie-api_db_data`.
