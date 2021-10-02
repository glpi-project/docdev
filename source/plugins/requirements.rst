Requirements
------------

* plugin will be installed by creating a directory in the ``plugins`` directory of the GLPI instance,
* plugin directory name should never change,
* each plugin **must** at least provides :ref:`setup.php <plugins_setupphp>` and :ref:`hook.php <plugins_hookphp>` files,
* if your plugin requires a newer PHP version than GLPI one, or extensions that are not mandatory in core; it is up to you to check that in the install process.

.. _plugins_setupphp:

setup.php
^^^^^^^^^

The plugin's `setup.php` file will be automatically loaded from GLPI's core in order to get its version, to check pre-requisites, etc.

This is a good practice, thus not mandatory, to define a constant name `{PLUGINNAME}_VERSION` in this file.

This is a minimalist example, for a plugin named `myexample` (functions names will contain plugin name):

.. code-block:: php

   <?php

   define('MYEXAMPLE_VERSION', '1.2.10');

   /**
    * Init the hooks of the plugins - Needed
    *
    * @return void
    */
   function plugin_init_myexample() {
      global $PLUGIN_HOOKS;

      //required!
      $PLUGIN_HOOKS['csrf_compliant']['myexample'] = true;

      //some code here, like call to Plugin::registerClass(), populating PLUGIN_HOOKS, ...
   }

   /**
    * Get the name and the version of the plugin - Needed
    *
    * @return array
    */
   function plugin_version_myexample() {
      return [
         'name'           => 'Plugin name that will be displayed',
         'version'        => MYEXAMPLE_VERSION,
         'author'         => 'John Doe and <a href="http://foobar.com">Foo Bar</a>',
         'license'        => 'GLPv3',
         'homepage'       => 'http://perdu.com',
         'requirements'   => [
            'glpi'   => [
               'min' => '9.1'
            ]
         ]
      ];
   }

   /**
    * Optional : check prerequisites before install : may print errors or add to message after redirect
    *
    * @return boolean
    */
   function plugin_myexample_check_prerequisites() {
      //do what the checks you want
      return true;
   }

   /**
    * Check configuration process for plugin : need to return true if succeeded
    * Can display a message only if failure and $verbose is true
    *
    * @param boolean $verbose Enable verbosity. Default to false
    *
    * @return boolean
    */
   function plugin_myexample_check_config($verbose = false) {
      if (true) { // Your configuration check
         return true;
      }

      if ($verbose) {
         echo "Installed, but not configured";
      }
      return false;
   }

Plugin informations provided in ``plugin_version_myexample`` method will be displayed in the GLPI plugins user interface.

.. _plugins_checks:

Requirements checking
~~~~~~~~~~~~~~~~~~~~~

Since GLPI 9.2; it is possible to provide some requirement informations along with the informations array. Those informations are not mandatory, but we encourage you to migrate :)

.. warning::

   Even if this has been deprecated for a wile, many plugins continue to provide a ``minGlpiVersion`` entry in the informations array. If this value is set; it will be automatically used as minimal GLPI version.

In order to set your requirements, add a ``requirements`` entry in the ``plugin_version_myexample`` informations array. Let's say your plugin is compatible with a version of GLPI comprised between 0.90 and 9.2; with a minimal version of PHP set to 7.0. The method would look like:

.. code-block:: php

   <?php

   function plugin_version_myexample() {
      return [
         'name'           => 'Plugin name that will be displayed',
         'version'        => MYEXAMPLE_VERSION,
         'author'         => 'John Doe and <a href="http://foobar.com">Foo Bar</a>',
         'license'        => 'GLPv3',
         'homepage'       => 'http://perdu.com',
         'requirements'   => [
            'glpi'   => [
               'min' => '0.90',
               'max' => '9.2'
            ],
            'php'    => [
               'min' => '7.0'
            ]
         ]
      ];
   }

``requirements`` array may take the following values:

* ``glpi``

   * ``min``: minimal GLPI version required,
   * ``max``: maximal supported GLPI version,
   * ``dev``: whether the plugin is supported on development versions (`9.2-dev` for example),
   * ``params``: an array of GLPI parameters names that must be set (not empty, not null, not false),
   * ``plugins``: an array of plugins name your plugin depends on (must be installed and active).

* ``php``

   * ``min``: minimal PHP version required,
   * ``max``: maximal PHP version supported (discouraged),
   * ``params``: an array of parameters name that must be set (retrieved from ``ini_get()``),
   * ``exts``: array of used extensions (see below).

PHP extensions checks rely on core capabilities. You have to provide a multi dimensionnal array with extension name as key. For each of those entries; you can define if the extension is required or not, and optionnally a class or a function to check.

The following example is from the core:

.. code-block:: php

   <?php
   $extensions = [
      'mysqli'    => [
         'required'  => true
      ],
      'fileinfo'  => [
         'required'  => true,
         'class'     => 'finfo'
      ],
      'json'      => [
         'required'  => true,
         'function'  => 'json_encode'
      ],
      'imap'      => [
         'required'  => false
      ]
   ];

* the ``mysqli`` extension is mandatory; ``extension_loaded()`` function will be used for check;
* the ``fileinfo`` extension is mandatory; ``class_exists()`` function will be used for check;
* the ``json`` extension is madatory; ``function_exists()`` function will be used for check;
* the ``imap`` extension is not mandatory.

.. note::

   Optionnal extensions are not yet handled in the checks function; but will probably be in the future. You can add them to the configuration right now :)

Without using automatic requirements; it's up to you to check with something like the following in the ``plugin_myexample_check_prerequisites``:

.. warning::

   Automatic requirements and manual checks are not exclusive. Both will be played! If you want to use automatic requirements with GLPI >= 9.2 and still provide manual checks for older versions; be careful not to indicate different versions.

.. code-block:: php

   <?php
      // Version check
      if (version_compare(GLPI_VERSION, '9.1', 'lt') || version_compare(GLPI_VERSION, '9.2', 'ge')) {
         if (method_exists('Plugin', 'messageIncompatible')) {
            //since GLPI 9.2
            Plugin::messageIncompatible('core', 9.1, 9.2);
         } else {
            echo "This plugin requires GLPI >= 9.1 and < 9.2";
         }
         return false;
      }


.. note::

   Since GLPI 9.2, you can rely on ``Plugin::messageIncompatible()`` to display internationalized messages when GLPI or PHP versions are not met.

   On the same model, you can use ``Plugin::messageMissingRequirement()`` to display internationalized message if any extension, plugin or GLPI parameter is missing.


.. _plugins_hookphp:

hook.php
^^^^^^^^

This file will contains hooks that GLPI may call under some user actions. Refer to core documentation to know more about available hooks.

For instance, a plugin need both an install and an uninstall hook calls. Here is the minimal file:

.. code-block:: php

   <?php
   /**
    * Install hook
    *
    * @return boolean
    */
   function plugin_myexample_install() {
      //do some stuff like instanciating databases, default values, ...
      return true;
   }

   /**
    * Uninstall hook
    *
    * @return boolean
    */
   function plugin_myexample_uninstall() {
      //to some stuff, like removing tables, generated files, ...
      return true;
   }

Coding standards
^^^^^^^^^^^^^^^^

You must respect GLPI's :doc:`global coding standards <../coding_standards/index>`.

In order to check for coding standards compliance, you can add the `glpi-project/coding-standard` to your composer file, using:

.. code-block:: bash

   $ composer require --dev glpi-project/coding-standard

This will install the latest version of the coding-standard used in GLPI core. If you want to use an loder version of the checks (for example if you have a huge amount of work to fix!), you can specify a version in the above command like ``glpi-project/coding-standard:0.5``. Refer to the `coding-standard project changelog <https://github.com/glpi-project/coding-standard/blob/master/CHANGELOG.md>`_ to know more ;)

You can then for example add a line in your ``.travis.yml`` file to automate checking:

.. code-block:: yaml

   script:
     - vendor/bin/phpcs -p --ignore=vendor --standard=vendor/glpi-project/coding-standard/GlpiStandard/ .

.. note::

   Coding standards and theirs checks are enabled per default using the `empty plugin facilities <http://glpi-plugins.readthedocs.io/en/latest/empty/>`_
