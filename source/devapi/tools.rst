Tools
=====

Differents tools are available on the ``tools`` folder; here is an non exhaustive list of provided features.

locale/
-------

Translations can be compiled using `./bin/console locales:compile`

genapidoc.sh
------------

Generate GLPI phpdoc using `apigen <https://github.com/ApiGen/ApiGen>`_. ``apigen`` command must be available in your path.

Generated documentation will be available in the ``api`` directory.

make_release.sh
---------------

Builds GLPI release tarball:

* install and cleanup third party libraries,
* remove files and directories that should not be part of tarball,
* minify CSS an Javascript files,
* ...

modify_headers.pl
-----------------

Update copyright header based on the contents of the ``HEADER`` file.

.. _getsearchoptions_php:

getsearchoptions.php
--------------------

This script is designed to be called from the command line. It will display existing search options for an item specified with the ``type`` argument.

For example :

.. code-block:: bash

   $ php tools/getsearchoptions.php --type=Computer

generate_bigdump.php
--------------------

This script is designed to generate many data in your GLPI instance. It relies on the ``generate_bigdump.function.php`` file.

Not yet documented...
---------------------

.. note::

   Following scripts are not yet documented... Feel free to open a pull request to add them!

* autoupdatelocales.sh: Probably obsolete
* check_dict.pl
* check_functions.pl
* checkforms.php: Check forms opened / closed
* checkfunction.php: Check for obsolete function usage
* cleanhistory.php: Purge history with some criteria
* diff_plugin_locale.php: Probably obsolete
* find_twin_in_dict.sh: Check duplicates key in language template
* findtableswithoutclass.php
* fix_utf8_bomfiles.sh
* fk_generate.php
* genphpcov.sh
* glpiuser.php
* ldap-glpi.ldif: An LDAP export
* ldap-schema.txt: An LDAP export
* ldapsync.php
* notincludedlanguages.php: Get all po files not used in GLPI
* test_langfiles.php
* testmail.php
* testunit.php
* update_registered_ids.php: Purge history with some criteria

Out of date
-----------

.. warning::

   Those tools are outdated, and kept for reference, or need some work to be working again. Use them at your own risks, or do not use them at all :)

phpunit/
^^^^^^^^

This directory contains a set of unit tests that have not really been integrated in the project. Since, some unit tests have been rewritten, but not everything has been ported :/
