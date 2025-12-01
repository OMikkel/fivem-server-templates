# 1. Use a base image with necessary libraries
FROM --platform=linux/amd64 debian:bookworm-slim

# Install dependencies including mariadb-client for DB operations
RUN apt-get update && apt-get install -y \
    wget curl xz-utils git libatomic1 ca-certificates mariadb-client iproute2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/fivem

# Download FiveM Artifacts
ARG FXSERVER_VER=17000-e0ef7490f76a24505b8bac7065df2b7075e610ba
RUN curl -O https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FXSERVER_VER}/fx.tar.xz \
    && tar xf fx.tar.xz \
    && rm fx.tar.xz

# Copy the main entrypoint
COPY ./scripts/entrypoint.sh /opt/fivem/entrypoint.sh
RUN chmod +x /opt/fivem/entrypoint.sh

EXPOSE 30120/tcp 30120/udp 40120/tcp

WORKDIR /opt/fivem/server-data
ENTRYPOINT ["/opt/fivem/entrypoint.sh"]