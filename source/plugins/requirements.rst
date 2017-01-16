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
      //some code here, like call to Plugin::registerClass(), populating PLUGIN_HOOKS? ...
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
         'minGlpiVersion' => '9.1'
      ];
   }

   /**
    * Optional : check prerequisites before install : may print errors or add to message after redirect
    *
    * @return boolean
    */
   function plugin_myexample_check_prerequisites() {
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

You must respect GLPI's :doc:`global coding standards <../codingstandards>`.

In order to check for coding standards compliance, you can add the `glpi-projecT/coding-standard` to your composer file, using:

.. code-block:: bash

   $ composer require --dev glpi-project/coding-standard

This will install the latest version of the coding-standard used in GLPI core. If you want to use an loder version of the checks (for example if you have a huge amount of work to fix!), you can specify a version in the above command like ``glpi-project/coding-standard:0.5``. Refer to the `coding-standard project changelog <https://github.com/glpi-project/coding-standard/blob/master/CHANGELOG.md>`_ to know more ;)

You can then for example add a line in your ``.travis.yml`` file to automate checking:

.. code-block:: yaml

   script:
     - vendor/bin/phpcs -p --ignore=vendor --ignore=js --standard=vendor/glpi-project/coding-standard/GlpiStandard/ .

.. note::

   Coding standards and theirs checks are enabled per default using the `empty plugin facilities <http://glpi-plugins.readthedocs.io/en/latest/empty/>`_
