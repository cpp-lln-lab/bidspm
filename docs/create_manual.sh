#!/bin/bash

sphinx-build -M latexpdf source build

cp build/latex/bidspm.pdf bidspm-manual.pdf
