.. include:: /globals.rst

Plugins
=======

GLPi provides facilities to develop plugins, and there are many `plugins that have been already published <plugins_dir_website_>`_.

Generally speaking, there is really a few things you have to do in order to get a plugin working; many considerations are up to you. Anyways, this guide will provide you some guidelines to get a plugins repository as consistent as possible :)

If you want to see more advanced examples of what it is possible to do with plugins, you can take a look at the `example plugin source code <http://github.com/pluginsGLPI/example/>`_.

.. _plugins_requirements:

Requirements
------------

* plugin will be installed by creating a directory in the ``plugins`` directory of the GLPi instance,
* plugin directory name should never change,
* each plugin **must** at least provides :ref:`setup.php <plugins_setupphp>` and :ref:`hook.php <plugins_hookphp>` files,
* if your plugin requires a newer PHP version than GLPi one, or extensions that are not mandatory in core; it is up to you to check that in the install process.

.. _plugins_setupphp:

setup.php
^^^^^^^^^

The plugin's `setup.php` file will be automatically loaded from GLPi's core in order to get its version, to check pre-requisites, etc.

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

This file will contains hooks that GLPi may call under some user actions. Refer to core documentation to know more about available hooks.

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

You must respect GLPi's :doc:`global coding standards <../codingstandards>`


Guidelines
----------

Directories structure
^^^^^^^^^^^^^^^^^^^^^

Real structure will depend of what your plugin propose. See :ref:`requirements below <plugins_requirements>` to find out what is needed.

The plugin directory structure should look like the following:

* |folder| `MyPlugin`

  * |folder| `front`

    * |phpfile| `...`

  * |folder| `inc`

    * |phpfile| `...`

  * |folder| `locale`

    * |file| `...`

  * |folder| `tools`

    * |file| `...`

  * |file| `README.md`
  * |file| `LICENSE`
  * |phpfile| `setup.php`
  * |phpfile| `hook.php`
  * |file| `MyPlugin.xml`
  * |file| `MyPlugin.png`
  * |file| `...`
  * |phpfile| `...`

* `front` will host all PHP files directly used to display something to the user,
* `inc` will host all classes,
* if you internationalize your plugin, localization files will be found under the `locale` directory,
* if you need any scripting tool (like something to extract or update your translatable strings), you can put them in the `tools` directory
* a `README.md` file describing the plugin features, how to install it, and so on,
* a `LICENSE` file contaiing the license,
* `MyPlugin.xml` and `MyPlugin.png` can be used to reference your plugin on the `plugins directory website <plugins_dir_website_>`_,
* the required `setup.php` and `hook.php` files.

Versionning
^^^^^^^^^^^

We recommand you to use `semantic versionning <http://semver.org/>` for you plugins. You may find existing plugins that have adopted another logic; some have reasons, others don't... Well, it is up to you finally :-)

Whatever the versionning logic you adopt, you'll have to be consistent, it is not easy to change it without breaking things, once you've released something.

.. _plugins_dir_website: http://plugins.glpi-project.org/
