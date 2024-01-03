FROM nvidia/cuda:12.1.1-devel-ubuntu22.04
ENV PATH="/usr/local/cuda/bin:${PATH}"
RUN apt update && \
	apt install -y \
		lsb-release \
		curl \
		ca-certificates \
		gnupg \
		coreutils \
		sudo \
		openssl
RUN echo "deb [trusted=yes] https://apt.postgresml.org $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgresml.list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null

# Install build-essential tools and required packages
RUN apt-get update && \
    apt-get install -y build-essential curl wget git jq cmake gnupg postgresql-common apt-transport-https lsb-release protobuf-c-compiler libprotobuf-c-dev postgresql-server-dev-15 libkrb5-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone timescaledb source code from GitHub
RUN git clone https://github.com/timescale/timescaledb && \
    cd timescaledb && \
    git checkout 2.12.2 && \
    ./bootstrap && \
    cd build && make && \
    make install

ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y && apt install git postgresml-15 postgresql-contrib-15 postgresml-dashboard -y
RUN git clone --branch v0.5.0 https://github.com/pgvector/pgvector && \
cd pgvector && \
echo "trusted = true" >> vector.control && \
	make && \
	make install

COPY entrypoint.sh /app/entrypoint.sh
COPY dashboard.sh /app/dashboard.sh

COPY --chown=postgres:postgres local_dev.conf /etc/postgresql/15/main/conf.d/01-local_dev.conf
COPY --chown=postgres:postgres pg_hba.conf /etc/postgresql/15/main/pg_hba.conf

RUN echo "include_dir = 'conf.d'" >> /etc/postgresql/15/main/postgresql.conf


ENTRYPOINT ["bash", "/app/entrypoint.sh"]
