FROM mcr.microsoft.com/playwright:v1.39.0-jammy

# Install netlify-cli, serve, and jq
RUN npm install -g netlify-cli serve && \
    apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
