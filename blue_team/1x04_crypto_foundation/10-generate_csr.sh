#!/bin/bash

echo "Generating ECC P-256 private key..."
openssl ecparam -genkey -name prime256v1 -out portal_key.pem

echo "Generating Certificate Signing Request (CSR)..."
openssl req -new -key portal_key.pem -out portal.csr \
    -subj "/C=US/ST=California/L=San Francisco/O=MedDefense Health Systems/OU=Information Technology/CN=portal.meddefense.local" \
    -addext "subjectAltName=DNS:portal.meddefense.local,DNS:www.portal.meddefense.local,DNS:meddefense.local"

echo "Inspecting CSR contents:"
openssl req -text -noout -in portal.csr
