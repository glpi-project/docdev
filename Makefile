# Makefile for Sphinx documentation
#

COMPOSE = docker compose
DOCS = $(COMPOSE) exec docs

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         =
BUILDDIR      = build
SPHINXAUTOBUILD = sphinx-autobuild

# User-friendly check for sphinx-build
ifeq ($(shell which $(SPHINXBUILD) >/dev/null 2>&1; echo $$?), 1)
$(error The '$(SPHINXBUILD)' command was not found. Make sure you have Sphinx installed, then set the SPHINXBUILD environment variable to point to the full path of the '$(SPHINXBUILD)' executable. Alternatively you can add the directory with the executable to your PATH. If you don't have Sphinx installed, grab it from http://sphinx-doc.org/)
endif

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) source
# the i18n builder cannot share the environment and doctrees with the others
I18NSPHINXOPTS  = $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) source

#Watcher
ALLSPHINXLIVEOPTS   = $(ALLSPHINXOPTS) -q \
   --delay 1 \
   --ignore "*.swp" \
   --ignore "*.pdf" \
   --ignore "*.log" \
   --ignore "*.out" \
   --ignore "*.toc" \
   --ignore "*.aux" \
   --ignore "*.idx" \
   --ignore "*.ind" \
   --ignore "*.ilg" \
   --ignore "*.tex" \
   --watch source

## —— General —————————————————————————————————————————————————————————————————
.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*?## "; printf "\nUsage:\n  make \033[32m<target>\033[0m\n"} \
		/^## —— / { \
			section = $$0; gsub(/^## —— /, "", section); gsub(/ —+$$/, "", section); \
			printf "\n\033[33m%s\033[0m\n", section \
		} \
		/^[a-zA-Z_-]+:.*?## / { printf "  \033[32m%-20s\033[0m %s\n", $$1, $$2 }' \
		$(MAKEFILE_LIST)
	@echo ""

## —— Docker ———————————————————————————————————————————————————————————————————
.PHONY: build start stop kill bash

build: ## Build the Docker images
	$(COMPOSE) pull
	$(COMPOSE) build --no-cache
.PHONY: build

up: ## Start all containers
	$(COMPOSE) up -d
	@echo "\033[32m▶ Documentation available at: http://localhost:8007 \033[0m"
.PHONY: start

watch: ## Start containers and run livehtml with live console output
	$(MAKE) up
	$(DOCS) bash -c 'make livehtml'
.PHONY: watch

down: ## Stop the containers
	$(COMPOSE) down --remove-orphans
.PHONY: stop

kill: ## Stop the containers and remove the volumes
	$(COMPOSE) kill
	$(COMPOSE) down --volumes --remove-orphans
.PHONY: kill

bash: ## Start a shell inside the php container
	$(DOCS) bash
.PHONY: bash

## —— Sphinx ———————————————————————————————————————————————————————————————————
.PHONY: clean html livehtml dirhtml singlehtml pickle json htmlhelp qthelp devhelp epub latex latexpdf latexpdfja text man texinfo info gettext changes linkcheck doctest xml pseudoxml

clean: ## Remove all build artifacts
	rm -rf $(BUILDDIR)/*

html: ## Build standalone HTML files
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

livehtml: ## Build HTML files and watch for changes (auto-rebuild)
	$(SPHINXAUTOBUILD) -b html $(ALLSPHINXLIVEOPTS) $(BUILDDIR)/html --host 0.0.0.0 --port 8007
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

dirhtml: ## Build HTML files named index.html in directories
	$(SPHINXBUILD) -b dirhtml $(ALLSPHINXOPTS) $(BUILDDIR)/dirhtml
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/dirhtml."

singlehtml: ## Build a single large HTML file
	$(SPHINXBUILD) -b singlehtml $(ALLSPHINXOPTS) $(BUILDDIR)/singlehtml
	@echo
	@echo "Build finished. The HTML page is in $(BUILDDIR)/singlehtml."

pickle: ## Build pickle files
	$(SPHINXBUILD) -b pickle $(ALLSPHINXOPTS) $(BUILDDIR)/pickle
	@echo
	@echo "Build finished; now you can process the pickle files."

json: ## Build JSON files
	$(SPHINXBUILD) -b json $(ALLSPHINXOPTS) $(BUILDDIR)/json
	@echo
	@echo "Build finished; now you can process the JSON files."

htmlhelp: ## Build HTML files and a HTML help project
	$(SPHINXBUILD) -b htmlhelp $(ALLSPHINXOPTS) $(BUILDDIR)/htmlhelp
	@echo
	@echo "Build finished; now you can run HTML Help Workshop with the" \
	      ".hhp project file in $(BUILDDIR)/htmlhelp."

qthelp: ## Build HTML files and a qthelp project
	$(SPHINXBUILD) -b qthelp $(ALLSPHINXOPTS) $(BUILDDIR)/qthelp
	@echo
	@echo "Build finished; now you can run "qcollectiongenerator" with the" \
	      ".qhcp project file in $(BUILDDIR)/qthelp, like this:"
	@echo "# qcollectiongenerator $(BUILDDIR)/qthelp/GLPIDeveloperDocumentation.qhcp"
	@echo "To view the help file:"
	@echo "# assistant -collectionFile $(BUILDDIR)/qthelp/GLPIDeveloperDocumentation.qhc"

devhelp: ## Build HTML files and a Devhelp project
	$(SPHINXBUILD) -b devhelp $(ALLSPHINXOPTS) $(BUILDDIR)/devhelp
	@echo
	@echo "Build finished."
	@echo "To view the help file:"
	@echo "# mkdir -p $$HOME/.local/share/devhelp/GLPIDeveloperDocumentation"
	@echo "# ln -s $(BUILDDIR)/devhelp $$HOME/.local/share/devhelp/GLPIDeveloperDocumentation"
	@echo "# devhelp"

epub: ## Build an epub
	$(SPHINXBUILD) -b epub $(ALLSPHINXOPTS) $(BUILDDIR)/epub
	@echo
	@echo "Build finished. The epub file is in $(BUILDDIR)/epub."

latex: ## Build LaTeX files (set PAPER=a4 or PAPER=letter)
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo
	@echo "Build finished; the LaTeX files are in $(BUILDDIR)/latex."
	@echo "Run \`make' in that directory to run these through (pdf)latex" \
	      "(use \`make latexpdf' here to do that automatically)."

latexpdf: ## Build LaTeX files and run them through pdflatex
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo "Running LaTeX files through pdflatex..."
	$(MAKE) -C $(BUILDDIR)/latex all-pdf
	@echo "pdflatex finished; the PDF files are in $(BUILDDIR)/latex."

latexpdfja: ## Build LaTeX files and run them through platex/dvipdfmx
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo "Running LaTeX files through platex and dvipdfmx..."
	$(MAKE) -C $(BUILDDIR)/latex all-pdf-ja
	@echo "pdflatex finished; the PDF files are in $(BUILDDIR)/latex."

text: ## Build text files
	$(SPHINXBUILD) -b text $(ALLSPHINXOPTS) $(BUILDDIR)/text
	@echo
	@echo "Build finished. The text files are in $(BUILDDIR)/text."

man: ## Build manual pages
	$(SPHINXBUILD) -b man $(ALLSPHINXOPTS) $(BUILDDIR)/man
	@echo
	@echo "Build finished. The manual pages are in $(BUILDDIR)/man."

texinfo: ## Build Texinfo files
	$(SPHINXBUILD) -b texinfo $(ALLSPHINXOPTS) $(BUILDDIR)/texinfo
	@echo
	@echo "Build finished. The Texinfo files are in $(BUILDDIR)/texinfo."
	@echo "Run \`make' in that directory to run these through makeinfo" \
	      "(use \`make info' here to do that automatically)."

info: ## Build Texinfo files and run them through makeinfo
	$(SPHINXBUILD) -b texinfo $(ALLSPHINXOPTS) $(BUILDDIR)/texinfo
	@echo "Running Texinfo files through makeinfo..."
	make -C $(BUILDDIR)/texinfo info
	@echo "makeinfo finished; the Info files are in $(BUILDDIR)/texinfo."

gettext: ## Build PO message catalogs
	$(SPHINXBUILD) -b gettext $(I18NSPHINXOPTS) $(BUILDDIR)/locale
	@echo
	@echo "Build finished. The message catalogs are in $(BUILDDIR)/locale."

changes: ## Build an overview of all changed/added/deprecated items
	$(SPHINXBUILD) -b changes $(ALLSPHINXOPTS) $(BUILDDIR)/changes
	@echo
	@echo "The overview file is in $(BUILDDIR)/changes."

linkcheck: ## Check all external links for integrity
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) $(BUILDDIR)/linkcheck
	@echo
	@echo "Link check complete; look for any errors in the above output " \
	      "or in $(BUILDDIR)/linkcheck/output.txt."

doctest: ## Run all doctests embedded in the documentation
	$(SPHINXBUILD) -b doctest $(ALLSPHINXOPTS) $(BUILDDIR)/doctest
	@echo "Testing of doctests in the sources finished, look at the " \
	      "results in $(BUILDDIR)/doctest/output.txt."

xml: ## Build Docutils-native XML files
	$(SPHINXBUILD) -b xml $(ALLSPHINXOPTS) $(BUILDDIR)/xml
	@echo
	@echo "Build finished. The XML files are in $(BUILDDIR)/xml."

pseudoxml: ## Build pseudoxml-XML files for display purposes
	$(SPHINXBUILD) -b pseudoxml $(ALLSPHINXOPTS) $(BUILDDIR)/pseudoxml
	@echo
	@echo "Build finished. The pseudo-XML files are in $(BUILDDIR)/pseudoxml."
