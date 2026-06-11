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

# This Base64 string decodes exactly into your secure Nginx block
NGINX_CONF_B64="c2VydmVyIHsKICAgIGxpc3RlbiA0NDMgc3NsOwogICAgc2VydmVyX25hbWUgYXBpLmFkdmVudHVyZS1zdG9yeS1nZW5lcmF0b3IueHl6OwoKICAgIHNzbF9jZXJ0aWZpY2F0ZSAvZXRjL2xldHNlbmNyeXB0L2xpdmUvYXBpLmFkdmVudHVyZS1zdG9yeS1nZW5lcmF0b3IueHl6L2Z1bGxjaGFpbi5wZW07CiAgICBzc2xfY2VydGlmaWNhdGVfa2V5IC9ldGMvbGV0c2VuY3J5cHQvbGl2ZS9hcGkuYWR2ZW50dXJlLXN0b3J5LWdlbmVyYXRvci54eXovcHJpdmtleS5wZW07CgogICAgc3NsX3Byb3RvY29scyBUTFN2MS4yIFRMU3YxLjM7CiAgICBzc2xfY2lwaGVycyBISUdIOiFhTlVMTDshTUQ1OwoKICAgIGxvY2F0aW9uIC8gewogICAgICAgIHByb3h5X3Bhc3MgaHR0cDovLzEyNy4wLjAuMTo4MDAwOwogICAgICAgIHByb3h5X3NldF9oZWFkZXIgSG9zdCAkaG9zdDsKICAgICAgICBwcm94eV9zZXRfaGVhZGVyIFgtUmVhbC1JUEQgJHJlbW90ZV9hZGRyOwogICAgICAgIHByb3h5X3NldF9oZWFkZXIgWC1Gb3J3YXJkZWQtRm9yICRwcm94eV9hZGRfeF9mb3J3YXJkZWRfZm9yOwogICAgICAgIHByb3h5X3NldF9oZWFkZXIgWC1Gb3J3YXJkZWQtUHJvdG8gJHNjaGVtZTsKICAgIH0KfQo="

echo "$NGINX_CONF_B64" | base64 -d | sudo dd of=/etc/nginx/conf.d/ssl.conf status=none

# 3. Always restart Nginx to load the newly written SSL configurations
echo "Restarting Nginx to load secure configurations..."
sudo systemctl restart nginx
echo "HTTPS is now fully active on your custom domain!"