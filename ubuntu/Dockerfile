# syntax=docker/dockerfile:1
FROM ubuntu:latest AS base
RUN apt-get update && apt-get install -y \
  bzip2 \
  clang \
  git \
  tar \
  wget \
  && rm -rf /var/lib/apt/lists/*

FROM base AS cross-compiler-provider
RUN GCCARM_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2" && \
    wget -O /tmp/gcc-arm-none-eabi.tar.bz2 ${GCCARM_LINK} && \
    echo "2383e4eb4ea23f248d33adc70dc3227e /tmp/gcc-arm-none-eabi.tar.bz2" > /tmp/check.md5 && \
    md5sum --status --check /tmp/check.md5 && \
    tar xvf /tmp/gcc-arm-none-eabi.tar.bz2 --strip-components=1 -C /usr && \
    rm -rf /tmp/gcc-arm-none-eabi.tar.bz2 && \
    rm -rf /tmp/check.md5 && \
    rm -rf /usr/share/doc

FROM base AS mold-provider
RUN git clone https://github.com/rui314/mold.git && \
    cd mold && \
    git checkout v1.4.1 && \
    apt-get update && \
    ./install-build-deps.sh && \
    make -j$(nproc) CXX=clang++ && \
    make install

FROM base AS embedded-builder
COPY --from=cross-compiler-provider /usr /usr
COPY --from=mold-provider /usr/local/bin /usr/local/bin
RUN apt-get update && apt-get install -y \
  clang \
  cmake \
  ninja-build \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir --upgrade pip && \
  pip3 install --no-cache-dir conan


        
