.. include:: /globals.rst

Source Code management
======================

GLPI source code management is handled by `GIT <https://en.wikipedia.org/wiki/Git>`_ and hosted on `GitHub <https://github.com/glpi-project/glpi>`_.

In order to contribute to the source code, you will have to know a few things about Git and the development model we follow.

Branches
--------

On the Git repository, you will  find several existing branches:

* `master` contains the next major release source code,
* `xx/bugfixes` contains the next minor release source code,
* you should not care about all other branches that may exists, they should have been deleted right now.

The `master` branch is where new features are added. This code is reputed as **non stable**.

The `xx/bugfixes` branches is where bugs are fixed. This code is reputed as *stable*.

Those branches are created when any major version is released. At the time I wrote these lines, latest stable version is `9.1` so the current bugfix branch is `9.1/bugfixes`. As old versions are not supported, old bugfixes branches will not be changed at all; while they're still existing.

Testing
-------

Unfortunately, tests in GLPI are not numerous... But that's willing to change, and we'd like - as far as possible - that proposals contains unit tests for the bug/feature they're related.

Anyways, existing unit tests may never be broken, if you made a change that breaks something, check your code, or change the unit tests, but fix that! ;)

File Hierarchy System
---------------------

.. note::

   This lists current files and directories listed in the source code of GLPI. Some files are not part of distribued archives.

This is a brieve description of GLPI main folders and files:

* |folder| `.tx`: Transifex configuration
* |folder| `ajax`

  * |phpfile| `*.php`: Ajax components

* |folder| `files` Files written by GLPI or plugins (documents, session files, log files, ...)
* |folder| `front`

  * |phpfile| `*.php`: Front components (all displayed pages)

* |folder| `config` (only populated once installed)

  * |phpfile| `config_db.php`: Database configuration file
  * |phpfile| `local_define.php`: Optional file to override some constants definitions (see ``inc/define.php``)

* |folder| `css`

  * |folder| `...`: CSS stylesheets
  * |file| `*.css`: CSS stylesheets

* |folder| `inc`

  * |phpfile| `*.php`: Classes, functions and definitions

* |folder| `install`

  * |folder| `mysql`: MariaDB/MySQL schemas
  * |phpfile| `*.php`: upgrades scripts and installer

* |folder| `js`

  * |file| `*.js`: Javascript files

* |folder| `lib`

  * |folder| `...`: external Javascript libraries

* |folder| `locales`

  * |file| `glpi.pot`: Gettext's POT file
  * |file| `*.po`: Gettext's translations
  * |file| `*.mo`: Gettext's compiled translations

* |folder| `pics`

  * |file| `*.*`: pictures and icons

* |folder| `plugins`:

  * |folder| `...`: where all plugins lends

* |folder| `scripts`: various scripts which can be used in crontabs for example
* |folder| `tests`: unit and integration tests
* |folder| `tools`: a bunch of tools
* |folder| `vendor`: third party libs installed from composer (see composer.json below)
* |file| `.gitignore`: Git ignore list
* |file| `.htaccess`: Some convenient apache rules (all are commented)
* |file| `.travis.yml`: Travis-CI configuration file
* |phpfile| `apirest.php`: REST API main entry point
* |file| `apirest.md`: REST API documentation
* |phpfile| `apixmlrpc.php`: XMLRPC API main entry point
* |file| `AUTHORS.txt`: list of GLPI authors
* |file| `CHANGELOG.md`: Changes
* |file| `composer.json`: Definition of third party libraries (`see composer website <https://getcomposer.org>`_)
* |file| `COPYING.txt`: Licence
* |phpfile| `index.php`: main application entry point
* |file| `phpunit.xml.dist`: unit testing configuration file
* |file| `README.md`: well... a README ;)
* |file| `status.php`: get GLPI status for monitoring purposes



Workflow
--------

In short...
^^^^^^^^^^^

In a short form, here is the workflow we'll follow:

* `create a ticket <https://github.com/glpi-project/glpi/issues/new>`_
* fork, create a specific branch, and hack
* open a :abbr:`PR (Pull Request)`

Each bug will be fixed in a branch that came from the correct `bugfixes` branch. Once merged into the requested branch, developper must report the fixes in the `master`; with a simple cherry-pick for simple cases, or opening another pull request if changes are huge.

Each feature will be hacked in a branch that came from `master`, and will be merged back to `master`.

General
^^^^^^^

Most of the times, when you'll want to contribute to the project, you'll have to retrieve the code and change it before you can report upstream. Note that I will detail here the basic command line instructions to get things working; but of course, you'll find equivalents in your favorite Git GUI/tool/whatever ;)

Just work with a:

.. code-block:: bash

   $ git clone https://github.com/glpi-project/glpi.git

A directory named ``glpi`` will bre created where you've issued the clone.

Then - if you did not already - you will have to create a fork of the repository on your github account; using the `Fork` button from the `GLPI's Github page <https://github.com/glpi-project/glpi/>`_. This will take a few moments, and you will have a repository created, `{you user name}/glpi - forked from glpi-project/glpi`.

Add your fork as a remote from the cloned directory:

.. code-block:: bash

   $ git remote add my_fork https://github.com/{your user name}/glpi.git

You can replace `my_fork` with what you want but `origin` (just remember it); and you will find you fork URL from the Github UI.

A basic good practice using Git is to create a branch for everything you want to do; we'll talk about that in the sections below. Just keep in mind that you will publish your branches on you fork, so you can propose your changes.

When you open a new pull request, it will be reviewed by one or more member of the community. If you're asked to make some changes, just commit again on your local branch, push it, and you're done; the pull request will be automatically updated.

Bugs
^^^^

If you find a bug in the current stable release, you'll have to work on the `bugfixes` branch; and, as we've said already, create a specific branch to work on. You may name your branch explicitely like `9.1/fix-sthing` or to reference an existing issue `9.1/fix-1234`; just prefix it with `{version}/fix-`.

Generally, the very first step for a bug is to be `filled in a ticket <https://github.com/glpi-project/glpi/issues>`_.

From the clone directory:

.. code-block:: bash

   $ git checkout -b 9.1/bugfixes origin/9.1/bugfixes
   $ git branch 9.1/fix-bad-api-callback
   $ git co 9.1/fix-bad-api-callback

At this point, you're working on an only local branch named `9.1/fix-api-callback`. You can now work to solve the issue, and commit (as frequently as you want).

At the end, you will want to get your changes back to the project. So, just push the branch to your fork remote:

.. code-block:: bash

   $ git push -u my_fork 9.1/fix-api-callback

Last step is to create a PR to get your changes back to the project. You'll find the button to do this visiting your fork or even main project github page.

Just remember here we're working on some bugfix, that should reach the `bugfixes` branch; the PR creation will probably propose you to merge against the `master` branch; and maybe will tell you they are conflicts, or many commits you do not know about... Just set the base branch to the correct bugfixes and that should be good.

Features
^^^^^^^^

Before doing any work on any feature, mays sure it has been discussed by the community. Open - if it does not exists yet - a ticket with your detailled proposition. Fo technical features, you can work directly on github; but for work proposals, you should take a look at our `feature proposal platform <http://glpi.userecho.com/>`_.

If you want to add a new feature, you will have to work on the `master` branch, and create a local branch with the name you want, prefixed with `feature/`.

From the clone directory:

.. code-block:: bash

   $ git branch feautre/my-killer-feature
   $ git co feature/my-killler feature


You'll notice we do no change branch on the first step; that is just because `master` is the default branch, and therefore the one you'll be set on just fafter cloning. At this point, you're working on an only local branch named `feature/my-killer-feature`. You can now work and commit (as frequently as you want).

At the end, you will want to get your changes back to the project. So, just push the branch on your fork remote:

.. code-block:: bash

   $ git push -u my_fork feature/my-killer-feature

Commit messages
^^^^^^^^^^^^^^^

There are several good practices regarding commit messages, but this is quite simple:

* the commit message may refer an existing ticket if any,

  * just make a simple reference to a ticket with keywords like ``refs #1234`` or ``see #1234"``,
  * automatically close a ticket when commit will be merged back with keywords like ``closes #1234`` or ``fixes #1234``,

* the first line of the commit should be as short and as concise as possible
* if you want or have to provide details, let a blank line after the first commit line, and go on. Please avoid very long lines (some conventions talks about 80 characters maximum per line, to keep it lisible).

.. _3rd_party_libs:

Third party libraries
^^^^^^^^^^^^^^^^^^^^^

Third party libraries are handled using the `composer tool <http://getcomposer.org>`_.

To install existing dependencies, just install composer from their website or from your distribution repositories and then run:

.. code-block:: bash

   $ composer install

To add a new library, you will probably found the command line on the library documentation, something like:

.. code-block:: bash

   $ composer require libauthor/libname
