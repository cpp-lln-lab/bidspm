# Creates a docker image of the default branch of CPP_SPM

# this is mostly taken from the spm docker files: https://github.com/spm/spm-docker
FROM ubuntu:focal

#TODO how to update this with the content of the current version
LABEL version="1.1.2"

# basic OS tools install and also octave
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    build-essential \
    curl \
    git \
    octave \
    liboctave-dev \
    datalad &&
    apt-get clean

RUN rm -rf \
    /tmp/hsperfdata* \
    /var/*/apt/*/partial \
    /var/lib/apt/lists/* \
    /var/log/apt/term*

RUN mkdir /opt/spm12 &&
    curl -SL https://github.com/spm/spm12/archive/r7487.tar.gz |
    tar -xzC /opt/spm12 --strip-components 1 &&
    curl -SL https://raw.githubusercontent.com/spm/spm-docker/master/octave/spm12_r7487.patch |
    patch -p0 &&
    make -C /opt/spm12/src PLATFORM=octave distclean &&
    make -C /opt/spm12/src PLATFORM=octave &&
    make -C /opt/spm12/src PLATFORM=octave install &&
    ln -s /opt/spm12/bin/spm12-octave /usr/local/bin/spm12

RUN octave --no-gui --eval "addpath(\"/opt/spm12\"); savepath ();"

RUN git clone --depth 1 --recurse-submodule https://github.com/cpp-lln-lab/CPP_SPM.git

RUN mkdir code output

RUN cd CPP_SPM && octave --no-gui --eval "initCppSpm(); savepath();"

WORKDIR /code

ENTRYPOINT ["octave"]
