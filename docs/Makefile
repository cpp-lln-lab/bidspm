# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile cpp_spm-manual.pdf

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

clean:
	rm -rf $(BUILDDIR)
	rm -f cpp_spm-manual.pdf
clean_default_options: source/default_options.m
	sed -i "s@/home/remi/matlab/SPM/spm12@spm12_dir@g" source/default_options.m
	sed -i "s@/home/remi/github/CPP_SPM/docs/derivatives@derivatives@g" source/default_options.m
	sed -i "s@/home/remi/github/CPP_SPM/docs/jobs@jobs@g" source/default_options.m
	sed -i "s@\t@ @g" source/default_options.m
view:
	firefox build/html/index.html

cpp_spm-manual.pdf:
	bash create_manual.sh
