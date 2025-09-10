# syntax=docker/dockerfile:1.7
FROM debian:bookworm-slim

# Install dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates curl expect iproute2 iptables tini tinyproxy \
      python3 python3-flask \
    && rm -rf /var/lib/apt/lists/*

# Copy configs & controller
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY controller.py /usr/local/bin/controller.py
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Runtime env (override in compose)
ENV PROXY_PORT=8080 \
    CONTROL_PORT=8088 \
    KILLSWITCH=1

EXPOSE 8080 8088

# Install ExpressVPN client at runtime
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]