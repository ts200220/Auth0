# 03-silent-auth-prompt-none — Next.js × Auth0 CLI（Zenn 03 / Silent Auth）
FROM node:22-bookworm-slim

ARG AUTH0_CLI_VERSION=latest

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    jq \
    gosu \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  if [ "${AUTH0_CLI_VERSION}" = "latest" ]; then \
    TAG="$(curl -fsSL https://api.github.com/repos/auth0/auth0-cli/releases/latest | jq -r .tag_name)"; \
  else \
    TAG="${AUTH0_CLI_VERSION}"; \
  fi; \
  VERSION="${TAG#v}"; \
  curl -fsSL \
    "https://github.com/auth0/auth0-cli/releases/download/${TAG}/auth0-cli_${VERSION}_Linux_x86_64.tar.gz" \
    -o /tmp/auth0.tgz; \
  tar -xzf /tmp/auth0.tgz -C /usr/local/bin auth0; \
  chmod +x /usr/local/bin/auth0; \
  rm /tmp/auth0.tgz; \
  auth0 --version

ENV XDG_CONFIG_HOME=/home/node/.config \
    HOME=/home/node \
    NEXT_TELEMETRY_DISABLED=1 \
    npm_config_update_notifier=false \
    WATCHPACK_POLLING=true \
    CHOKIDAR_USEPOLLING=true

WORKDIR /workspace

COPY scripts/docker-entrypoint-web.sh /usr/local/bin/docker-entrypoint-web.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-web.sh \
  && mkdir -p /home/node/.config/auth0 \
  && chown -R node:node /home/node

USER root

CMD ["bash"]
