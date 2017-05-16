paper = paper

all: pdf clean

tex: $(paper).md template.tex
	cat $(paper).md | sed -f variables.sed | pandoc -f markdown -sS --filter pandoc-fignos --template=template.tex --natbib -o tmp.tex
	# cat $(paper).md | sed -f variables.sed | pandoc -f markdown -sS --template=template.tex --natbib -o tmp.tex

pdf: tex
	latexmk -f -pdf -quiet tmp.tex 
	mv tmp.pdf $(paper).pdf
	open $(paper).pdf

clean:
	rm tmp.*