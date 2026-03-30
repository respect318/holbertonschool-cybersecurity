# Use slim Python base
FROM python:3.11-slim

# Create non-root user
RUN useradd -m appuser

# Set working directory
WORKDIR /app

# Switch to non-root user
USER appuser

# Note: Do NOT hardcode secrets here
# Correct way: pass secrets at runtime with environment variables (-e DB_PASSWORD=...)

# Default command (just show environment variables)
CMD ["sh", "-c", "echo 'DB_HOST='$DB_HOST 'DB_USER='$DB_USER 'DB_PASSWORD='$DB_PASSWORD"]
