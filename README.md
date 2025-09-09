# 📦 Docker Images Repository

This repository contains all **Dockerfiles** and configuration required to build custom development images used across my projects (Node.js, PHP, MariaDB, ClickHouse, Nginx…).  
All images are built and published to **GitHub Container Registry (GHCR)** for easy reuse in different projects.

---

## 📂 Repository Structure

- **images/** – contains individual Dockerfiles grouped by technology  
- **README.md** – this documentation  

---

## 🛠 Build & Publish

### Build locally
You can build any image directly from its folder.  
Example for Node.js 22 Alpine:

```bash
cd images/node
docker build -t ghcr.io/<username>/node-dev:22-alpine --build-arg NODE_VERSION=22-alpine .
```

Run the container locally for testing:
```bash
docker run --rm -it ghcr.io/<username>/node-dev:22-alpine node -v
```

### Push to GHCR
Login to GHCR using a Personal Access Token with `write:packages` scope:

```bash
echo $GHCR_PAT | docker login ghcr.io -u <username> --password-stdin
docker push ghcr.io/<username>/node-dev:22-alpine
```

### Automated publishing (recommended)

This repository includes a GitHub Actions workflow (.github/workflows/publish.yml) that automatically:
-	Builds all images from the images/ directory
-	Tags them with semver (vX.Y.Z), rolling (22-alpine), and snapshot (YYYYMMDD) tags
-	Pushes them to GHCR

The workflow is triggered on every push to main (and can also be triggered manually).

---

## 📥 Usage in Projects

To use a published image inside your project `docker-compose.yml`:

```yaml
services:
  node22:
    image: ghcr.io/<username>/node-dev:22-alpine
    working_dir: /workspace
    volumes:
      - .:/workspace
    command: ["sh","-lc","npm run dev"]
```

For VS Code Dev Containers, reference the image in `.devcontainer/devcontainer.json`:

```jsonc
{
  "name": "node22 dev",
  "dockerComposeFile": ["../docker-compose.yml"],
  "service": "node22",
  "workspaceFolder": "/workspace",
  "remoteUser": "node",
  "shutdownAction": "stopCompose"
}
```

---

## 🔑 Authentication

- **Public images** → can be pulled without authentication  
- **Private images** → require login:

```bash
echo $GHCR_PAT | docker login ghcr.io -u <username> --password-stdin
```

---

## 📜 License
These images are intended for **personal development** and can be freely used as a base for other projects.  
For production environments, consider creating your own hardened builds.
