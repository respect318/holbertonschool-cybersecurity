# 15-Dockerfile.securedev
FROM python:3.11-slim

# Metadata
LABEL maintainer="yourname@example.com"
LABEL description="Secure Python 3.11 Development Environment with linters, formatter, type checking, and testing tools"

# Set non-root user
RUN useradd -m -u 1000 devuser

# Set working directory
WORKDIR /home/devuser/app

# Install required Python tools
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends curl build-essential && \
    python -m pip install --upgrade pip setuptools wheel && \
    pip install pylint black pytest mypy && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER devuser

# HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Default command
CMD ["python3"]
