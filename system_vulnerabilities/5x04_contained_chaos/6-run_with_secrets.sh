#!/bin/bash
echo "=== Running container with secrets safely ==="

# Example runtime secrets
DB_HOST="myhost"
DB_USER="myuser"
DB_PASSWORD="mypass"

# Run the container passing secrets via environment variables
docker run -e DB_HOST=$DB_HOST -e DB_USER=$DB_USER -e DB_PASSWORD=$DB_PASSWORD devstream-nosecrets:v1
