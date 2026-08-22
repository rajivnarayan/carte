# CARTE - Container based Analysis RunTime Environments

CARTE is a collection of Docker-based runtime environments for reproducible data analysis.

## Environments

| Environment | Description | Docker Hub |
|---|---|---|
| [carte-r](carte-r/) | R analysis environment with optional RStudio, OpenCPU, and Shiny Server | [askrajiv/carte-r](https://hub.docker.com/repository/docker/askrajiv/carte-r) |
| [carte-py](carte-py/) | Python analysis environment (Conda-based) | — |
| [carte-mcr](carte-mcr/) | MATLAB Compiler Runtime (MCR) environment | [askrajiv/carte-mcr-v95](https://hub.docker.com/repository/docker/askrajiv/carte-mcr-v95) |

Each subdirectory is an independent subproject with its own Dockerfile and documentation.
