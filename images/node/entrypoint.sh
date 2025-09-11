#!/usr/bin/env sh
set -eu

# Define node paths
PATHS="
/home/node/.npm
/home/node/.yarn
/home/node/.local
/home/node/.local/share
/home/node/.local/share/pnpm
"

# Create paths if they don't exist
for p in $PATHS; do
  mkdir -p "$p" || true
done

# If running as root, fix ownership (on Alpine, node:node = 1000:1000)
if [ "$(id -u)" -eq 0 ]; then
  chown -R 1000:1000 /home/node || true
fi

# Drop privileges and execute CMD/command
exec su-exec node:node "$@"