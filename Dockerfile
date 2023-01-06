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

## add python
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update -qq && \
    apt-get -qq -y --no-install-recommends install \
        python3.11 \
        python3-pip && \
    apt-get clean && \
    rm -rf \
        /tmp/hsperfdata* \
        /var/*/apt/*/partial \
        /var/lib/apt/lists/* \
        /var/log/apt/term* && \
    echo '\n' && \
    python3 --version && \
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

## Install node.js
RUN node -v && npm -v

## Install bidspm in user folder
RUN test "$(getent passwd neuro)" || useradd --no-user-group --create-home --shell /bin/bash neuro

COPY version /version

WORKDIR /home/neuro
RUN mkdir code input output

# uncomment when local development
RUN echo '\n development'
COPY . /home/neuro/bidspm

# TODO
# USER neuro

# RUN echo '\n production'
# RUN git clone --depth 1 --branch main --recursive https://github.com/cpp-lln-lab/bidspm.git

WORKDIR /home/neuro/bidspm
RUN make install && \
    octave --no-gui --eval "addpath(pwd); savepath();"

WORKDIR /home/neuro

ENTRYPOINT ["bidspm"]
