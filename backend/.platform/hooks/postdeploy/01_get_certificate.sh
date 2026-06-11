#!/bin/bash

DOMAIN="api.adventure-story-generator.xyz"
EMAIL="felixboegge@googlemail.com"

# 1. Acquire Let's Encrypt certificate ONLY if it doesn't exist yet
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "Certificate not found. Starting Let's Encrypt acquisition..."

    # Stop Nginx to free port 80 for Certbot
    sudo systemctl stop nginx

    # Run Certbot in standalone mode
    if sudo certbot certonly --standalone -n -d $DOMAIN --agree-tos --email $EMAIL --no-eff-email; then
        echo "Certbot successfully acquired certificate!"
    else
        echo "Certbot failed to acquire certificate. Restarting standard Nginx..."
        sudo systemctl start nginx
        exit 1
    fi
else
    echo "Certificate already exists on disk. Skipping certificate acquisition step."
fi

# 2. ALWAYS recreate the custom Nginx SSL configuration (since EB overwrites conf.d on every deploy!)
echo "Applying Nginx SSL configuration..."

sudo printf 'server {
    listen 443 ssl;
    server_name api.adventure-story-generator.xyz;

    ssl_certificate /etc/letsencrypt/live/api.adventure-story-generator.xyz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.adventure-story-generator.xyz/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}' | sudo tee /etc/nginx/conf.d/ssl.conf

# 3. Always restart Nginx to load the newly written SSL configurations
echo "Restarting Nginx to load secure configurations..."
sudo systemctl restart nginx
echo "HTTPS is now fully active on your custom domain!"