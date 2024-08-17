# FROM bids/base_validator:1.13.1
# https://github.com/gnu-octave/docker/tree/main
FROM gnuoctave/octave:9.2.0@sha256:b4cab2446a847530129fe8333a4b31eb046efb4b14bb3182e781fa2238116108

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
        curl \
        default-jre \
        fonts-freefont-otf \
        ghostscript \
        gnuplot-x11 \
        octave-common \
        octave-io \
        octave-image \
        octave-signal \
        octave-statistics \
        python3-pip \
        python3 \
        unzip && \
    apt-get clean && \
    rm -rf \
        /tmp/hsperfdata* \
        /var/*/apt/*/partial \
        /var/lib/apt/lists/* \
        /var/log/apt/term*

# install bids validator
# TODO find out how to pin version
RUN curl -fsSL https://deno.land/install.sh | sh && \
    export DENO_INSTALL="/root/.deno" && \
    export PATH="$DENO_INSTALL/bin:$PATH" && \
    deno install -Agf https://github.com/bids-standard/bids-validator/raw/deno-build/bids-validator.js

## Install SPM
RUN mkdir /opt/spm12 && \
    curl -SL https://github.com/spm/spm12/archive/r7771.tar.gz | tar -xzC /opt/spm12 --strip-components 1 && \
    curl -SL https://raw.githubusercontent.com/spm/spm-octave/main/spm12_r7771.patch | patch -p3 -d /opt/spm12 && \
    make -C /opt/spm12/src PLATFORM=octave distclean && \
    make -C /opt/spm12/src PLATFORM=octave && \
    make -C /opt/spm12/src PLATFORM=octave install && \
    ln -s /opt/spm12/bin/spm12-octave /usr/local/bin/spm12

WORKDIR /home/neuro

COPY . /home/neuro/bidspm
WORKDIR /home/neuro/bidspm
RUN git restore . && \
    git submodule foreach --recursive 'git reset --hard' && \
    git submodule foreach --recursive 'git clean --force -dfx' && \
    pip install --no-cache-dir --upgrade pip && \
    pip3 --no-cache-dir install -r requirements.txt && \
    pip3 --no-cache-dir install . && \
    octave --no-gui --eval "addpath('/opt/spm12/'); savepath ('/usr/share/octave/site/m/startup/octaverc');" && \
    octave --no-gui --eval "addpath(pwd); savepath('/usr/share/octave/site/m/startup/octaverc'); bidspm(); path" && \
    octave --no-gui --eval "path"

WORKDIR /home/neuro

ENTRYPOINT ["bidspm"]
