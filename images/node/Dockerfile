# syntax=docker/dockerfile:1.7
ARG NODE_VERSION
FROM node:${NODE_VERSION}

RUN apk add --no-cache bash git openssh-client python3 make g++ libc6-compat tini su-exec \
 && corepack enable && corepack prepare pnpm@latest --activate || true

# Environment variables for package managers
ENV NPM_CONFIG_CACHE=/home/node/.npm \
    YARN_CACHE_FOLDER=/home/node/.yarn \
    PNPM_HOME=/home/node/.local/share/pnpm \
    PATH="/home/node/.local/share/pnpm:$PATH" \
    HISTFILE=/home/node/.bash_history HISTSIZE=50000 HISTFILESIZE=200000

# Enable live history append for node user
RUN printf '%s\n' 'shopt -s histappend' \
  'export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"' \
  >> /home/node/.bashrc \
  && chown node:node /home/node/.bashrc

WORKDIR /workspace

# Copy entrypoint script
COPY --link entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Run as root initially so entrypoint can fix ownership
USER root

ENTRYPOINT ["/sbin/tini","--","/usr/local/bin/entrypoint.sh"]
CMD ["sleep","infinity"]