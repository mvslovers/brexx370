# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build
PDFBUILD      = build/pdf

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile pdf

pdf: $(PDFBUILD)/BREXX370_Users_Guide.pdf

$(PDFBUILD)/BREXX370_Users_Guide.pdf:
	$(SPHINXBUILD) -b pdf "$(SOURCEDIR)" "$(PDFBUILD)" >> ../build/docs.log 2>&1

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O) >> ../build/docs.log 2>&1

