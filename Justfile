root := justfile_directory()

# Set the shell on Windows to using PowerShell.
set windows-shell := ["powershell.exe", "-c"]

export TYPST_ROOT := root

[private]
default:
	@just --list --unsorted

# generate manual
doc *args:
	typst compile docs/docs.typ docs.pdf --root . --font-path ./docs/fonts --ignore-system-fonts {{ args }}

# watch the manual
doc-watch *args:
	typst watch docs/docs.typ docs.pdf --root . --font-path ./docs/fonts --ignore-system-fonts {{ args }}

# generate the codly function signature in codly.typ
signature:
	python3 ./scripts/gen-signature.py

# run test suite
test *args:
	tt run --no-fail-fast --font-path ./docs/fonts {{ args }}

# update test cases
update *args:
	tt update --font-path ./docs/fonts {{ args }}

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

# Benchmark codly
bench *args:
	crityp bench/test-codly-12/main.typ --bench-output .
	crityp bench/test-codly-main/main.typ --root . --bench-output .

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# run ci suite
ci: test doc
