# GLPI's developer documentation

[![Build Status](https://readthedocs.org/projects/glpi-developer-documentation/badge/?version=latest)](http://glpi-developer-documentation.readthedocs.io/en/latest/?badge=latest)

Current documentation is built on top of [Sphinx documentation generator](http://sphinx-doc.org/). It is released under the terms of the <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">Creative Commons BY-NC-ND 4.0 International License</a>.

We're following [GitFlow](http://git-flow.readthedocs.io/):
- ``master`` branch for the current major stable release,
- ``develop`` branch for next major release.

## View it online!

[GLPI installation documentation is currently visible on ReadTheDocs](http://glpi-developer-documentation.rtfd.io/).

## Run it!

### Using Docker

```shell
docker compose up --remove-orphans
```

Doc is available at http://localhost:8007/

### Using your machine 

You'll just have to install [Python Sphinx](http://sphinx-doc.org/), it is generally available in distributions repositories for Linux.

If your distribution does not provide it, you could use a `virtualenv`:
```
$ virtualenv /path/to/virtualenv/files
$ /path/to/virtualenv/bin/activate
$ pip install sphinx
```

Once all has been successfully installed, just run the following to build the documentation:
```
$ make html
```

Results will be available in the `build/html` directory :)

Note that it actually uses the default theme, which differs locally and on readthedocs system.

## Autobuild

Autobuild automatically rebuild and refresh the current page on edit.
To use it, you need the `sphinx-autobuild` module:
```
$ pip install sphinx-autobuild
```

You can then use the `livehtml` command:
```
$ make livehtml
```

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/80x15.png" /></a>
