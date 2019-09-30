# this is mostly taken from the spm docker files: https://github.com/spm/spm-docker
FROM ubuntu:cosmic

MAINTAINER Remi Gau <remi.gau@gmail.com>

# basic OS tools install and also octave
RUN apt-get update && apt-get -y install \
     build-essential \
     git \
     zip unzip \
     curl \
     octave \
     liboctave-dev \
 && apt-get clean \
 && rm -rf \
     /tmp/hsperfdata* \
     /var/*/apt/*/partial \
     /var/lib/apt/lists/* \
     /var/log/apt/term*

# install SPM and the relevant patches for octave
RUN mkdir /opt/spm12 \
 && curl -SL https://github.com/spm/spm12/archive/r7487.tar.gz \
  | tar -xzC /opt/spm12 --strip-components 1 \
 && curl -SL https://raw.githubusercontent.com/spm/spm-docker/master/octave/spm12_r7487.patch \
  | patch -p0 \
 && make -C /opt/spm12/src PLATFORM=octave distclean \
 && make -C /opt/spm12/src PLATFORM=octave \
 && make -C /opt/spm12/src PLATFORM=octave install \
 && ln -s /opt/spm12/bin/spm12-octave /usr/local/bin/spm12

RUN octave --no-gui --eval "addpath(\"/opt/spm12\"); savepath ();"

# get the CPP BIDS pipeline code
RUN mkdir /CPP_BIDS_pipeline /output /code \
 && git clone https://github.com/Remi-Gau/CPP_BIDS_SPM_pipeline.git /CPP_BIDS_pipeline/

RUN octave --no-gui --eval "addpath(genpath(\"/CPP_BIDS_pipeline\")); savepath ();"

WORKDIR /CPP_BIDS_pipeline

RUN git checkout remi-docker_dev
