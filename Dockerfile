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
        python3 \
        python3-pip \
        fonts-freefont-otf \
        ghostscript \
        # TODO reduce number of octave dependencies
        gnuplot-x11 libcurl4-gnutls-dev \
        # autoconf bison dvipng epstool fig2dev flex \
        # gperf icoutils libarpack2-dev libbison-dev libopenblas-dev  \
        # libfftw3-dev libfltk1.3-dev libfontconfig1-dev  \
        # libfreetype6-dev libgl1-mesa-dev libgl2ps-dev libglpk-dev  \
        # libgraphicsmagick++1-dev libhdf5-dev liblapack-dev libosmesa6-dev  \
        # libpcre3-dev libqhull-dev libqscintilla2-qt5-dev libqrupdate-dev  \
        # libreadline-dev librsvg2-bin libsndfile1-dev libsuitesparse-dev  \
        # libsundials-dev libtool libxft-dev openjdk-8-jdk  \
        # pstoedit qtbase5-dev qttools5-dev qttools5-dev-tools zlib1g-dev \
        octave \
        liboctave-dev \
        octave-common \
        octave-io \
        octave-image \
        octave-signal \
        octave-statistics && \
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
