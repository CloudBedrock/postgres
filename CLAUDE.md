# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Docker-based PostgreSQL distribution that extends the official PostgreSQL 17.4 image with the pgvector extension for vector similarity search capabilities.

## Architecture

The project consists of:
- **Dockerfile**: Multi-stage build that installs pgvector from source
- **GitHub Actions workflow**: Automated multi-architecture builds and releases

## Build Commands

### Local Development
```bash
# Build the Docker image locally
docker build -t postgres-pgvector .

# Run the container
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword postgres-pgvector
```

### Release Process
Releases are triggered by pushing git tags starting with 'v':
```bash
git tag v1.0.0
git push origin v1.0.0
```

This triggers the GitHub Actions workflow that:
1. Builds AMD64 and ARM64 images
2. Pushes to both ghcr.io and docker.io registries
3. Creates multi-architecture manifests

## Key Files

- **Dockerfile**: Installs pgvector extension into postgres:17.4 base image
- **.github/workflows/release.yaml**: CI/CD pipeline for multi-arch builds and releases

## Published Images

The workflow publishes to:
- `ghcr.io/cloudbedrock/postgres:<version>`
- `docker.io/cloudbedrock/postgres:<version>`

Both with architecture-specific tags (`-amd64`, `-arm64`) and multi-arch manifests.

## Development Notes

- The pgvector extension is built from source during the Docker build process
- No test suite currently exists in the repository
- ARM64 builds run on self-hosted macOS runners

## Automated Updates

The repository includes automation to keep the PostgreSQL image up to date:

### Scheduled Updates (.github/workflows/scheduled-update.yaml)
- Runs daily at 2 AM UTC
- Checks for new PostgreSQL 17.x versions
- Automatically updates Dockerfile and creates a new release tag
- Version format: `v17.x-YYYYMMDD` (e.g., `v17.4-20240723`)

### Dependabot (.github/dependabot.yml)
- Monitors Docker base image updates
- Monitors GitHub Actions updates
- Creates pull requests for updates
- Restricted to PostgreSQL 17.x versions only (won't auto-update to 18.x)

### Manual Update
To force a rebuild without waiting for the schedule:
1. Go to Actions → "Scheduled Update Check"
2. Click "Run workflow"
3. Check "Force rebuild even if no updates"