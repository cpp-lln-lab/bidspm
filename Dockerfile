# Creates a docker image of bidspm

# version number are updated automatically with the bump version script

# this is mostly taken from the spm docker files: https://github.com/spm/spm-docker
FROM ubuntu:22.04

USER root

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

LABEL version="3.0.0"

LABEL maintainer="Rémi Gau <remi.gau@gmail.com>"

## basic OS tools install, node, npm also octave
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    build-essential software-properties-common\
    curl \
    octave liboctave-dev \
    nodejs npm

## add python
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update
RUN apt-get -y install python3.10 python3-pip

RUN apt-get clean && \
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
RUN octave --no-gui --eval "addpath('/opt/spm12/'); savepath ();"

## Install node.js
RUN node -v && npm -v

## Install bidspm in user folder
RUN test "$(getent passwd neuro)" || useradd --no-user-group --create-home --shell /bin/bash neuro

WORKDIR /home/neuro
RUN mkdir code input output

# uncomment when local development
# RUN echo '\nDEV'
# COPY . /home/neuro/bidspm

RUN echo '\nPROD'
RUN git clone --depth 1 --branch FIXME --recursive https://github.com/cpp-lln-lab/bidspm.git

RUN cd bidspm && make install

RUN echo '\n'
RUN python3 --version && pip3 list
RUN echo '\n'

# TODO
# USER neuro

RUN cd bidspm && octave --no-gui --eval "addpath(pwd); savepath();"

ENTRYPOINT ["bidspm"]
