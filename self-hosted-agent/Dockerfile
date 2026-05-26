# Module F — Containerized Azure DevOps self-hosted Linux agent
# Supports amd64 and arm64 (Apple Silicon Docker Desktop)
FROM ubuntu:22.04

ARG TARGETARCH
ENV AGENT_VERSION=3.232.0 \
    DEBIAN_FRONTEND=noninteractive \
    TRIVY_VERSION=0.70.0 \
    AGENT_ALLOW_RUNASROOT=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq unzip wget gnupg lsb-release apt-transport-https \
    openjdk-17-jdk maven docker.io \
    && rm -rf /var/lib/apt/lists/*

# docker.io uses the legacy builder; buildx is required for linux/amd64 images on arm64 agents
ARG BUILDX_VERSION=0.19.3
RUN ARCH="$(dpkg --print-architecture)" \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -fsSL "https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-${ARCH}" \
      -o /usr/local/lib/docker/cli-plugins/docker-buildx \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx \
    && docker buildx version

# Azure CLI via Microsoft apt repo (works on arm64 and amd64)
RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
      > /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends azure-cli \
    && rm -rf /var/lib/apt/lists/*

# kubectl + Helm binaries for target architecture
RUN ARCH="${TARGETARCH:-amd64}" \
    && curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -fsSL "https://get.helm.sh/helm-v3.16.3-linux-${ARCH}.tar.gz" -o /tmp/helm.tgz \
    && tar -xzf /tmp/helm.tgz -C /tmp \
    && mv "/tmp/linux-${ARCH}/helm" /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf /tmp/helm.tgz "/tmp/linux-${ARCH}"

# Trivy (arch-specific release)
RUN ARCH="${TARGETARCH:-amd64}" \
    && case "${ARCH}" in arm64) TRIVY_ARCH=ARM64 ;; *) TRIVY_ARCH=64bit ;; esac \
    && curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz" -o /tmp/trivy.tgz \
    && tar -xzf /tmp/trivy.tgz -C /usr/local/bin trivy \
    && rm /tmp/trivy.tgz \
    && trivy --version

# ADO pipeline agent (baked at build time — avoids azureedge.net DNS issues at runtime)
RUN ARCH="${TARGETARCH:-amd64}" \
    && case "${ARCH}" in arm64) AGENT_ARCH=linux-arm64 ;; *) AGENT_ARCH=linux-x64 ;; esac \
    && mkdir -p /azp/agent \
    && curl -fsSL "https://download.agent.dev.azure.com/agent/${AGENT_VERSION}/vsts-agent-${AGENT_ARCH}-${AGENT_VERSION}.tar.gz" -o /tmp/agent.tgz \
    && tar -xzf /tmp/agent.tgz -C /azp/agent --strip-components=1 \
    && rm /tmp/agent.tgz \
    && test -x /azp/agent/config.sh

COPY start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /azp/agent
VOLUME ["/azp/agent/_work"]

ENTRYPOINT ["/start.sh"]
