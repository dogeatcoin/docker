# syntax=docker/dockerfile:1.7

# Version argument
ARG MARIADB_VERSION
FROM mariadb:${MARIADB_VERSION}

# Dumb-init to forward signals/reap zombies
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/dumb-init", "--", "docker-entrypoint.sh"]
CMD ["mysqld"]