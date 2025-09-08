# syntax=docker/dockerfile:1.7
ARG NODE_VERSION
FROM node:${NODE_VERSION}

RUN apk add --no-cache bash git openssh-client python3 make g++ libc6-compat tini \
 && corepack enable && corepack prepare pnpm@latest --activate || true

ENV NPM_CONFIG_CACHE=/home/node/.npm \
    YARN_CACHE_FOLDER=/home/node/.yarn \
    PNPM_HOME=/home/node/.local/share/pnpm \
    PATH="/home/node/.local/share/pnpm:$PATH" \
    HISTFILE=/home/node/.bash_history HISTSIZE=50000 HISTFILESIZE=200000

USER node
WORKDIR /workspace

# live history append
RUN printf '%s\n' 'shopt -s histappend' \
  'export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"' \
  >> /home/node/.bashrc

ENTRYPOINT ["/sbin/tini","--"]
CMD ["node","-v"]