#!/bin/bash

sphinx-build -M latexpdf source build

cp build/latex/cppspm.pdf bidspm-manual.pdf
