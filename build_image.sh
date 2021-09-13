#!/usr/bin/env bash

# creates a tagged version of the CPP_SPM
# will build a ``stable`` version
# and a ``latest`` version

# NOTE: the Dockerfile_dev can be modified to either build from the dev branch
# or from the locally checkout branch

USERNAME=cpplab
IMAGE=cpp_spm
VERSION=`cat version.txt | cut -c2-`

docker build . -f Dockerfile -t $USERNAME/$IMAGE:stable
docker tag $USERNAME/$IMAGE:stable $USERNAME/$IMAGE:$VERSION

docker build . -f Dockerfile_dev -t $USERNAME/$IMAGE:latest
