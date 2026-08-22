# carte-mcr

## **C**ontainerized **A**nalysis **R**un**T**ime **E**nvironment for **MCR**

## Overview

carte-mcr provides Docker images bundling the [MATLAB Compiler Runtime (MCR)](https://www.mathworks.com/products/compiler/matlab-runtime.html), enabling execution of compiled MATLAB programs without a MATLAB license.

- Docker image: [askrajiv/carte-mcr-v95](https://hub.docker.com/repository/docker/askrajiv/carte-mcr-v95)

## Available Versions

| Directory | MATLAB Release | MCR Version | Base Image |
|---|---|---|---|
| `v84/` | R2014b | v84 | bitnami/minideb |
| `v93/` | R2017b | v93 | bitnami/minideb:stretch |
| `v95/` | R2018b | v95 | bitnami/minideb:bookworm |
| `r2021b/` | R2021b | v911 | bitnami/minideb:buster |

The **v95** image (R2018b) is the currently published and supported version.

## Features

- Minimal Debian-based image with MCR installed at `/opt/mcr/<version>`
- Configured library paths via `MCR_LD_LIBRARY_PATH` for running compiled MATLAB executables without modifying `LD_LIBRARY_PATH`
- `sigtool_runtime/` — extends `carte-mcr-v95` with CMap sig-tool scripts for executing Connectivity Map algorithms

## Usage

### Running a compiled MATLAB executable

Pull the image and use `MCR_LD_LIBRARY_PATH` when invoking your compiled binary:

```bash
docker run --rm \
  -v /path/to/your/binary:/usr/local/bin/myapp \
  askrajiv/carte-mcr-v95:latest \
  bash -c 'LD_LIBRARY_PATH=$MCR_LD_LIBRARY_PATH /usr/local/bin/myapp <args>'
```

### Environment Variables

| Variable | Description |
|---|---|
| `MCR_ROOT` | Path to the MCR installation (`/opt/mcr/v95`) |
| `MCR_LD_LIBRARY_PATH` | Library paths required to run compiled MATLAB executables |
| `XAPPLRESDIR` | Path to MCR X11 app defaults |

## Building Locally

```bash
cd v95
docker build --no-cache=true \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg BUILD_VERSION="test" \
  -t carte-mcr-v95:test .
```

> **Note:** The build downloads the MCR installer (~1.8 GB) from MathWorks and may take several minutes.

## CI/CD

The GitHub Actions workflow `.github/workflows/build-carte-mcr.yml` builds and pushes `askrajiv/carte-mcr-v95` to Docker Hub on pushes to `master` that touch `carte-mcr/**`, and on manual dispatch. Required secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.
