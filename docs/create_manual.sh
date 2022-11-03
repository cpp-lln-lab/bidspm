#!/bin/bash

# needed to ignore svg badges
sed -i 's/<!-- .. only:: not latex -->/.. only:: not latex/g' ../README.md
sed -i 's/\[!\[/    \[!\[/g' ../README.md

sphinx-build -M latexpdf source build

cp build/latex/bidspm.pdf bidspm-manual.pdf

sed -i 's/.. only:: not latex/<!-- .. only:: not latex -->/g' ../README.md
sed -i 's/    \[!\[/\[!\[/g' ../README.md
