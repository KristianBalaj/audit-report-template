#bin/sh
echo "> Pre-processing markdown files."
markdown-pp $1 -o $2 -e latexrender
echo "> Running pandoc on the pre-processed result."
pandoc --template=./linked-files/templates/latex.tpl $2 -o $3
echo "> Done! Check" $3