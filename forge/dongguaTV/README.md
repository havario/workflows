# dongguaTV

```yaml
tee docker-compose.yaml >/dev/null <<'EOF'
---
services:
  dongguatv:
    image: honeok/dongguatv
    container_name: dongguatv
    restart: unless-stopped
    ports:
      - 3000:3000
    environment:
      TZ: Asia/Shanghai
      TMDB_API_KEY: your_api_key
      # PROXY_URL:
      # ADMIN_PASSWD:
    network_mode: bridge
EOF
```
