#!/bin/bash

DOMAIN="api.adventure-story-generator.xyz"
EMAIL="felixboegge@googlemail.com"

# Check if certificate already exists
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "Certificate already exists. Skipping acquisition."
    exit 0
fi

echo "Certificate not found. Starting Let's Encrypt acquisition..."

# 1. Stop Nginx to free port 80 for Certbot
sudo systemctl stop nginx

# 2. Run Certbot in standalone mode to verify domain and generate certificates
if sudo certbot certonly --standalone -n -d $DOMAIN --agree-tos --email $EMAIL --no-eff-email; then
    echo "Certbot successfully acquired certificate. Creating Nginx SSL configuration..."

    # 3. Create the custom Nginx SSL configuration file dynamically
    sudo tee /etc/nginx/conf.d/ssl.conf > /dev/null <