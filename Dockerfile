# Dockerfile
FROM ubuntu:plucky

ARG DEBIAN_FRONTEND=noninteractive
ARG UPSTREAM_VERSION=auto         # "auto" resolves the latest from versions.json
ARG EDITION=Tdarr_Node            # Tdarr_Node or Tdarr_Server
ARG TARGETOS
ARG TARGETARCH

# Base tools, add-apt-repository, unzip/curl
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      software-properties-common ca-certificates curl unzip gnupg wget jq && \
    rm -rf /var/lib/apt/lists/*

# Intel graphics PPA
RUN add-apt-repository -y ppa:kobuk-team/intel-graphics && \
    apt-get update

# Intel Level Zero / OpenCL / metrics
RUN apt-get install -y --no-install-recommends \
      libze-intel-gpu1 libze1 intel-metrics-discovery \
      intel-opencl-icd clinfo intel-gsc

# VA-API + VPL + legacy MFX
RUN apt-get install -y --no-install-recommends \
      intel-media-va-driver-non-free libmfx-gen1 libvpl2 libvpl-tools \
      libva-glx2 va-driver-all vainfo

# ffmpeg + Tesseract runtime + English data
RUN apt-get update && apt-get install -y --no-install-recommends \
      ffmpeg tesseract-ocr tesseract-ocr-eng libleptonica-dev mkvtoolnix handbrake-cli && \
    # Compat shim for binaries expecting libtesseract.so.4
    ln -sf /usr/lib/x86_64-linux-gnu/libtesseract.so.5 /usr/lib/x86_64-linux-gnu/libtesseract.so.4 && \
    # Create ABI-compat symlinks for the old CCExtractor build
    ln -sf /usr/lib/x86_64-linux-gnu/libleptonica.so.6 /usr/lib/x86_64-linux-gnu/liblept.so.5 || true && \
    rm -rf /var/lib/apt/lists/*

# Create configs directory
RUN mkdir -p /root/Tdarr_Node

# Dynamically download & unpack Tdarr Node based on UPSTREAM_VERSION and platform
RUN set -euo pipefail; \
    # Map arch to Tdarr naming convention
    case "${TARGETOS}-${TARGETARCH}" in \
      linux-amd64) PLATFORM_DIR="linux_x64" ;; \
      linux-arm64) PLATFORM_DIR="linux_arm64" ;; \
      *) echo "Unsupported platform: ${TARGETOS}-${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    if [ "${UPSTREAM_VERSION}" = "auto" ]; then \
      echo "Resolving latest Tdarr version from versions.json..."; \
      ver="$(curl -sSfL https://storage.tdarr.io/versions.json | jq -r 'keys[]' | sort -V | tail -n1)"; \
    else \
      ver="${UPSTREAM_VERSION}"; \
    fi; \
    echo "Using Tdarr version: ${ver} (${PLATFORM_DIR})"; \
    url="https://storage.tdarr.io/versions/${ver}/${PLATFORM_DIR}/${EDITION}.zip"; \
    echo "Downloading ${url}"; \
    cd /root/Tdarr_Node; \
    curl -fsSL "$url" -o Tdarr_Node.zip; \
    unzip -o Tdarr_Node.zip; \
    rm -f Tdarr_Node.zip; \
    echo "$ver" > /root/Tdarr_Node/VERSION

WORKDIR /root/Tdarr_Node

ENTRYPOINT ["/root/Tdarr_Node/Tdarr_Node"]
