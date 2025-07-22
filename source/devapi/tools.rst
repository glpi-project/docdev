Tools
=====

Differents tools are available on the ``tools`` folder; here is an non exhaustive list of provided features.

locale/
-------

Translations can be compiled using `./bin/console locales:compile`

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