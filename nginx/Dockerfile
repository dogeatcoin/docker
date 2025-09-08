# syntax=docker/dockerfile:1.7
ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

# Tiny init to forward signals/reap zombies
RUN apk add --no-cache dumb-init

EXPOSE 80 443
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/usr/bin/dumb-init","--"]
CMD ["nginx","-g","daemon off;"]