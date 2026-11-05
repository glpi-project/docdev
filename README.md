# GLPI's developer documentation

[![Build Status](https://readthedocs.org/projects/glpi-developer-documentation/badge/?version=latest)](http://glpi-developer-documentation.readthedocs.io/en/latest/?badge=latest)

Current documentation is built on top of [Sphinx documentation generator](http://sphinx-doc.org/). It is released under the terms of the <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">Creative Commons BY-NC-ND 4.0 International License</a>.

We're following [GitFlow](http://git-flow.readthedocs.io/):
- ``master`` branch for the current major stable release,
- ``develop`` branch for next major release.

## View it online!

[GLPI installation documentation is currently visible on ReadTheDocs](http://glpi-developer-documentation.rtfd.io/).

## Run it!

Each command exists in two flavours: with Docker (`docker-` prefix, only Docker required) or directly on your machine (Sphinx required).

| Docker              | Your machine | What it does                                                         |
|---------------------|--------------|----------------------------------------------------------------------|
| `make docker-build` | `make build` | Build the HTML documentation in `build/html`                         |
| `make docker-watch` | `make watch` | Serve the documentation on http://localhost:8007/, rebuilt on change |
| `make docker-lint`  | `make lint`  | Check RST syntax and references; fails on any warning                |

Run `make` alone to list the available commands.

### Using Docker

Nothing to install but Docker: each command runs in a throwaway container, and the image is built on first use.

### Using your machine

Install Sphinx, `sphinx-autobuild` and the GLPI theme, for example in a virtual environment:
```shell
python3 -m venv .venv
. .venv/bin/activate
pip install sphinx sphinx-autobuild -r requirements.txt
```

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/80x15.png" /></a>
