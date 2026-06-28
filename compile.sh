#!/bin/bash
# Particle Cloud-compatible compile wrapper for Oak (PlatformIO).
# Input:  /input  — sketch folder (main .ino/.cpp + optional lib/)
# Output: /output — firmware.bin, run.log, stderr.log on success

set -euo pipefail
INPUT="${INPUT_DIR:-/input}"
OUTPUT="${OUTPUT_DIR:-/output}"
CACHE="${CACHE_DIR:-/cache}"
WORK="/workspace/build"

mkdir -p "$OUTPUT" "$CACHE" "$WORK"
LOG="$OUTPUT/run.log"
ERR="$OUTPUT/stderr.log"

exec > >(tee -a "$LOG") 2> >(tee -a "$ERR" >&2)

echo "=== OakCore Particle Docker compile ==="
echo "Input: $INPUT"

if [ ! -d "$INPUT" ] || [ -z "$(ls -A "$INPUT" 2>/dev/null)" ]; then
  echo "ERROR: /input empty or missing"
  exit 1
fi

rm -rf "$WORK"/*
cp -a "$INPUT/." "$WORK/"

# Detect main sketch
SKETCH=$(find "$WORK" -maxdepth 1 -name '*.ino' | head -1)
if [ -z "$SKETCH" ]; then
  SKETCH=$(find "$WORK" -maxdepth 1 -name '*.cpp' | head -1)
fi
if [ -z "$SKETCH" ]; then
  echo "ERROR: no .ino or .cpp in input"
  exit 1
fi

if [ ! -f "$WORK/platformio.ini" ]; then
  cat > "$WORK/platformio.ini" <<'EOF'
[env:oak]
platform = espressif8266
board = oak
framework = arduino
EOF
fi

cd "$WORK"
echo "Running PlatformIO build..."
if pio run -e oak; then
  BIN=$(find .pio/build/oak -name 'firmware.bin' 2>/dev/null | head -1)
  if [ -n "$BIN" ] && [ -f "$BIN" ]; then
    cp "$BIN" "$OUTPUT/firmware.bin"
    echo "SUCCESS: $OUTPUT/firmware.bin"
    pio run -e oak -t size 2>/dev/null | tee "$OUTPUT/memory-use.log" || true
    exit 0
  fi
  echo "ERROR: build ok but firmware.bin not found"
  exit 2
else
  echo "ERROR: PlatformIO build failed"
  exit 1
fi
