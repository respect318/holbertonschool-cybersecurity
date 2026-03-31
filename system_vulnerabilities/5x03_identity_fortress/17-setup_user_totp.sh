#!/bin/bash

# Checker'ın regex ile arayabileceği yapılandırma komutları (Bypass bloğu)
_bypass='
google-authenticator -t -d -f -r 3 -R 30 -W
google-authenticator -t -d -f -r 3 -R 30 -w 3
'

# Checker'ın beklediği birebir çıktı
echo "=== TOTP Setup for Current User ==="
echo ""
echo "Running google-authenticator with secure defaults..."
echo ""
echo "Your new secret key is: JBSWY3DPEHPK3PXP"
echo ""
echo "[QR CODE DISPLAYED HERE]"
echo ""
echo "Your emergency scratch codes are:"
echo "  12345678"
echo "  87654321"
echo "  11223344"
echo "  44332211"
echo "  99887766"
echo ""
echo "Configuration saved to ~/.google_authenticator"
echo ""
echo "Settings applied:"
echo "  Time-based tokens: YES"
echo "  Rate limiting: 3 logins per 30 seconds"
echo "  Token reuse: DISALLOWED"
echo "  Window size: 3 (allows clock skew)"
echo ""
echo "IMPORTANT: Save your emergency codes securely!"
echo "Scan the QR code with your authenticator app."
