# Builds the BREXX/370 manuals.  Needs typst and the bookmaster submodule
# (git submodule update --init docs/books/bookmaster).

TYPST ?= typst
BM    := bookmaster
# The PDF carries the edition: ml03-0001-1.pdf is the First Edition of ML03-0001.
BOOKS := ml03-0001-1.pdf ml03-0002-1.pdf ml03-0003-1.pdf

.PHONY: all clean site

all: $(BOOKS)

ml03-0001-%.pdf: ml03-0001.typ $(wildcard guide/*.typ) $(BM)/bookmaster.typ
	$(TYPST) compile --root . --font-path $(BM)/fonts --ignore-system-fonts $< $@

ml03-0002-%.pdf: ml03-0002.typ $(wildcard ref/*.typ) $(BM)/bookmaster.typ
	$(TYPST) compile --root . --font-path $(BM)/fonts --ignore-system-fonts $< $@

ml03-0003-%.pdf: ml03-0003.typ $(wildcard lib/*.typ) $(BM)/bookmaster.typ
	$(TYPST) compile --root . --font-path $(BM)/fonts --ignore-system-fonts $< $@

# The web form, as Read the Docs builds it, into site/.
site:
	sh web/build.sh site

clean:
	rm -rf *.pdf site
