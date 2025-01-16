FROM julia:1.11

WORKDIR /app

COPY . /app

RUN apt-get update \
    && apt-get install -y logrotate \
    && rm -rf /var/lib/apt/lists/*

RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'