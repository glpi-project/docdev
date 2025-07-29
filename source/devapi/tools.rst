Tools
=====

Differents tools are available on the ``tools`` folder; here is an non exhaustive list of provided features.

locale/
-------

* Translations can be compiled using `./bin/console locales:compile`
* `vendor/bin/extract-locales` is used to extract translated string to the POT file (before sending it to Transifex)

make_release.sh
---------------

Builds GLPI release tarball:

* install and cleanup third party libraries,
* remove files and directories that should not be part of tarball,
* minify CSS an Javascript files,
* ...

.. code-block:: bash

    $ ./tools/make_release.sh -y . mytag
    # file created in /tmp/glpi-mytag.tgz

Modify and check code files headers
-----------------------------------

Update copyright header based on the contents of the ``./tools/HEADER`` file.

.. code-block:: bash

   $ ./vendor/bin/licence-headers-check --fix

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

   Following scripts are not yet documented and probably broken.
   Feel free to open a pull request to add them!

* fk_generate.php
* ldap-glpi.ldif: An LDAP export
* testmail.php
* update_registered_ids.php: This script seems to update the Registered PCI and USB IDs