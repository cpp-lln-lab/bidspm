#!/usr/bin/env python
# see https://github.com/python-versioneer/python-versioneer/issues/249#issuecomment-1038184056
import sys

sys.path.insert(0, ".")

from setuptools import setup

import versioneer

if __name__ == "__main__":

    setup(version=versioneer.get_version(), cmdclass=versioneer.get_cmdclass())
