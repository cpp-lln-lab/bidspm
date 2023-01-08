.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

# determines what "make help" will show
define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

# TODO make more general to use the local matlab version
MATLAB = /usr/local/MATLAB/R2018a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

################################################################################
#   General

.PHONY: help clean clean_demos clean_test update fix_submodule

install:
	npm install -g bids-validator
	pip3 install .

help: ## Show what this Makefile can do
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean_demos clean_doc clean_test ## Remove all the clutter
	rm -rf version.txt

clean_demos: ## Remove all the output of the demo
	rm -rf demos/*/cfg
	rm -rf demos/*/outputs/derivatives
	rm -rf demos/*/inputs
	rm -rf demos/*/*.zip
	rm -rf demos/*/*_report.md

clean_test:	## Remove all the output of the tests
	rm *.log
	rm -rf coverage_html

update: ## Tries to get the latest version of the current branch from upstream
	bash tools/update.sh

fix_submodule: ## Fix any submodules that would not be checked out
	git submodule update --init --recursive && git submodule update --recursive

bump_version:
	bash tools/bump_version.sh

validate_cff: ## Validate the citation file
	cffconvert --validate

release: validate_cff bump_version lint manual


################################################################################
#   doc

update_faq:
	faqtory build

clean_doc:
	cd docs && make clean

manual: update_faq ## Build PDF version of the doc
	cd docs && sh create_manual.sh


################################################################################
#   lint

lint: lint_matlab lint_python ## Clean MATLAB and python code

lint_matlab: ## Clean MATLAB code
	mh_style --fix && mh_metric --ci && mh_lint

lint_python: ## Clean python code
	black *.py src tests docs
	flake8	*.py src tests docs
	mypy *.py src

################################################################################
#   test

test: ## Run tests with coverage
	$(MATLAB) $(ARG) -r "run_tests; exit()"

system_test: ## Run system tests
	$(MATLAB) $(ARG) -r "cd demos/face_repetition/; test_face_rep; exit()"
	$(MATLAB) $(ARG) -r "cd demos/MoAE/; test_moae; exit()"

test_python: ## Run python tests
	python -m pytest

coverage: ## use coverage
	coverage erase
	coverage run --source src -m pytest
	coverage report -m

################################################################################
#   DOCKER

.PHONY: clean_docker Dockerfile_matlab

clean_docker:
	rm -f Dockerfile_matlab

build_image: Dockerfile ## Build stable docker image from the main branch
	docker build . -f Dockerfile -t cpplab/bidspm:unstable
	VERSION=$(cat version.txt | cut -c2-)

Dockerfile_matlab:
	docker run --rm kaczmarj/neurodocker:0.9.1 generate docker \
		--pkg-manager apt \
		--base-image debian:stretch-slim \
		--spm12 version=r7771 \
		--install nodejs npm \
		--run "node -v && npm -v && npm install -g bids-validator" \
		--user neuro \
		--run "mkdir code output bidspm" \
		--copy ".", "/home/neuro/bidspm/" > Dockerfile_matlab

build_image_matlab: Dockerfile_matlab
	docker build . -f Dockerfile_matlab -t cpplab/bidspm_matlab:unstable

################################################################################
