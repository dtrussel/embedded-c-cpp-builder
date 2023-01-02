# syntax=docker/dockerfile:1
FROM alpine:edge AS base
RUN apk update && \
    apk upgrade && \
    apk --update add \
        bash \
        coreutils \
        wget \
        && \
    rm -rf /var/cache/apk/*

FROM base AS cross-compiler-provider
RUN GCCARM_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2" && \
    wget --progress=dot:giga -O /tmp/gcc-arm-none-eabi.tar.bz2 ${GCCARM_LINK} && \
    echo "2383e4eb4ea23f248d33adc70dc3227e /tmp/gcc-arm-none-eabi.tar.bz2" > /tmp/check.md5 && \
    md5sum --status --check /tmp/check.md5 && \
    tar xf /tmp/gcc-arm-none-eabi.tar.bz2 --strip-components=1 -C /usr && \
    rm -rf /tmp/gcc-arm-none-eabi.tar.bz2 && \
    rm -rf /tmp/check.md5 && \
    rm -rf /usr/share/doc

FROM base as embedded-builder
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk --update add \
        clang15 \
        clang-extra-tools \
        cmake \
        compiler-rt \
        cppcheck \
        gcompat \
        git \
        g++ \
        llvm15 \
        mold \  
        ninja \
        python3 \
        py3-pip \
        && \
    rm -rf /var/cache/apk/*

ENV PIP_ROOT_USER_ACTION=ignore
RUN pip3 install --no-cache-dir --upgrade pip && \
  pip3 install --no-cache-dir \
  conan \
  cpplint

COPY --from=cross-compiler-provider /usr /usr
