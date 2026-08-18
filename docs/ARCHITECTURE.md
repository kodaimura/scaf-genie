# Application Architecture

## Status and source

This project adopts [HUMQ](https://github.com/kodaimura/humq) v1.1.0 and maps
its responsibilities to Julia, Genie, and SearchLight. This document is the
local contract; upstream HUMQ changes apply only after an explicit review.

## Responsibility mapping

| HUMQ responsibility | This repository |
| --- | --- |
| Handler | `app/handler/<domain>.jl` and `app/handler/dto/` |
| Usecase | Exported actions in `app/usecase/<domain>/` |
| Module | Table-oriented Julia modules under `app/module/<table>/` |
| Query | Read-specific code under `app/query/` |
| Policy / Operation | Narrow internal functions in the owning Usecase module |
| External client | Protocol adapters such as mail under `app/core/` or a named client module |

A Julia module groups related functions and dependencies. Each exported
Usecase function still represents one independently explainable business
action.

## Dependency direction

```text
Genie route
  -> Handler
       -> Usecase action
            -> Module -> SearchLight model / PostgreSQL
            -> Query  -> read model / PostgreSQL
            -> Policy
            -> Operation -> Module / Query / Policy
            -> External client
```

- Handler calls Usecase, never SearchLight, Module, Query, or an external client.
- Usecase coordinates Module, Query, Policy, Operation, and external clients.
- Module owns one table by default and does not call Handler or Usecase.
- Query is read-only and named after the result it observes.
- `app/core` contains cross-cutting infrastructure, not hidden business flow.

## Handler and DTO

Handlers translate Genie requests into typed DTO or Usecase inputs and convert
results into HTTP responses. They own route parameters, request parsing,
cookies, response status, and transport error conversion.

Handlers must not access SearchLight, mutate models, own transactions, or make
business authorization decisions. Authentication helpers may identify a caller;
the Handler passes that identity into the relevant Usecase.

## Usecase

An exported Usecase function owns the order of business steps, state-dependent
validation, authorization, branching, transaction boundaries, and external-I/O
policy. Keep significant branches visible in that function.

Avoid generic helper modules. A deterministic shared calculation may be an
internal policy function that receives all inputs. Shared database-dependent
behavior may become a narrowly named internal operation after it is reused with
the same meaning and failure policy.

Usecase does not call SearchLight persistence functions directly. It may open a
`Database.transaction` block and call Modules or Queries inside it.

## Module and Query

A Module owns basic reads and all writes for its SearchLight model's table. It
owns row locks, conditional updates, timestamp persistence, and ORM-specific
conversion. It must not start or commit an application transaction.

Use Query for joins, aggregation, reports, complex search, and purpose-specific
read models. Query never writes. Basic lookup and standard lists stay in the
table Module.

SearchLight models represent persistence only. Handlers return explicitly
constructed response dictionaries or DTOs so password hashes and other internal
fields cannot leak.

## Transactions and concurrency

The Usecase wraps changes that must succeed or fail together in
`Database.transaction do ... end`. The owning Module performs the
database-specific concurrency control inside that same block. Password reset
uses a conditional `UPDATE ... RETURNING` so only one request can consume an
unused token. Database constraints are the final guard for representable
invariants.

SearchLightPostgreSQL exposes one connection per application process.
`ScafGenie.Database` serializes all access to that connection so asynchronous
requests cannot enter another request's transaction. Modules use
`Database.with_connection`; application transactions remain explicit in the
owning Usecase.

External I/O is outside database atomicity. Perform best-effort notification
after commit, or introduce an outbox when delivery must be guaranteed.

## Authentication and authorization

Authentication establishes the caller identity. Authorization remains a
Usecase responsibility. Define product-specific ownership, roles, and
administrative permissions and deny operations that are not explicitly
allowed. Account collection and target-account routes require this work before
production use.

## Testing and evolution

- Test policy and Usecase branches with Julia tests.
- Test SearchLight queries, locks, transactions, and constraints with
  PostgreSQL when their behavior matters.
- Cover transport contracts and complete flows with API E2E tests.
- Run `make check`; run `make test_e2e` for API, database, transaction, or
  migration changes.

Document and test any deliberate exception instead of silently mixing
responsibilities.
