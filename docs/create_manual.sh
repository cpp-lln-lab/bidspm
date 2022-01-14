#!/bin/bash

sphinx-build -M latexpdf source build

cp build/latex/cppspm.pdf cpp_spm-manual.pdf