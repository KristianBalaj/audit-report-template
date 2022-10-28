.PHONY: generate-report clean live-update

run-latex=latexmk                \
	-quiet                   \
	-f                       \
	-shell-escape            \
	-bibtex -xelatex         \
	-output-directory=_build \
	audit-report.tex || true

generate-report:
	$(run-latex) && $(run-latex) && $(run-latex)

live-update:
	make generate-report
	zathura _build/*.pdf&
	find . | grep -E "*.tex" | entr make generate-report

clean:
	rm -r _build 
