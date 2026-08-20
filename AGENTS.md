# Repository Instructions

## Project Context

- This repository is a Genie backend scaffold written in Julia.
- Read `README.md` and the `Makefile` before changing setup or development workflows.
- Preserve the existing project structure and naming unless the task requires an architectural change.

## Architecture

- This project follows HUMQ v1.1.0, reviewed at upstream commit `d3c9150`, through the Julia/Genie-specific contract in `docs/ARCHITECTURE.md`.
- Before designing, reviewing, or changing application code under `app/`, read and follow `docs/ARCHITECTURE.md`.
- Treat `docs/ARCHITECTURE.md` as the local source of truth for responsibility boundaries, dependency direction, state ownership, and testing expectations.
- Update the implementation and architecture document together when a requested change intentionally alters those rules.

## Working Agreements

- Keep changes focused and preserve unrelated work.
- Do not commit secrets, local environment files, generated builds, or runtime data.
- Add or update tests when behavior changes.

## Verification

- Run `make check` for Julia tests and application precompilation.
- Run `make test_e2e` when API behavior or database integration changes.
- Run `make build_prod` when production dependencies or container configuration changes.

## Operations

- Read `docs/RUNBOOK.md` before changing production behavior or assisting with a deployment, release, rollback, recovery, or production incident.
- Follow the runbook's authorization, verification, and stop conditions. An implementation or commit request is not deployment authorization.
