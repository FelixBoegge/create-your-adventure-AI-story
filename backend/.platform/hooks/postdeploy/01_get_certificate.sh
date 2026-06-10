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
    sudo tee /etc/nginx/conf.d/ssl.conf > /dev/null <<EOF
server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    # 4. Start Nginx with HTTPS enabled!
    sudo systemctl start nginx
    echo "HTTPS configuration applied and Nginx started successfully!"
else
    # Defensive fallback: If Certbot fails, restart Nginx on Port 80 so the app stays online!
    echo "Certbot failed to acquire certificate. Restarting standard Nginx on Port 80..."
    sudo systemctl start nginx
    exit 1
fi