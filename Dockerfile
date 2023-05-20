# syntax=docker/dockerfile:1.2
FROM ubuntu:latest AS base
RUN apt-get update && apt-get install -y \
  xz-utils \
  git \
  tar \
  wget \
  && rm -rf /var/lib/apt/lists/*

FROM base AS cross-compiler-provider
ARG GCCARM_MD5="f3d1d32c8ac58f1e0f9dbe4bc56efa05"
RUN GCCARM_LINK="https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz?rev=7bd049b7a3034e64885fa1a71c12f91d&hash=732D909FA8F68C0E1D0D17D08E057619" && \
  wget -O /tmp/gcc-arm-none-eabi.tar.xz ${GCCARM_LINK} && \
  echo "${GCCARM_MD5} /tmp/gcc-arm-none-eabi.tar.xz" > /tmp/check.md5 && \
  md5sum --status --check /tmp/check.md5 && \
  tar xvf /tmp/gcc-arm-none-eabi.tar.xz --strip-components=1 -C /usr

FROM base AS mold-provider
ARG MOLD_VERSION="1.11.0"
ARG MOLD_MD5="b2ac2661c8c3ef93d5691019f2e1ca1a"
RUN MOLD_LINK="https://github.com/rui314/mold/releases/download/v${MOLD_VERSION}/mold-${MOLD_VERSION}-x86_64-linux.tar.gz" && \
  wget -O /tmp/mold.tar.gz ${MOLD_LINK} && \
  echo "${MOLD_MD5} /tmp/mold.tar.gz" > /tmp/check.md5 && \
  md5sum --status --check /tmp/check.md5 && \
  tar xvf /tmp/mold.tar.gz --strip-components=1 -C /usr

FROM base AS doxygen-provider
ARG DOXYGEN_VERSION="1.9.6"
ARG DOXYGEN_MD5="b6193a16bc5128597f5affd878dbd7b7"
RUN DOXYGEN_LINK="https://www.doxygen.nl/files/doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz" && \
  wget -O /tmp/doxygen.tar.gz ${DOXYGEN_LINK} && \
  echo "${DOXYGEN_MD5} /tmp/doxygen.tar.gz" > /tmp/check.md5 && \
  md5sum --status --check /tmp/check.md5 && \
  tar xvf /tmp/doxygen.tar.gz --strip-components=1 -C /usr

FROM base AS llvm-provider
ARG LLVM_VERSION="16"
# empty version = latest stable release
RUN apt-get update && apt-get install -y \
  lsb-release\
  software-properties-common \
  gnupg  && \
  wget https://apt.llvm.org/llvm.sh && \
  chmod +x llvm.sh && \
  ./llvm.sh ${LLVM_VERSION} all

FROM base AS embedded-builder
COPY --from=cross-compiler-provider /usr /usr
COPY --from=mold-provider /usr/ /usr/
COPY --from=doxygen-provider /usr/bin /usr/bin
COPY --from=llvm-provider /usr/ /usr/

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
  cmake \
  cppcheck \
  graphviz \
  latexmk \
  ninja-build \
  texlive-latex-recommended \
  texlive-fonts-recommended \
  tex-gyre \
  texlive-latex-extra \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,source=resources,target=/tmp/resources \
  pip3 install --no-cache-dir --upgrade pip && \
  pip3 install --no-cache-dir -r /tmp/resources/requirements.txt

FROM embedded-builder AS embedded-developer
# Create a non-root user for development
ARG USERNAME=developer
ARG USER_UID=1001
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
        
