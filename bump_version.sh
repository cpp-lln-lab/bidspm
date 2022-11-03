#!/bin/bash

# update version in version.txt, dockerfiles and readme

grep -w "^version" CITATION.cff | sed "s/version: /v/g" >version.txt
VERSION=$(cat version.txt | cut -c2-)
sed -i "s/version=.*/version=\"$VERSION\"/g" Dockerfile
sed -i "s/version=.*/version=\"$VERSION\"/g" Dockerfile_matlab
sed -i "s/version = {.*/version = {$VERSION}/g" README.md
sed -i "s/__version__ = .*/version = {$VERSION}/g" README.md
