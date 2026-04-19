FROM ghcr.io/home-assistant/amd64-base-python:3.12-alpine3.20

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    py3-virtualenv \
    git \
    curl \
    bash \
    build-base \
    libffi-dev \
    openssl-dev \
    musl-dev \
    gcc

# Create virtualenv to avoid system package conflicts
RUN python3 -m venv /opt/hermes-env

# Install hermes-agent into virtualenv
RUN /opt/hermes-env/bin/pip install --upgrade pip && \
    /opt/hermes-env/bin/pip install "hermes-agent[all]" || \
    /opt/hermes-env/bin/pip install "hermes-agent"

# Add venv to PATH
ENV PATH="/opt/hermes-env/bin:$PATH"

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]