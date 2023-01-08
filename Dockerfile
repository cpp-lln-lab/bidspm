# Creates a docker image of bidspm
# version number are updated automatically with the bump version script

FROM ubuntu:jammy

ARG DEBIAN_FRONTEND="noninteractive"

## basic OS tools install, node, npm also octave
RUN apt-get update -qq && \
    apt-get -qq -y --no-install-recommends install \
        build-essential \
        software-properties-common \
        apt-utils \
        curl \
        octave \
        liboctave-dev \
        ca-certificates \
        gnupg2 && \
    apt-get clean && \
    rm -rf \
        /tmp/hsperfdata* \
        /var/*/apt/*/partial \
        /var/lib/apt/lists/* \
        /var/log/apt/term*

## Install python
RUN : \
    && . /etc/lsb-release \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys F23C5A6CF475977595C89F51BA6932366A755776 \
    && echo deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu $DISTRIB_CODENAME main > /etc/apt/sources.list.d/deadsnakes.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3.11 \
        python3-pip && \
    apt-get clean && \
    rm -rf \
        /tmp/hsperfdata* \
        /var/*/apt/*/partial \
        /var/lib/apt/lists/* \
        /var/log/apt/term* && \
    echo '\n' && \
    python3.11 --version && \
    pip3 list && \
    echo '\n'

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


## Install node and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get update -qq && \
    apt-get install -y -q --no-install-recommends \
        nodejs && \
    rm -rf /var/lib/apt/lists/*
RUN node --version && npm --version

RUN test "$(getent passwd neuro)" || useradd --no-user-group --create-home --shell /bin/bash neuro

WORKDIR /home/neuro
COPY . /home/neuro/bidspm
WORKDIR /home/neuro/bidspm
RUN make install

RUN octave --no-gui --eval "addpath('/opt/spm12/'); savepath ();" && \
    octave --no-gui --eval "addpath(pwd); savepath(); bidspm();"

USER neuro

WORKDIR /home/neuro

ENTRYPOINT ["bidspm"]
