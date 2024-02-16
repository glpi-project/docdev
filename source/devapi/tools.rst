Tools
=====

Differents tools are available on the ``tools`` folder; here is an non exhaustive list of provided features.

locale/
-------

The locale directory contains several scripts used to maintain :doc:`translations <translations>` along with Transifex services:

* ``extract_template.sh`` is used to extract translated string to the POT file (before sending it to Transifex),
* ``locale\update_mo.pl`` compiles MO files from PO file (after they've been updated from transifex).

genapidoc.sh
------------

Generate GLPI phpdoc using `apigen <https://github.com/ApiGen/ApiGen>`_. ``apigen`` command must be available in your path.

Generated documentation will be available in the ``api`` directory.

convert_search_options.php
--------------------------

Search options have changed in GLPI 9.2 (see `PR #1396 <https://github.com/glpi-project/glpi/issues/1396>`_). This script is a helper to convert existing search options to new way.

.. note::

   The script output can probably **not be used as is**; but it would probably help you a lot!

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

This script is designed to be called from a browser, or from the command line. It will display existing search options for an item specified with the ``type`` argument.

For example, open ``http://localhost/glpi/tools/getsearchoptions.php?type=Computer``, and you will see search options for `Computer` type.

On command line, you can get the exact same result entering:

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

php.vim
^^^^^^^

A vimfile for autocompletion and highlithing in VIM. This one is very outaded; it should be replaced with a most recent version, or being removed.
