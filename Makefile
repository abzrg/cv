#------------------------------------------------------------------------------
# Author:
#      Ali Bozorgzadeh
# Copyright:
#      Copyright (c) 2024 Ali Bozorgzadeh
# License:
#      The MIT License (see https://opensource.org/license/mit)
#------------------------------------------------------------------------------
# Project structure:
#
# .
# ├── Makefile
# ├── include
# │   ├── interests.tex
# │   ├── education.tex
# │   └── publications.tex
# └── main.tex
#------------------------------------------------------------------------------
# Prerequisits:
#
#  - Some latex distribution of course (mine: texlive)
#  - latexmk
#  - pandoc (for converting to plain text)
#  - latexdiff
#  - git
#------------------------------------------------------------------------------

INCDIR   := include
BUILDDIR := build
BIB      := refs.bib
SRC      := main.tex
INCLUDES := $(wildcard $(INCDIR)/*.tex)
PDF      := cv.pdf

TEXFLAGS  = -pdf
TEXFLAGS += -dvi-
TEXFLAGS += -output-directory=${BUILDDIR}
TEXFLAGS += -file-line-error
TEXFLAGS += -interaction=nonstopmode
TEXFLAGS += -shell-escape



all: $(PDF)


$(BUILDDIR):
	mkdir -p $@


$(INCDIR):
	mkdir -p $@


# $(PDF): $(BIB)
$(PDF): $(SRC) $(INCLUDES) | $(BUILDDIR) $(INCDIR)
	latexmk $(TEXFLAGS) $<
	-ln -fs $(BUILDDIR)/$(<:.tex=.pdf) $@


# Generate a PDF that displays the changes between HEAD and working directory
# (Needs latexdiff to be installed)
diffwork:
	latexdiff-vc --flatten --type CULINECHBAR --force --git --revision=HEAD $(SRC)
	latexmk $(TEXFLAGS) $(SRC:.tex=-diffHEAD.tex)
	ln -sf $(BUILDDIR)/$(SRC:.tex=-diffHEAD.pdf) diffwork.pdf
	-rm -f $(SRC:.tex=-diffHEAD.tex)


# Generate a PDF that displays the changes between last two commits
# (Needs latexdiff to be installed)
diff: diffprev
diffprev:
	latexdiff-vc --flatten --type CULINECHBAR --force --git --revision=HEAD~ --revision=HEAD $(SRC)
	mv $(SRC:.tex=-diffHEAD~-HEAD.tex) diff.tex
	latexmk $(TEXFLAGS) diff.tex
	ln -sf $(BUILDDIR)/diff.pdf .
	-rm -f diff.tex


# Convert to text (text width = 70)
# (Needs pandoc to be installed)
text:
	pandoc $(SRC) --wrap=auto --columns=70 --to=plain -o $(SRC:.tex=.txt)


# Word count (assuming texcount is installed)
wc:
	@texcount -inc $(SRC) \
		| awk -v RS='' '/Sum of files/' \
		| grep 'Words in text' \
		| awk '{print $$4}'


clean:
	@-latexmk -C -output-directory=$(BUILDDIR)
	@-rm -vf build/*


.PHONY: all diffwork diff diffprev text wc clean
