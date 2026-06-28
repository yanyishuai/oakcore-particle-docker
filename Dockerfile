FROM python:3.11-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir -U platformio

# Pre-install ESP8266 platform + Oak board support
RUN pio platform install espressif8266 \
    && pio boards espressif8266 | grep -i oak || true

ENV PLATFORMIO_CORE_DIR=/root/.platformio

COPY compile.sh /usr/local/bin/compile-oak
RUN chmod +x /usr/local/bin/compile-oak

WORKDIR /workspace
VOLUME ["/input", "/output", "/cache"]

ENTRYPOINT ["/usr/local/bin/compile-oak"]
