ARG JULIA_VERSION=1.12.6
FROM julia:${JULIA_VERSION} AS base

WORKDIR /app

ENV TZ=UTC
ENV JULIA_PROJECT=/app

COPY Project.toml Manifest.toml ./
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

FROM base AS development

COPY . .
RUN chmod +x ./entrypoint.sh

EXPOSE 8000

CMD ["./entrypoint.sh"]

FROM base AS production

COPY --chown=65532:65532 . .
RUN chmod +x ./entrypoint.sh

USER 65532:65532

EXPOSE 8000

CMD ["./entrypoint.sh"]
