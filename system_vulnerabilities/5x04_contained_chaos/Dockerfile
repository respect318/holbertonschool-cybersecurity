FROM python:3.11-slim

# Create non-root user
RUN useradd -m appuser

WORKDIR /app
USER appuser

# Copy application code
COPY . .

# Install minimal runtime dependencies
RUN pip install --no-cache-dir flask

# Expose Flask default port
EXPOSE 5000

# Healthcheck: every 30s, timeout 10s, 3 retries
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Default command to run app
CMD ["python3", "app.py"]
