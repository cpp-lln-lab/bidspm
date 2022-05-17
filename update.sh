#!/bin/bash

branch=$(git rev-parse --abbrev-ref HEAD)
echo "you are on branch ${branch}"
git remote add tmp https://github.com/cpp-lln-lab/CPP_SPM.git
git fetch tmp
git pull tmp ${branch}
git remote remove tmp
