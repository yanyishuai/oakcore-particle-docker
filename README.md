# OakCore Particle Cloud Docker Buildpack

Docker image for **digistump/OakCore#32** — compile Oak sketches via PlatformIO with Particle-compatible I/O layout.

## Features

- Based on `python:3.11-slim` + PlatformIO
- Pre-installs `espressif8266` platform with `board = oak`
- Input/output contract matches Particle buildpack pattern:
  - **Input:** `/input` — sketch + optional `platformio.ini` + libraries
  - **Output:** `/output/firmware.bin`, `run.log`, `stderr.log`, `memory-use.log`

## Build

```bash
docker build -t oakcore-particle-docker .
```

## Run

```bash
mkdir -p /tmp/input /tmp/output /tmp/cache
cp your_sketch.ino /tmp/input/
docker run --rm \
  -v /tmp/input:/input \
  -v /tmp/output:/output \
  -v /tmp/cache:/cache \
  oakcore-particle-docker
ls /tmp/output
```

## OakCore release URL

Update `platformio.ini` or Dockerfile if a pinned Oak core release is required — default uses PlatformIO's bundled Oak board manifest.

## Bounty

Submitted for [digistump/OakCore#32](https://github.com/digistump/OakCore/issues/32) ($100).

Wallet: `Do4v7foHJvRJLpRRoGaVPWX6DDEjX3yTK7J91gpwUQpE`
