# syntax=docker/dockerfile:1.2
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
    mkdir mold/build && \
    cd mold/build && \
    git checkout v1.11.0 && \
    apt-get update && \
    ../install-build-deps.sh && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ .. && \
    cmake --build . -j $(nproc) && \
    cmake --install .

FROM base AS doxygen-provider
ARG DOXYGEN_VERSION="1.9.6"
ARG DOXYGEN_MD5="b6193a16bc5128597f5affd878dbd7b7"
RUN DOXYGEN_LINK="https://www.doxygen.nl/files/doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz" && \
    wget -O /tmp/doxygen.tar.gz ${DOXYGEN_LINK} && \
    echo "${DOXYGEN_MD5} /tmp/doxygen.tar.gz" > /tmp/check.md5 && \
    md5sum --status --check /tmp/check.md5 && \
    tar xvf /tmp/doxygen.tar.gz --strip-components=1 -C /usr && \
    rm -rf /tmp/check.md5

FROM base AS embedded-builder
COPY --from=cross-compiler-provider /usr /usr
COPY --from=mold-provider /usr/local/bin /usr/local/bin
COPY --from=doxygen-provider /usr/bin /usr/bin
RUN apt-get update && apt-get install -y \
  clang \
  cmake \
  graphviz \
  ninja-build \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,source=resources,target=/tmp/resources \
  pip3 install --no-cache-dir --upgrade pip && \
  pip3 install --no-cache-dir -r /tmp/resources/requirements.txt


        
