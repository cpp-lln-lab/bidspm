FROM bids/base_validator

ARG DEBIAN_FRONTEND="noninteractive"

## basic OS tools install octave
RUN apt-get update -qq && \
    apt-get -qq -y --no-install-recommends install \
        build-essential \
        software-properties-common \
        apt-utils \
        ca-certificates \
        git \
        curl \
        gnuplot \
        python3 \
        python3-pip \
        octave \
        liboctave-dev && \
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
    curl -SL https://raw.githubusercontent.com/spm/spm-docker/main/octave/spm12_r7771.patch | \
    patch -p0 && \
    make -C /opt/spm12/src PLATFORM=octave distclean && \
    make -C /opt/spm12/src PLATFORM=octave && \
    make -C /opt/spm12/src PLATFORM=octave install && \
    ln -s /opt/spm12/bin/spm12-octave /usr/local/bin/spm12

WORKDIR /home/neuro

COPY . /home/neuro/bidspm
WORKDIR /home/neuro/bidspm
RUN pip install --no-cache-dir --upgrade pip && \
    pip3 --no-cache-dir install . && \
    octave --no-gui --eval "addpath('/opt/spm12/'); savepath ();" && \
    octave --no-gui --eval "addpath(pwd); savepath(); bidspm(); path"

WORKDIR /home/neuro

ENTRYPOINT ["bidspm"]
