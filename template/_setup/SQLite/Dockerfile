FROM julia:1.11

WORKDIR /app

RUN apt-get update \
    && apt-get install -y sqlite3 \
    && apt-get install -y logrotate \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'