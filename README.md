[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/cloudbedrock/postgres)
# PostgreSQL with pgvector

A ready-to-use Docker image for PostgreSQL 17.4 with the [pgvector](https://github.com/pgvector/pgvector) extension pre-installed, and intended for use with [Crib Ops](https://github.com/cloudbedrock/cribops-docs)

## Overview

This repository provides a Dockerfile that builds PostgreSQL with the pgvector extension, allowing you to work with vector embeddings and perform efficient similarity searches directly in your PostgreSQL database.

The image is built using a multi-stage build approach to keep the final image size minimal while including all necessary components.

## Features

- Based on the official PostgreSQL 17.4 image
- Pre-installed pgvector extension for vector similarity search
- Multi-stage build for minimal image size
- Includes latest security updates

## Quick Start

### Pull the image

```bash
docker pull cloudbedrock/postgres:latest
```

### Run a container

```bash
docker run -d \
  --name postgres-vector \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  yourusername/postgres-pgvector:latest
```

### Enable the extension

Connect to your PostgreSQL instance and run:

```sql
CREATE EXTENSION vector;
```

## Usage Examples

### Creating a table with vector data

```sql
CREATE TABLE items (
  id bigserial PRIMARY KEY,
  embedding vector(384),
  metadata jsonb
);
```

### Adding vector indexes

```sql
-- Create an index for approximate nearest neighbor search
CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100);

-- Or for exact nearest neighbor search (slower but precise)
CREATE INDEX ON items USING hnsw (embedding vector_cosine_ops);
```

### Performing similarity searches

```sql
-- Find the 5 most similar items using L2 distance
SELECT id, metadata, embedding <-> '[1,2,3,...]'::vector AS distance
FROM items
ORDER BY distance
LIMIT 5;

-- Find similar items using cosine distance
SELECT id, metadata, embedding <=> '[1,2,3,...]'::vector AS distance
FROM items
ORDER BY distance
LIMIT 5;
```

## Building the Image

If you want to build the image yourself:

```bash
git clone https://github.com/cloudbedrock/postgres.git
cd postgres-pgvector
docker build -t cloudbedrock/postgres:latest .
```

## Dockerfile

```dockerfile
# -----------------------------------------------------------------------------
# Stage 1: Builder – Build the pgvector extension
# -----------------------------------------------------------------------------
FROM postgres:17.4 AS builder

# Update and install build dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    postgresql-server-dev-17 \
    build-essential \
    git

# Clone, build, and install pgvector
RUN git clone https://github.com/pgvector/pgvector.git /tmp/pgvector && \
    cd /tmp/pgvector && \
    make && \
    make install

# -----------------------------------------------------------------------------
# Stage 2: Final – Copy over built extension into a clean runtime image
# -----------------------------------------------------------------------------
FROM postgres:17.4

# Update the runtime image to include any security updates
RUN apt-get update -y && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the installed pgvector extension files from the builder stage
COPY --from=builder /usr/lib/postgresql/ /usr/lib/postgresql/
COPY --from=builder /usr/share/postgresql/ /usr/share/postgresql/
```

## Environment Variables

This image uses all the same environment variables as the [official PostgreSQL image](https://hub.docker.com/_/postgres/). The most important ones are:

- `POSTGRES_PASSWORD`: Required. Sets the superuser password for PostgreSQL
- `POSTGRES_USER`: Optional. Used with POSTGRES_PASSWORD to set a user and its password. Defaults to `postgres`
- `POSTGRES_DB`: Optional. Defines a name for the default database. Defaults to `POSTGRES_USER` if not specified

## Volumes

The image exposes the `/var/lib/postgresql/data` volume for persisting the database data.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [PostgreSQL Project](https://www.postgresql.org/)
- [pgvector](https://github.com/pgvector/pgvector) - The open-source vector similarity search extension for PostgreSQL
