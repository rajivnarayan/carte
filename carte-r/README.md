# carte-r

## **C**ontainerized **A**nalysis **R**un**T**ime **E**nvironment for **R**

## Overview

carte-r is a Docker image for data analysis in R, providing a reproducible environment that runs consistently across different hosts.

- Docker image: [askrajiv/carte-r](https://hub.docker.com/repository/docker/askrajiv/carte-r)
- Presentations: [Boston Computational Biology and Bioinformatics Meetup](https://docs.google.com/presentation/d/12IYun6xaBOPVdTIMsmFnTdH7LfP26pOV0ZBdzP4MEsY/edit?usp=sharing)

## Features

- Built on [rocker/r2u](https://github.com/rocker-org/r2u) (Ubuntu Noble), providing fast binary R package installation via the [r2u](https://eddelbuettel.github.io/r2u/) repository
- 200+ pre-installed packages from CRAN and Bioconductor covering computational biology, data analysis, and report generation
- Optional services enabled at runtime:
  - [RStudio Server](https://posit.co/products/open-source/rstudio-server/) — browser-based R IDE
  - [OpenCPU](https://www.opencpu.org/) — HTTP API server for R
  - [Shiny Server](https://shiny.posit.co/r/articles/host/shiny-server/) — interactive web applications
- Auto-selects a CPU-optimized BLAS library at runtime (`AUTOSELECT_BLAS=true`): MKL (Intel), BLIS (AMD), or OpenBLAS (other)
- [s6-overlay](https://github.com/just-containers/s6-overlay) init system for managing multiple services in a single container

A static variant with RStudio pre-installed for faster startup is available at [askrajiv/carte-r-rstudio](https://hub.docker.com/repository/docker/askrajiv/carte-r-rstudio).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) 20.10 or later
- [Docker Compose](https://docs.docker.com/compose/install/) v2.0 or later (included with Docker Desktop; verify with `docker compose version`)

## Getting Started

### Using docker compose (recommended)

Clone the repo and navigate to the carte-r directory:

```bash
git clone https://github.com/rajivnarayan/carte.git
cd carte/carte-r
```

Copy the dotenv template and edit it:

```bash
cp dotenv .env
```

Edit `.env` and set at minimum:

```bash
# Required: password for the carte user
CARTE_PASSWORD=your_secure_password

# Full path to your home directory on the host
BIND_VOLUME_HOME=/home/yourname

# Full path to your workspace on the host
BIND_VOLUME_WORKSPACE=/home/yourname/projects

# Your host user ID (run: id -u)
HOST_UID=1000
```

> **Note:** If `BIND_VOLUME_HOME` or `BIND_VOLUME_WORKSPACE` paths do not exist on the host, Docker will fail to start the container. Create them first if needed.

**Start a base container with R command-line access:**

```bash
docker compose run base
```

**Start RStudio Server:**

```bash
docker compose up rstudio
```

Open http://localhost:8787 and log in with username `carte` and the password from `CARTE_PASSWORD`.

**Start a full container with RStudio, OpenCPU, and Shiny:**

```bash
docker compose up full
```

- RStudio: http://localhost:8787
- OpenCPU: http://localhost:8080/ocpu
- Shiny: http://localhost:3838

> **Note:** Host ports are configured in `.env` via `RSTUDIO_HOST_PORT`, `SHINY_HOST_PORT`, and `OPENCPU_HTTP_HOST_PORT`. If a port is already in use on your host, change the corresponding variable before starting the container.

### Using docker run

**Base container:**

```bash
docker run -it --rm \
  -e PASSWORD=<your_password> \
  -e USERID=$(id -u) \
  -v $HOME:/home/carte \
  -v /path/to/workspace:/home/carte/workspace \
  askrajiv/carte-r:latest /init su carte
```

**With RStudio Server:**

```bash
docker run -it --rm \
  -p 8787:8787 \
  -e PASSWORD=<your_password> \
  -e USERID=$(id -u) \
  -e ADD_RSTUDIO=true \
  -v $HOME:/home/carte \
  -v /path/to/workspace:/home/carte/workspace \
  askrajiv/carte-r:latest /init
```

### Building the image

```bash
./build.sh
```

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `PASSWORD` | Yes | — | Password for the `carte` user |
| `USERID` | No | `1000` | UID of the container user — should match host UID (`id -u`) |
| `GROUPID` | No | `1000` | GID of the container user |
| `SUDO` | No | `false` | Grant `carte` user sudo access |
| `ADD_RSTUDIO` | No | `false` | Install and start RStudio Server |
| `ADD_OPENCPU` | No | `false` | Install and start OpenCPU |
| `ADD_SHINY` | No | `false` | Install and start Shiny Server |
| `AUTOSELECT_BLAS` | No | `false` | Auto-select CPU-optimized BLAS library |
| `PRIVILEGED_MODE` | No | `false` | Run with extended privileges (needed for CIFS mounts) |

## Container Ports

| Service | Port |
|---|---|
| RStudio | `8787` |
| Shiny | `3838` |
| OpenCPU HTTP | `80` |
| OpenCPU HTTPS | `443` |

Host port mappings are configured in `.env` via `RSTUDIO_HOST_PORT`, `SHINY_HOST_PORT`, and `OPENCPU_HTTP_HOST_PORT`.

## Troubleshooting

**Port already in use**

If a service fails to start with a port binding error, another process is using that port. Either stop the conflicting process or change the host port in `.env`:

```bash
# Find what's using port 8787
lsof -i :8787
# or
ss -tlnp | grep 8787
```

Then update the relevant port variable in `.env` (e.g. `RSTUDIO_HOST_PORT=8788`) and restart.

**Permission errors on mounted volumes**

Ensure `HOST_UID` in `.env` matches your host user ID:

```bash
id -u
```

**Viewing container logs**

```bash
# docker compose
docker compose logs rstudio

# docker run (if container is still running)
docker logs <container_id>
```

**RStudio or services not starting**

Services like RStudio are installed at container startup when `ADD_RSTUDIO=true`. This adds a few seconds on first run. Check logs if the service doesn't appear after ~30 seconds:

```bash
docker compose logs -f rstudio
```
