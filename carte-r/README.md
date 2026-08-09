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

Set at minimum:
- `CARTE_PASSWORD` — password for the `carte` user (**required**)
- `BIND_VOLUME_HOME` — full path to your home directory on the host
- `BIND_VOLUME_WORKSPACE` — full path to your workspace on the host
- `HOST_UID` — your host user ID (`id -u`)

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

### Using docker run

**Base container:**

```bash
docker run -it --rm \
  -e PASSWORD=<your_password> \
  -e USERID=$(id -u) \
  -v $HOME:/home/carte \
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
