FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/hermes-env/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    git \
    curl \
    bash \
    build-essential \
    libffi-dev \
    libssl-dev \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create virtualenv
RUN python3 -m venv /opt/hermes-env

# Install hermes-agent v0.10.0 from GitHub tag
RUN /opt/hermes-env/bin/pip install --upgrade pip && \
    /opt/hermes-env/bin/pip install "git+https://github.com/NousResearch/hermes-agent.git@v2026.4.16"

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]