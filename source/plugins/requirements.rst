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
         echo "This plugin requires GLPI >= 9.1 and < 9.2";
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

