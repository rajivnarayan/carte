# AGENTS.md

Guidance for AI agents working on this repository.

## Repository Overview

CARTE (Container based Analysis RunTime Environments) is a collection of Docker-based runtime environments for data analysis. Each subdirectory is an independent subproject with its own Dockerfile, build scripts, and configuration.

| Directory | Description |
|---|---|
| `carte-r/` | Containerized R environment with optional RStudio, OpenCPU, and Shiny Server |
| `carte-py/` | Containerized Python environment (Conda-based) |
| `carte-mcr/` | Containerized MATLAB Compiler Runtime (MCR) environment |

## Repo Structure

```
carte/
├── carte-r/
│   ├── Dockerfile              # Main image build
│   ├── Dockerfile.rstudio      # Static RStudio variant (FROM carte-r)
│   ├── docker-compose.yml      # Compose services: base, rstudio, opencpu, shiny, full
│   ├── dotenv                  # Template for .env — copy to .env before use
│   ├── build.sh                # Build the main carte-r image
│   ├── build_rstudio.sh        # Build the static RStudio image
│   ├── assets/                 # Files copied into the image (entrypoint, s6 services, etc.)
│   └── bin/                    # Helper scripts
├── carte-py/
│   ├── Dockerfile
│   └── environment.yml         # Conda environment spec
├── carte-mcr/
│   ├── Dockerfile
│   └── sigtool_runtime/        # MCR runtime variant
└── .github/workflows/
    └── build-carte-r.yml       # CI: builds and pushes carte-r images to Docker Hub on master
```

## Docker Images

All images are published to Docker Hub under `askrajiv/`:

| Image | Docker Hub |
|---|---|
| `carte-r` | [askrajiv/carte-r](https://hub.docker.com/repository/docker/askrajiv/carte-r) |
| `carte-r-rstudio` | [askrajiv/carte-r-rstudio](https://hub.docker.com/repository/docker/askrajiv/carte-r-rstudio) |

Do not reference `quay.io` or any other registry for these images.

## CI/CD

- The GitHub Actions workflow `.github/workflows/build-carte-r.yml` triggers on pushes to `master` that touch `carte-r/**`, and on manual dispatch.
- It builds and pushes both `askrajiv/carte-r` and `askrajiv/carte-r-rstudio` to Docker Hub.
- Required repository secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

## Conventions

- **Branching:** Use descriptive branch names with a prefix, e.g. `docs/`, `feat/`, `fix/`, `chore/`.
- **Commits:** Follow the conventional commits style: `type: short description`. Types in use: `feat`, `fix`, `docs`, `chore`, `ci`.
- **PRs:** Reference the related GitHub issue in the PR body using `Closes #N`.
- **No secrets in code:** Never hardcode passwords, tokens, or credentials. Use environment variables or `.env` (which is gitignored).

## Key Files to Know

- `carte-r/dotenv` — template for all runtime configuration; copy to `.env` before running compose
- `carte-r/docker-compose.yml` — defines `base`, `rstudio`, `opencpu`, `shiny`, and `full` services
- `carte-r/assets/root/entrypoint.sh` — container entrypoint, handles user setup and service activation
- `carte-r/assets/root/etc/cont-init.d/` — s6-overlay init scripts that install optional services at startup

## Common Tasks

**Build carte-r locally:**
```bash
cd carte-r && ./build.sh
```

**Run locally with compose:**
```bash
cd carte-r
cp dotenv .env   # edit .env first
docker compose up rstudio
```

**Update README:**
The primary user-facing documentation is `carte-r/README.md`. Keep usage examples, environment variable tables, and port tables in sync with `docker-compose.yml` and `dotenv`.
