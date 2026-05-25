# Module F — Containerized Azure DevOps self-hosted Linux agent
FROM ubuntu:22.04

ENV AGENT_VERSION=3.232.0 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq unzip wget \
    openjdk-17-jdk maven \
    docker.io \
    azure-cli \
    kubectl \
    helm \
    && rm -rf /var/lib/apt/lists/*

# Trivy
RUN wget -qO- https://aquasecurity.github.io/trivy/v0.54.1/trivy_0.54.1_Linux-64bit.tar.gz | tar xz -C /usr/local/bin trivy

COPY start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /azp/agent
VOLUME ["/azp/agent/_work"]

ENTRYPOINT ["/start.sh"]
