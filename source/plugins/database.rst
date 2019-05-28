Database
--------

.. warning::

   A plugin should **never** change core's database! It just add its own tables to manage its own data.

Of course, plugins rely on :ref:`GLPI database model <dbmodel>` and must therefore respect :ref:`database naming conventions <dbnaming_conventions>`.

Creating, updating or removing tables is done by the plugin, at installation, update or uninstallation; functions added in the ``hook.php`` file will be used for that; and you will rely on the `Migration class <https://forge.glpi-project.org/apidoc/class-Migration.html>`_ provided from GLPI core. Please refer to this documentation do know more about various `Migration` possibilities.

Creating and updating tables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Creating and updating tables must be done in the plugin installation process. You will add the required code to the ``plugin_{myplugin}_install``. As the same function is used for both installation and update, you'll have to make tests to know what to do.

For example, we will create a basic table to store some configuration for our plugin:

.. code-block:: php

   <?php

   /**
    * Install hook
    *
    * @return boolean
    */
   function plugin_myexample_install() {
      global $DB;

      //instanciate migration with version
      $migration = new Migration(100);

      //Create table only if it does not exists yet!
      if (!$DB->tableExists('glpi_plugin_myexample_configs')) {
         //table creation query
         $query = "CREATE TABLE `glpi_plugin_myexample_config` (
                     `id` INT(11) NOT NULL autoincrement,
                     `name` VARCHAR(255) NOT NULL,
                     PRIMARY KEY  (`id`)
                  ) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci";
         $DB->queryOrDie($query, $DB->error());
      }

      //execute the whole migration
      $migration->executeMigration();

      return true;
   }

The update part is quite the same. Considering our previous example, we missed to add a field in the configuration table to store the config value; and we should add an index on the ``name`` column. The code will become:

.. code-block:: php

   <?php
   /**
    * Install hook
    *
    * @return boolean
    */
   function plugin_myexample_install() {
      global $DB;

      //instanciate migration with version
      $migration = new Migration(100);

      //Create table only if it does not exists yet!
      if (!$DB->tableExists('glpi_plugin_myexample_configs')) {
         //table creation query
         $query = "CREATE TABLE `glpi_plugin_myexample_configs` (
                     `id` INT(11) NOT NULL autoincrement,
                     `name` VARCHAR(255) NOT NULL,
                     PRIMARY KEY  (`id`)
                  ) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci";
         $DB->queryOrDie($query, $DB->error());
      }

      if (TableExists('glpi_plugin_myexample_configs')) {
         //missed value for configuration
         $migration->addField(
            'glpi_plugin_myexample_configs',
            'value',
            'string'
         );

         $migration->addKey(
            'glpi_plugin_myexample_configs',
            'name'
         );
      }

      //execute the whole migration
      $migration->executeMigration();

      return true;
   }

Of course, we can also add or remove tables in our upgrade process, drop fields, keys, ... Well, do just what you need to do :-)

Deleting tables
^^^^^^^^^^^^^^^

You will have to drop all plugins tables when it will be uninstalled. Just put your code into the ``plugin_{myplugin]_uninstall`` function:

.. code-block:: php

   <?php
   /**
    * Uninstall hook
    *
    * @return boolean
    */
   function plugin_myexample_uninstall() {
      global $DB;
      
      $tables = [
         'configs'
      ];

      foreach ($tables as $table) {
         $tablename = 'glpi_plugin_myexample_' . $table;
         //Create table only if it does not exists yet!
         if ($DB->tableExists($tablename)) {
            $DB->queryOrDie(
               "DROP TABLE `$tablename`",
               $DB->error()
            );
         }
      }

      return true;
   }
