#!/bin/bash

# update version in version.txt, dockerfiles and readme

grep -w "^version" CITATION.cff | sed "s/version: /v/g" >version.txt
VERSION=$(cat version.txt | cut -c2-)
sed -i "s/version=.*/version=\"$VERSION\"/g" Dockerfile
sed -i "s/--branch .* --depth 1/--branch v$VERSION --depth 1/g" Dockerfile

sed -i "s/version=.*/version=\"$VERSION\"/g" Dockerfile_matlab
sed -i "s/version = {.*/version = {$VERSION}/g" README.md
sed -i "s/__version__ = .*/version = {$VERSION}/g" README.md

sed -i "s/  version   = {.*/  version   = {$VERSION}/g" src/reports/bidspm.bib

cd tools
git tag --list | tac >versions.txt
python update_versions_bug_report.py
