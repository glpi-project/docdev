# Makefile for Sphinx documentation
#
# Two usage contexts:
#   - Sphinx targets (no prefix) need Sphinx installed on your machine.
#   - Docker targets (docker- prefix) only need Docker; they run the matching
#     Sphinx target in a throwaway "docs" container.

SPHINXBUILD     = sphinx-build
SPHINXAUTOBUILD = sphinx-autobuild
SPHINXOPTS      =
SOURCEDIR       = source
BUILDDIR        = build
PORT            = 8007

DOCKER_RUN = docker compose run --rm --user $(shell id -u):$(shell id -g)

.DEFAULT_GOAL := help
.PHONY: help build watch lint docker-build docker-watch docker-lint

## —— General —————————————————————————————————————————————————————————————————
help: ## Show this help message
	@printf '\nUsage:\n  make \033[32m<target>\033[0m\n'
	@awk 'BEGIN {FS = ":.*?## "} \
		/^## —— / { \
			section = $$0; gsub(/^## —— /, "", section); gsub(/ —+$$/, "", section); \
			printf "\n\033[33m%s\033[0m\n", section \
		} \
		/^[a-zA-Z_-]+:.*?## / { printf "  \033[32m%-20s\033[0m %s\n", $$1, $$2 }' \
		$(MAKEFILE_LIST)
	@printf '\n'

## —— Sphinx (Sphinx required on your machine) ————————————————————————————————
build: ## Build the HTML documentation in build/html
	$(SPHINXBUILD) -M html $(SOURCEDIR) $(BUILDDIR) $(SPHINXOPTS)

watch: ## Serve the doc with live rebuild on http://localhost:8007
	$(SPHINXAUTOBUILD) $(SOURCEDIR) $(BUILDDIR)/html -d $(BUILDDIR)/doctrees -q --ignore "*.swp" --host 0.0.0.0 --port $(PORT) $(SPHINXOPTS)

lint: ## Check RST syntax and references (warnings fail, no output generated)
	$(SPHINXBUILD) -M dummy $(SOURCEDIR) $(BUILDDIR) -E -q -W --keep-going $(SPHINXOPTS)

## —— Docker (only Docker required) ———————————————————————————————————————————
docker-build: ## Same as build, in Docker
	$(DOCKER_RUN) docs make build SPHINXOPTS="$(SPHINXOPTS)"

docker-watch: ## Same as watch, in Docker
	$(DOCKER_RUN) --service-ports docs make watch SPHINXOPTS="$(SPHINXOPTS)"

docker-lint: ## Same as lint, in Docker
	$(DOCKER_RUN) docs make lint SPHINXOPTS="$(SPHINXOPTS)"
