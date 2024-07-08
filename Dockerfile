FROM bids/base_validator:1.13.1

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

## Install SPM
RUN mkdir /opt/spm12 && \
    curl -SL https://github.com/spm/spm12/archive/r7771.tar.gz | \
    tar -xzC /opt/spm12 --strip-components 1 && \
    curl -SL https://raw.githubusercontent.com/spm/spm-octave/main/spm12_r7771.patch | \
    patch -p0 && \
    make -C /opt/spm12/src PLATFORM=octave distclean && \
    make -C /opt/spm12/src PLATFORM=octave && \
    make -C /opt/spm12/src PLATFORM=octave install && \
    ln -s /opt/spm12/bin/spm12-octave /usr/local/bin/spm12

WORKDIR /home/neuro

COPY . /home/neuro/bidspm
WORKDIR /home/neuro/bidspm
RUN pip install --no-cache-dir --upgrade pip && \
    pip3 --no-cache-dir install -r requirements.txt && \
    pip3 --no-cache-dir install . && \
    octave --no-gui --eval "addpath('/opt/spm12/'); savepath ();" && \
    octave --no-gui --eval "addpath(pwd); savepath(); bidspm(); path"

WORKDIR /home/neuro

ENTRYPOINT ["bidspm"]
