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
