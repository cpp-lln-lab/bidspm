# TODO make more general to use the local matlab version
MATLAB = /usr/local/MATLAB/R2018a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?= -v
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile bidspm-manual.pdf

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

clean:
	rm -rf $(BUILDDIR)

view:
	$(BROWSER) build/html/index.html

release: update_faq boilerplate clean_default_options default_mapping
	python generate_doc.py

update_faq:
	cd faq/bids && faqtory build
	cd faq/general && faqtory build
	cd faq/preproc && faqtory build
	cd faq/results && faqtory build
	cd faq/spm && faqtory build
	cd faq/stats && faqtory build

boilerplate:
	$(MATLAB) $(ARG) -r "print_boilerplate; exit()"
	rm -fr reports

clean_default_options:
	$(MATLAB) $(ARG) -r "print_default_options; exit()"
	sed -i "s@/home/remi/matlab/SPM/spm12@spm12_dir@g" source/default_options.m
	sed -i "s@/home/remi/github/bidspm/docs/derivatives@derivatives@g" source/default_options.m
	sed -i "s@/home/remi/github/bidspm/docs/jobs@jobs@g" source/default_options.m
	sed -i "s@\t@ @g" source/default_options.m

default_mapping:
	$(MATLAB) $(ARG) -r "print_spm_to_bids_mapping; exit()"
