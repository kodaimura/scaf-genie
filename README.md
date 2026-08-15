# scaf-genie

Genie backend scaffold.

## Create a project

This scaffold supports direct cloning, GitHub's **Use this template**, and
generation through webscaf.

For a direct clone or a repository created from the GitHub template, clone it
using the intended project directory and initialize it once:

```sh
git clone <repository-url> my-app
cd my-app
make init
```

`make init` uses the current directory name. Override it when needed with
`make init PROJECT_NAME=another-name`. webscaf runs the same initialization
automatically. Skip initialization only when developing this scaffold itself.

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
make test_e2e
make smoke
make routes
make versions
make migrate
make down_volumes
```

API E2E tests are organized by domain so new endpoints can add coverage at the
same level. See [`test/e2e/README.md`](test/e2e/README.md).

The API runs at `http://localhost:8000/api`.
Health check is available at `http://localhost:8000/health`.
MailHog is available at `http://localhost:8025` by default.
Set `MAILHOG_PORT` when that port is already in use.
Set `API_PORT` when `8000` is already in use.
Host ports are bound to `127.0.0.1` by default. Set `API_BIND_HOST=0.0.0.0`
only when the API must be reachable from outside the host.

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
`scaf-genie_db_data`.
If PostgreSQL image versions are upgraded on an existing local volume and a
collation warning appears, recreate the dev volume with `make down_volumes`
before running `make migrate` again.
