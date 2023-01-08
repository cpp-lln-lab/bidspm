# Creates a docker image of bidspm
# version number are updated automatically with the bump version script

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND="noninteractive"

USER root

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

LABEL version="3.0.0"

## basic OS tools install, node, npm also octave
RUN apt-get update -qq && \
    apt-get -qq -y --no-install-recommends install \
        build-essential \
        software-properties-common\
        curl \
        octave \
        liboctave-dev \
        nodejs \
        npm && \
    apt-get clean && \
    rm -rf \
        /tmp/hsperfdata* \
        /var/*/apt/*/partial \
        /var/lib/apt/lists/* \
        /var/log/apt/term*

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
    ln -s /opt/spm12/bin/spm12-octave /usr/local/bin/spm12 && \
    octave --no-gui --eval "addpath('/opt/spm12/'); savepath ();"

## Install validator
RUN node -v && npm -v && \
    npm install -g bids-validator@1.9.9

RUN test "$(getent passwd neuro)" || useradd --no-user-group --create-home --shell /bin/bash neuro

WORKDIR /home/neuro
COPY . /home/neuro/bidspm
WORKDIR /home/neuro/bidspm
RUN make install && \
    octave --no-gui --eval "addpath(pwd); savepath();"

USER neuro
WORKDIR /home/neuro

ENTRYPOINT ["bidspm"]
