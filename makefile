.PHONY: open pdf clean
pdf:
	-pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape cv.tex

open:
	open cv.pdf

clean:
	$(RM) *.aux *.log *.out

