# carte-r

## **C**ontainerized **A**nalysis **R**un**T**ime **E**nvironment for **R**

## Overview

carte-r provides a customizable Docker container for data analysis using the R programming language.

- Docker image: [https://hub.docker.com/repository/docker/askrajiv/carte-r](https://hub.docker.com/repository/docker/askrajiv/carte-r)
- Presentations
  - [Talk at Boston Computational Biology and Bioinformatics Meetup](https://docs.google.com/presentation/d/12IYun6xaBOPVdTIMsmFnTdH7LfP26pOV0ZBdzP4MEsY/edit?usp=sharing)

## Aims

This project grew out of a need to run various scientific-computing and data-science workflows in R across multiple hosts in a reproducible manner. In particular the requirements were:

- Support for a configurable and feature-rich computational environment frequently needed to process and explore real-world data
- An IDE for exploratory data analysis and developing and testing R code
- The ability to quickly expose custom algorithms via APIs for enabling web applications

## Features

carte-r is a single Docker image that provides command-line access to a customized R environment with the ability to enable additional software components (RStudio, OpenCPU, Shiny) at runtime.

The image integrates several software components:

- The R analysis environment is based on the [rocker/r2u](https://github.com/rocker-org/r2u) image
  - Includes a version-specific R installation with 200+ packages from CRAN and Bioconductor focused on computational biology, data analysis, and report generation
  - Pre-configured CRAN and marutter PPA repositories provide easy access to 4000+ pre-compiled binary R packages
- Optional services enabled at runtime:
  - Browser-based IDE via [RStudio Server](https://posit.co/products/open-source/rstudio-server/)
  - [OpenCPU](https://www.opencpu.org/) server for HTTP-based R APIs
  - [Shiny](https://shiny.posit.co/r/articles/host/shiny-server/) server for interactive web applications
- CPU-specific BLAS library auto-selection at runtime (`AUTOSELECT_BLAS=true`): MKL for Intel, BLIS for AMD, OpenBLAS otherwise
- The [s6-overlay](https://github.com/just-containers/s6-overlay) init system to manage multiple processes within a single container

## Getting Started

### Using docker compose (recommended)

**Initial setup**

Clone the repo and navigate to the carte-r directory:

```bash
git clone https://github.com/rajivnarayan/carte.git
cd carte/carte-r
```

Copy the dotenv template to `.env` and edit as needed:

```bash
cp dotenv .env
```

Edit `.env` and set at minimum:
- `CARTE_PASSWORD` — password for the `carte` user (**required**, must not be left as default)
- `BIND_VOLUME_HOME` — full path to your home directory on the host
- `BIND_VOLUME_WORKSPACE` — full path to your workspace directory on the host
- `HOST_UID` — your host user ID (run `id -u` to check)

**Start a base container with command-line access**

```bash
docker compose run base
```

Type `R` to start the R interpreter.

**Start RStudio Server**

```bash
docker compose up rstudio
```

Access RStudio at http://localhost:8787 (or the port set by `RSTUDIO_HOST_PORT` in `.env`).

Login with username `carte` and the password set in `CARTE_PASSWORD`.

**Start a full container with RStudio, OpenCPU, and Shiny**

```bash
docker compose up full
```

- RStudio: http://localhost:8787
- OpenCPU: http://localhost:8080/ocpu
- Shiny: http://localhost:3838

### Using the docker command directly

Start a base container with R and mount the host `$HOME` at `/home/carte`:

```bash
docker run -it --rm \
  -e PASSWORD=<your_password> \
  -e USERID=$(id -u) \
  -v $HOME:/home/carte \
  askrajiv/carte-r:latest /init su carte
```

Start RStudio Server:

```bash
docker run -it --rm \
  -p 8787:8787 \
  -e PASSWORD=<your_password> \
  -e USERID=$(id -u) \
  -e ADD_RSTUDIO=true \
  -e SUDO=true \
  -v $HOME:/home/carte \
  -v /path/to/workspace:/home/carte/workspace \
  askrajiv/carte-r:latest /init
```

### Building a new image

```bash
./build.sh
```

Or manually:

```bash
docker build --platform=linux/amd64 \
  --no-cache=true \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg BUILD_VERSION="latest" \
  -f Dockerfile \
  -t askrajiv/carte-r:latest \
  assets/
```

### Static RStudio image

A pre-built image with RStudio baked in (faster startup, no install at runtime) is available at
[askrajiv/carte-r-rstudio](https://hub.docker.com/repository/docker/askrajiv/carte-r-rstudio).

To build and push it:

```bash
./build_rstudio.sh
```

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `PASSWORD` | Yes | — | Password for the `carte` user |
| `USERID` | No | `1000` | UID of the container user, should match host UID |
| `GROUPID` | No | `1000` | GID of the container user |
| `SUDO` | No | `false` | Add `carte` user to sudoers if `true` |
| `ADD_RSTUDIO` | No | `false` | Install and start RStudio Server if `true` |
| `ADD_OPENCPU` | No | `false` | Install and start OpenCPU if `true` |
| `ADD_SHINY` | No | `false` | Install and start Shiny Server if `true` |
| `AUTOSELECT_BLAS` | No | `false` | Auto-select CPU-optimized BLAS (MKL/BLIS/OpenBLAS) if `true` |
| `PRIVILEGED_MODE` | No | `false` | Run with extended privileges (needed for CIFS mounts) |

## Container Ports

Services run on the following ports within the container:

| Service | Port |
|---|---|
| RStudio | `8787` |
| Shiny | `3838` |
| OpenCPU HTTP | `80` |
| OpenCPU HTTPS | `443` |

Host port mappings are configured via `.env` (see `RSTUDIO_HOST_PORT`, `SHINY_HOST_PORT`, `OPENCPU_HTTP_HOST_PORT`).
