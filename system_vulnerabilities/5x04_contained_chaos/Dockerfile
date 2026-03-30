# Stage 1: Builder
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y gcc make build-essential python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy app source (example)
COPY . .

# Install Python dependencies in builder
RUN pip install --upgrade pip && pip install flask --no-cache-dir

# Stage 2: Runtime
FROM python:3.11-slim

# Create non-root user
RUN useradd -m appuser

WORKDIR /app
USER appuser

# Copy only runtime artifacts from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /app /app

# Default command
CMD ["python3", "app.py"]
