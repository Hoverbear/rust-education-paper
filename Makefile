all:
	pandoc --smart --filter pandoc-citeproc --standalone --toc --highlight-style=haddock -f markdown -t latex -o paper.pdf paper.md
