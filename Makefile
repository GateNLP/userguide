########################################################################
#
# Makefile
#
# Hamish, 7/8/1
#
# $Id: Makefile,v 1.20 2006/06/19 12:06:22 ian Exp $
#
########################################################################

TEXFILES=\
tao_main.tex intro.tex gettingstarted.tex developer.tex creole-model.tex \
corpora.tex annie.tex api.tex jape.tex annic.tex evaluation.tex \
gate_development.tex gazetteers.tex ontologies.tex language-creole.tex machine-learning.tex \
alignment.tex parsers.tex crowdsourcing.tex uima.tex misc-creole.tex changes.tex \
plugin-name-map.tex design.tex ant-tasks.tex negram.tex \
postag.tex mlconfig.tex iaa-kappa.tex shortcuts.tex colophon.tex \
recent-changes.tex cloud.tex teamware.tex mimir.tex domain-creole.tex social-media.tex
EDITOR=	viw
#TEX=	texify --pdf
TEX=	latex
#HTLATEX=htlatex.bat
HTLATEX=htlatex
#DVIPDF= dvipdft
DVIPDF= dvipdf
PDFLATEX= pdflatex
THUMBPDF= thumbpdf
SED=sed
export TEX4HTENV ?= $(firstword $(shell locate tex4ht.env))

all: clean tao.pdf index.html split.html

clean:
	rm -fv tao.pdf index.html tao_main*.html split*.html shortc.tex \
tao_main.4tc tao_main.4ct tao_main.aux tao_main.bbl tao_main.blg tao_main.css tao_main.dvi tao_main.idv tao_main.lg tao_main.log tao_main.out tao_main.pdf tao_main*.png tao_main.tmp tao_main.toc tao_main.xref tao_main.log.sav tao_main.blg.sav tao_main.tpt \
split.4tc split.4ct split.aux split.blg split.css split.dvi split.idv split.lg split.log split.out split.pdf split*.png split.tmp split.toc split.xref

# PDF
# we remove the .aux before building the pdf, as if we've previously
# built the html this may have screwed it up...
tao.pdf: $(TEXFILES)
	rm -f tao_main.aux
	printf "\\\\thispagestyle{plain}\n" > shortc.tex
	printf "\\markboth{Brief Contents}{Brief Contents}\n" >> shortc.tex
#	egrep 'chapter\}|\{section\}' tao_main.toc >> shortc.tex ; :
	egrep 'chapter\}|\{part\}' tao_main.toc >> shortc.tex ; :
	$(PDFLATEX) tao_main
	bibtex tao_main
	$(PDFLATEX) tao_main
	printf "\\\\thispagestyle{plain}\n" > shortc.tex
	printf "\\markboth{Brief Contents}{Brief Contents}\n" >> shortc.tex
#	egrep 'chapter\}|\{section\}' tao_main.toc >>shortc.tex ; :
	egrep 'chapter\}|\{part\}' tao_main.toc >>shortc.tex ; :
	$(PDFLATEX) tao_main
#	$(THUMBPDF) tao_main.pdf
	$(PDFLATEX) tao_main
	rm -f thumb???.png
	mv tao_main.pdf tao.pdf
	sleep 1
	@cp tao_main.log tao_main.log.sav ; :
	@cp tao_main.blg tao_main.blg.sav ; :
	@echo ===== WARNINGS ==============================================
	@grep -h Warning tao_main.log tao_main.blg ; :
	@echo =============================================================

tao_main.bbl: tao.pdf

# HTML
index.html: $(TEXFILES) tao_main.bbl
	ebb -x *.png *.jpg
	$(HTLATEX) tao_main.tex "html,0,fn-in,charset=utf-8" " -cunihtf -utf8"
	mv tao_main.html index.html
	# correct lot of errors introduced by htlatex
	$(SED) -r -e 's/ \/>/>/g' \
          -e 's/<\/td>(\s*<div class="multicolumn")/\1/gi' \
          -e 's/<td colspan="3" /<td colspan="5" /gi' \
          -e 's/ id=("[^"]+"><\/a>)/ name=\1/gi' \
          -e 's/href="(.+)&([^";]+)"/href="\1\&amp;\2"/gi' \
          -e 's/<body/<body bgcolor="#FFFFFF"/i' \
          index.html > index.tmp
	mv index.tmp index.html
	sleep 1
	@echo ===== WARNINGS ==============================================
	@echo ===== last pdf run:
	@grep -h Warning tao_main.log.sav tao_main.blg.sav ; :
	@echo ===== index.html run:
	@grep -h Warning tao_main.log tao_main.blg ; :
	@echo =============================================================
	#$(HTLATEX) tao_main.tex
	#if using \part:
	#$(SED) 's|chapterToc A|partToc A, chapterToc A|' tao_main.css >zxc; \
	#  mv zxc tao_main.css

# HTML user guide split in one page per chapter
split.html: $(TEXFILES) tao_main.bbl
	ebb -x *.png *.jpg
	cp tao_main.tex split.tex
	cp tao_main.bbl split.bbl
	# 2 is the level of sectionning
	# sections+ means backlinks on sections
	# fn-in means footnotes are internal
	$(HTLATEX) split.tex "html,2,sections+,fn-in,charset=utf-8" " -cunihtf -utf8"
	# correct lot of errors introduced by htlatex
	@for f in `ls split*.html`; do \
     $(SED) -r -e 's/ \/>/>/g' \
            -e 's/<\/td>(\s*<div class="multicolumn")/\1/gi' \
            -e 's/<td colspan="3" /<td colspan="5" /gi' \
            -e 's/ id=("[^"]+"><\/a>)/ name=\1/gi' \
            -e 's/(href="[^"]+") id=("[^"]+">)/ \1 name=\2/gi' \
            -e 's/(<span style="font-size:x-small">\[<A)/<\/a>\1/gi' \
            -e 's/(>#<\/A>]<\/span>)<\/a>/\1/gi' \
            -e 's/href="(.+)&([^";]+)"/href="\1\&amp;\2"/gi' \
            -e 's/<body/<body bgcolor="#FFFFFF"/i' \
            $$f > $$f.tmp; \
     mv $$f.tmp $$f; \
   done
	@echo Building section index...
	./build-sections-index.pl split*.html
	rm -f split.tex split.bbl
	sleep 1
	@echo ===== WARNINGS ==============================================
	@echo ===== split.html run:
	@grep -h Warning split.log ; :
	@echo =============================================================

edit:
	$(EDITOR) $(TEXFILES) &

files:
	@echo $(TEXFILES)
