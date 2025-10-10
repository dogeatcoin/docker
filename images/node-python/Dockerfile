# syntax=docker/dockerfile:1.7
ARG NODE_VERSION
FROM node:${NODE_VERSION}

# Install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for python command
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Python dependencies as root first
RUN pip install git+https://github.com/elliottech/lighter-python.git python-dotenv

# Create Python cache directory and set permissions for node user
RUN mkdir -p /home/node/.cache/pip && \
    chown -R node:node /home/node/.cache

# Set working directory
WORKDIR /workspace

# Change ownership of workspace to node user
RUN chown node:node /workspace

# Switch to node user
USER node

# Set Python user base for node user
ENV PYTHONUSERBASE=/home/node/.local
ENV PATH=$PATH:/home/node/.local/bin

# Expose ports
EXPOSE 3000 9229

# Keep container running
CMD ["sleep", "infinity"]