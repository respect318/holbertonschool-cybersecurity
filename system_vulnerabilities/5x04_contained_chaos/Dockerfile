# Base image: minimal Python 3.11
FROM python:3.11-slim

# Metadata
LABEL maintainer="yourname@example.com"
LABEL description="Secure Python 3.11 development environment"

# Create non-root user
ARG USER=devuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $USER \
    && useradd -m -u $UID -g $GID -s /bin/bash $USER

# Set working directory
WORKDIR /app

# Switch to non-root user
USER $USER

# Install Python development tools
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir \
        pylint \
        black \
        pytest \
        mypy \
    && python -m venv /app/venv

# Expose /app for mounting code
VOLUME ["/app"]

# Configure HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD python -c "import sys; sys.exit(0)"

# Default command
CMD ["bash"]
