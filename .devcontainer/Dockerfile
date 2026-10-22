# SPDX-License-Identifier: GPL-2.0-only

FROM debian:stable-slim

# Install essential low-level build tools and NASM for pure Assembly compilation
RUN apt-get update && apt-get install -y \
    nasm \
    make \
    mtools \
    xorriso \
    dosfstools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Default command to keep the container ready
CMD ["/bin/bash"]
