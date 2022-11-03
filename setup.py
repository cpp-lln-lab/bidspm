#!/usr/bin/env python
# see https://github.com/python-versioneer/python-versioneer/issues/249#issuecomment-1038184056
from setuptools import setup

with open("version.txt", "r") as f:
    version = f.read().strip()

if __name__ == "__main__":
    setup(version=version)
