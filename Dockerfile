FROM ubuntu:jammy-20240808@sha256:adbb90115a21969d2fe6fa7f9af4253e16d45f8d4c1e930182610c4731962658

LABEL org.opencontainers.image.source="https://github.com/cpp-lln-lab/bidspm"
LABEL org.opencontainers.image.url="https://github.com/cpp-lln-lab/bidspm"
LABEL org.opencontainers.image.documentation="https://bidspm.readthedocs.io/en/latest"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.title="bidspm"
LABEL org.opencontainers.image.description="an SPM-centric BIDS app"

ARG DEBIAN_FRONTEND="noninteractive"

## basic OS tools install octave
RUN apt-get update -qq && \
    apt-get -qq -y --no-install-recommends install \
        apt-utils \
        build-essential \
        ca-certificates \
        curl \
        default-jre \
        fonts-freefont-otf \
        ghostscript \
        git \
        gnuplot-x11 \
        libcurl4-gnutls-dev \
        liboctave-dev \
        octave \
        octave-common \
        octave-io \
        octave-image \
        octave-signal \
        octave-statistics \
        python3-pip \
        python3 \
        software-properties-common \
        unzip \
        zip && \
    apt-get clean && \
    rm -rf \
        /tmp/hsperfdata* \
        /var/*/apt/*/partial \
        /var/lib/apt/lists/* \
        /var/log/apt/term*

## Install validator
RUN curl -fsSL https://deno.land/install.sh | sh && \
    export DENO_INSTALL="/root/.deno" && \
    export PATH="$DENO_INSTALL/bin:$PATH" && \
    deno install -Agf -n bids-validator jsr:@bids/validator@1.14.12

## Install SPM
ARG SPM_VERSION=26.10.01
RUN curl -fsSL --retry 5 -o /tmp/spm.zip \
        https://github.com/spm/spm/releases/download/${SPM_VERSION}/spm_${SPM_VERSION}.zip && \
    unzip -q /tmp/spm.zip -d /opt && \
    rm /tmp/spm.zip && \
    make -C /opt/spm/src PLATFORM=octave distclean && \
    make -C /opt/spm/src PLATFORM=octave && \
    make -C /opt/spm/src PLATFORM=octave install && \
    ln -s /opt/spm/bin/spm-octave /usr/local/bin/spm

COPY --from=ghcr.io/astral-sh/uv:0.13.5 /uv /uvx /bin/
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_NO_CACHE=1
ENV PATH="/opt/venv/bin:${PATH}"

WORKDIR /home/neuro

COPY . /home/neuro/bidspm
WORKDIR /home/neuro/bidspm
RUN git restore . && \
    git -C lib/CPP_ROI/atlas/HCPex reset --hard && \
    git -C lib/CPP_ROI/atlas/HCPex clean --force -dfx && \
    git status && \
    uv sync --locked --no-dev --no-editable --python 3.12 && \
    octave --no-gui --eval "addpath('/opt/spm/'); savepath ('/usr/share/octave/site/m/startup/octaverc');" && \
    octave --no-gui --eval "addpath(pwd); savepath('/usr/share/octave/site/m/startup/octaverc'); bidspm(); path" && \
    octave --no-gui --eval "path"


WORKDIR /home/neuro

ENTRYPOINT ["bidspm"]
