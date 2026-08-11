# scaf-genie-api

Genie backend scaffold.

This template is intended to run through Docker. Local Julia and Node are not
required for normal development.
PostgreSQL is the supported database. The server stores and emits timestamps in
UTC.

Default runtime versions:

- Julia 1.12.6
- Genie 6.0.x
- PostgreSQL 17.10

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
make test
make smoke
make routes
make versions
make migrate
make down_volumes
```

The API runs at `http://localhost:8000/api`.
Health check is available at `http://localhost:8000/health`.
MailHog is available at `http://localhost:8025` by default.
Set `MAILHOG_PORT` when that port is already in use.
Set `API_PORT` when `8000` is already in use.

The dev compose file bind-mounts the repository into the API container, so
source changes are reflected without rebuilding the image. Rebuild when
`Project.toml`, `Manifest.toml`, or Docker metadata changes.

## Structure

```text
app/
  core/     # cross-cutting application primitives
  handler/  # HTTP request/response handling
  module/   # persistence-oriented domain modules
  query/    # read/query-specific access
  usecase/  # application use cases
db/migrations/ # SearchLight migrations
```

Use production compose settings with `ENV=prod`. The production compose file
runs from the built image instead of bind-mounting the repository.

```sh
cp .env.example .env
# Edit production secrets and database settings in .env.
make build ENV=prod
make migrate ENV=prod
make up ENV=prod
```

`Manifest.toml` is tracked so Docker builds resolve the same Julia package
versions by default. Update it intentionally when upgrading dependencies.

The development database is stored in the Docker named volume
`scaf-genie-api_db_data`.
If PostgreSQL image versions are upgraded on an existing local volume and a
collation warning appears, recreate the dev volume with `make down_volumes`
before running `make migrate` again.
