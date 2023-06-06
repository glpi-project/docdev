.. include:: /globals.rst

Guidelines
----------

Directories structure
^^^^^^^^^^^^^^^^^^^^^

Real structure will depend of what your plugin propose. See :doc:`requirements <requirements>` to find out what is needed. You may also want to :ref:`take a look at GLPI File Hierarchy Standard <fhs>`.

.. warning::

   The main directory name of your plugin may contain only alphanumeric characters (no ``-`` or ``_`` or accented characters or else).

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
* a `LICENSE` file containing the license,
* `MyPlugin.xml` and `MyPlugin.png` can be used to reference your plugin on the `plugins directory website <http://plugins.glpi-project.org>`_,
* the required `setup.php` and `hook.php` files.

Where to write files?
+++++++++++++++++++++

.. warning::

   Plugins my never ask user to give them write access on their own directory!

The GLPI installation already ask for administrator to get write access on its ``files`` directory; just use ``GLPI_PLUGIN_DOC_DIR/{plugin_name}`` (that would resolve to ``glpi_dir/files/_plugins/{plugin_name}`` in default basic installations).

Make sure to create the plugin directory at install time, and to remove it on uninstall.

Versionning
^^^^^^^^^^^

We recommend you to use `semantic versionning <http://semver.org/>`_ for you plugins. You may find existing plugins that have adopted another logic; some have reasons, others don't... Well, it is up to you finally :-)

Whatever the versioning logic you adopt, you'll have to be consistent, it is not easy to change it without breaking things, once you've released something.

ChangeLog
^^^^^^^^^

Many projects make releases without providing any changelog file. It is not simple for any end user (whether a developer or not) to read a repository log or a list of tickets to know what have changed between two releases.

Keep in mind it could help users to know what have been changed. To achieve this, take a look at `Keep an ChangeLog <http://keepachangelog.com/>`_, it will explain you some basics and give you guidelines to maintain sug a thing.

Third party libraries
^^^^^^^^^^^^^^^^^^^^^

Just like GLPI, you should use the :ref:`composer tool to manage third party libraries <3rd_party_libs>` for your plugin.
