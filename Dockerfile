FROM ghcr.io/qltysh/qlty

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        jq \
        build-essential \
    && curl -sSL \
        -o /usr/local/bin/sarif-converter \
        https://gitlab.com/ignis-build/sarif-converter/-/releases/permalink/latest/downloads/bin/sarif-converter-linux-amd64 \
    && chmod +x /usr/local/bin/sarif-converter \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
