ARG JULIA_VERSION=1.12.6
FROM julia:${JULIA_VERSION}

WORKDIR /app

ENV TZ=UTC
ENV JULIA_PROJECT=/app

COPY Project.toml Manifest.toml ./
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

COPY . .
RUN chmod +x ./entrypoint.sh

EXPOSE 8000

CMD ["./entrypoint.sh"]
