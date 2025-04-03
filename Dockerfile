FROM postgres:17.4

# Install build dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    postgresql-server-dev-17 \
    build-essential \
    git

# Build and install pgvector
RUN git clone https://github.com/pgvector/pgvector.git /tmp/pgvector && \
    cd /tmp/pgvector && \
    make && \
    make install && \
    rm -rf /tmp/pgvector
