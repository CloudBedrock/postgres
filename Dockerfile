# -----------------------------------------------------------------------------
# Stage 1: Builder – Build pgvector and pg_cron extensions
# -----------------------------------------------------------------------------
    FROM postgres:18.1 AS builder

    # Update and install build dependencies
    RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        postgresql-server-dev-17 \
        build-essential \
        git
    
    # Build and install pgvector
    RUN git clone https://github.com/pgvector/pgvector.git /tmp/pgvector && \
        cd /tmp/pgvector && \
        make && \
        make install
    
    # Build and install pg_cron
    RUN git clone https://github.com/citusdata/pg_cron.git /tmp/pg_cron && \
        cd /tmp/pg_cron && \
        make && \
        make install
    
    # -----------------------------------------------------------------------------
    # Stage 2: Final – Create a lean runtime image with only the necessary files
    # -----------------------------------------------------------------------------
    FROM postgres:17.7
    
    # Update the runtime image for security updates
    RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*
    
    # Copy installed extension files from builder stage
    COPY --from=builder /usr/lib/postgresql/ /usr/lib/postgresql/
    COPY --from=builder /usr/share/postgresql/ /usr/share/postgresql/
    
