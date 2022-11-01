#bin/sh
markdown-pp $1           \
	  -o $2              \
	  -e latexrender
	pandoc $2 -o $3