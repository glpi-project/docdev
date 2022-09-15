.. include:: /globals.rst

Source Code management
======================

GLPI source code management is handled by `GIT <https://en.wikipedia.org/wiki/Git>`_ and hosted on `GitHub <https://github.com/glpi-project/glpi>`_.

In order to contribute to the source code, you will have to know a few things about Git and the development model we follow.

Versioning
-----------

Version numbers follow the `x.y.z` nomenclature, where `x` is a major release, `y` is an intermediate release, and `z` is a bugfix release.

Backward compatibility
----------------------

Wherever possible, bugfix releases should not make any non-backwards compatible changes to our source code, so a plugin that has been made compatible with a `10.0.0` release should therefore be compatible, barring exceptions, with all `10.0.x` versions. In the event that an incompatibility is introduced in a bugfix version, please let us know so that we can correct the problem.

In the context of intermediate or major versions, we do not prevent ourselves from breaking the backward compatibility of our source code. Indeed, although we try to make the maintenance of the plugins as easy as possible, some parts of our source code are not intended to be used or extended in them, and maintaining backward compatibility would be too costly in terms of time. However, the elements destined to disappear, as soon as they are intended to be used by plugins, are maintained for at least one intermediate version, and noted as being deprecated.

Branches
--------

On the Git repository, you will  find several existing branches:

* `master` contains the next major release source code,
* `xx/bugfixes` contains the next minor release source code,
* you should not care about all other branches that may exists, they should have been deleted right now.

The `main` branch is where new features are added. This code is reputed as **non stable**.

The `x.y/bugfixes` branches is where bugs are fixed. This code is reputed as *stable*.

Those branches are created when a new major or intermediate version is released. At the time I wrote these lines, the latest stable version is `10.0` so the current bugfix branch is `10.0/bugfixes`. We do not maintain previous stable versions, so old bugfixes branches are likely to not change; while they are still existing. In case we found a critical bug or a security issue, we may exceptionally apply patches to the latest previous stable branch.

Testing
-------

There are more and more unit tests in GLPI; we use the `atoum unit tests framework <http://atoum.org>`_.

Every proposal **must** contains unit tests; for new features as well as bugfixes. For the bugfixes; this is not a strict requirement if this is part of code that is not tested at all yet. See the :ref:`unit testing section <unittests>` at the bottom of the page.

Anyways, existing unit tests may never be broken, if you made a change that breaks something, check your code, or change the unit tests, but fix that! ;)

.. _fhs:

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

You can replace `my_fork` with what you want but `origin` (just remember it); and you will find your fork URL from the Github UI.

A basic good practice using Git is to create a branch for everything you want to do; we'll talk about that in the sections below. Just keep in mind that you will publish your branches on you fork, so you can propose your changes.

When you open a new pull request, it will be reviewed by one or more member of the community. If you're asked to make some changes, just commit again on your local branch, push it, and you're done; the pull request will be automatically updated.

.. note::

   It's up to you to manage your fork; and keep it up to date. I'll advice you to keep original branches (such as ``master`` or ``x.y/bugfixes``) pointing on the upstream repository.

   Tha way, you'll just have to update the branch from the main repository before doing anything.

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

   $ git branch feature/my-killer-feature
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

Third party PHP libraries are handled using the `composer tool <http://getcomposer.org>`_ and Javascript ones using `npmjs <https://www.npmjs.com/>`_.

To install existing dependencies, just install from their website or from your distribution repositories and then run:

.. code-block:: bash

   $ bin/console dependencies install

.. _unittests:

Unit testing (and functionnal testing)
--------------------------------------

.. note::

   A note for the purists... In GLPI, there are both unit and functional tests; without real distinction ;-)

We use the `atoum unit tests framework <http://atoum.org>`_; see `GLPI website if you wonder why <http://glpi-project.org/spip.php?breve375>`_.

`atoum`'s documentation in available at: http://docs.atoum.org

.. warning::

   With `atoum`, test class **must** refer to an existing class of the project!

Tests isolation
^^^^^^^^^^^^^^^

Tests must be run in an isolated environment. By default, `atoum` use a concurrent mode; that launches tests in a multi-threaded environment. While it is possible to bypass this; this should not be done See http://docs.atoum.org/en/latest/engine.html.

For technical reasons (mainly because of the huge session usage), GLPI unit tests are actually limited to one only thread while running the whole suite; but while developing, the behavior should only be changed if this is really needed.

Type hitting
^^^^^^^^^^^^

Unlike PHPUnit, `atoum` is very strict on type hitting. This really makes sense; but often in GLPI types are not what we should expect (for example, we often get a string and not an integer from counting methods).

Database
^^^^^^^^

Each class that tests something in database **must** inherit from ``\DbTestCase``. This class provides some helpers (like ``login()`` or ``setEntity()`` method); and it also does some preparation and cleanup.

Each ``CommonDBTM`` object added in the database with its ``add()`` method will be automatically deleted after the test method. If you always want to get a new object type created, you can use ``beforeTestMethod()`` or ``setUp()`` methods.

.. warning::

   If you use ``setUp()`` method, do not forget to call ``parent::setUp()``!

Some bootstrapped data are provided (will be inserted on the first test run); they can be used to check defaults behaviors or make queries, but you should **never change those data!** This lend to unpredictable further tests results.

Variables declaration
^^^^^^^^^^^^^^^^^^^^^

When you use a property that has not been declared, you will have errors that may be quite difficult to understand. Just remember to always declare property you use!

.. code-block:: php

   <?php

   class MyClass extends atoum {
      private $myprop;

      public function testMethod() {
         $this->myprop = 'foo'; //<-- error here if missing "private $myprop"
      }
   }

Launch tests
^^^^^^^^^^^^

You can install `atoum` from composer (just run ``composer install`` from GLPI directory) or even system wide.

There are two directories for tests:

* ``tests/units`` for main core tests;
* ``tests/api`` for API tests.

You can choose to run tests on a whole directory, or on any file (+ on a specific method). You have to specify a bootstrap file each time:

.. code-block:: bash

   $ atoum -bf tests/bootstrap.php -mcn 1 -d tests/units/
   [...]
   $ atoum -bf tests/bootstrap.php -f tests/units/Html.php
   [...]
   $ atoum -bf tests/bootstrap.php -f tests/functionnal/Ticket.php -m tests\units\Ticket::testTechAcls


If you want to run the API tests suite, you need to run a development server:

.. code-block:: bash

   php -S localhost:8088 tests/router.php &>/dev/null &


Running `atoum` without any arguments will show you the possible options. Most important are:

* ``-bf`` to set bootstrap file,
* ``-d`` to run tests located in a whole directory,
* ``-f`` to run tests on a standalone file,
* ``-m`` to run tests on a specific method (-f must also be defined),
* ``--debug`` to get extra informations when something goes wrong,
* ``-mcn`` limit number of concurrent runs. This is unfortunately mandatory running the whole test suite right now :/,
* ``-ncc`` do not generate code coverage,
* ``--php`` to change PHP executable to use,
* ``-l`` loop mode.

Note that if you do not use the `-ncc` switch; coverage will be generated in the `tests/code-coverage/` directory.
