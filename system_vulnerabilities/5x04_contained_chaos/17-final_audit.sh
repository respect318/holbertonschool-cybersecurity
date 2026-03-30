#!/bin/bash
echo "=== Final Security Audit ==="

# Variables
VULNERABLE_IMAGE="devstream-vulnerable"
SECURE_IMAGE="secure-python-dev:v1"

# Ensure docker-bench-security is available
if [ ! -d "./docker-bench-security" ]; then
  echo "Cloning docker-bench-security..."
  git clone https://github.com/docker/docker-bench-security.git >/dev/null 2>&1
fi

echo -e "\nAuditing Vulnerable Image (${VULNERABLE_IMAGE}):"
docker run -it --rm --name bench-vuln \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /usr/lib:/usr/lib:ro \
  -v /etc:/etc:ro \
  -v /boot:/boot:ro \
  -v /usr/bin/docker:/usr/bin/docker:ro \
  docker-bench-security/docker-bench-security.sh -c container -i ${VULNERABLE_IMAGE}

echo -e "\nAuditing Secure Image (${SECURE_IMAGE}):"
docker run -it --rm --name bench-secure \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /usr/lib:/usr/lib:ro \
  -v /etc:/etc:ro \
  -v /boot:/boot:ro \
  -v /usr/bin/docker:/usr/bin/docker:ro \
  docker-bench-security/docker-bench-security.sh -c container -i ${SECURE_IMAGE}

echo -e "\nAudit Complete. Compare PASS/WARN counts to measure improvement."
