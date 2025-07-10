Plugin development tutorial
===========================

This tutorial explores the basic concepts of GLPI while building a simple plugin. It has been written to be explained during a training session, but most of this document could be read and used by people wanting to write plugins. Don't hesitate to suggest enhancements or contribute at this address: https://github.com/glpi-project/docdev

.. warning::

    ⚠️ Several prerequisites are required in order to follow this tutorial:

    - A base knowledge of GLPI usage
    - A correct level in web development:

        - PHP
        - HTML
        - CSS
        - SQL
        - JavaScript (JQuery)
    - Being familiar with command line usage


📝 In this first part, we will create a plugin named "My plugin" (key: ``myplugin``).
We will cover project startup as well as the setup of base elements.

Prerequisites
--------------

Here are all the things you need to start your GLPI plugin project:

* a functional web server,
* latest `GLPI <https://github.com/glpi-project/glpi/releases>`_ stable release installed locally
* a text editor or any IDE (like `vscode <https://code.visualstudio.com>`_ or `phpstorm <https://www.jetbrains.com/phpstorm/>`_),
* `git <https://git-scm.com/>`_ version management software.

You may also need:

* `Composer`_ PHP dependency software, to handle PHP libraries specific for your plugin.
* `Npm`_ JavaScript dependency software, to handle JavaScript libraries specific for your plugin.

Start your project
------------------

.. warning::

    ⚠️ If you have production data in your GLPI instance, make sure you disable all notifications before beginning the development.
    This will prevent sending of tests messages to users present in the imported data.

First of all, a few resources:

* `Empty`_ plugin and its `documentation <https://glpi-plugins.readthedocs.io/en/latest/empty/index.html>`_. This plugin is a kind of skeleton for quick starting a brand new plugin.
* `Example <https://github.com/pluginsGLPI/example>`_ plugin. It aims to do an exhaustive usage of GLPI internal API for plugins.

My new plugin
^^^^^^^^^^^^^

Clone ``empty`` plugin repository in you GLPI ``plugins`` directory:

::

   cd /path/to/glpi/plugins
   git clone https://github.com/pluginsGLPI/empty.git

You can use the ``plugin.sh`` script in the ``empty`` directory to create your new plugin. You must pass it the name of your plugin and the first version number. In our example:

::

   cd empty
   chmod +x plugin.sh
   ./plugin.sh myplugin 0.0.1

.. note::

    | ℹ️ Several conditions must be respected choosing a plugin name: no space or special character is allowed.
    | This name will be used to declare your plugin directory, as well as methods, constants, database tables and so on.
    | ``My-Plugin`` will therefore create the ``MyPlugin`` directory.
    | Using capital characters will cause issues for some core functions.

    Keep it simple!

When running the command, a new directory ``myplugin`` will be created at the same level as the ``empty`` directory (both in ``/path/to/glpi/plugin`` directory) as well as files and methods associated with an empty plugin skeleton.

.. note::

    ℹ️ If you cloned the ``empty`` project outside your GLPI instance, you can define a destination directory for your new plugin:

    .. code-block:: shell

        ./plugin.sh myplugin 0.0.1 /path/to/another/glpi/plugins/

Retrieving `Composer`_ dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In a terminal, run the following command:

::

   cd /path/to/glpi/plugins/myplugin
   composer install


Minimal plugin structure
^^^^^^^^^^^^^^^^^^^^^^^^

.. raw:: html

   <pre>
   📂 glpi
     📂 plugins
       📂 myplugin
          📁 ajax
          📁 front
          📁 src
          📁 locales
          📁 tools
          📁 vendor
          🗋 composer.json
          🗋 hook.php
          🗋 LICENSE
          🗋 myplugin.xml
          🗋 myplugin.png
          🗋 Readme.md
          🗋 setup.php
   </pre>

* ``📂 front`` directory is used to store our object actions (create, read, update, delete).
* ``📂 ajax`` directory is used for ajax calls.
* Your plugin own classes will be stored in the ``📂 src`` directory.
* `gettext`_ translations will be stored in the ``📂 locales`` directory.
* An optional ``📂 templates`` directory would contain your plugin `Twig <https://twig.symfony.com/>`_ template files.
* ``📂 tools`` directory provides some optional scripts from the empty plugin for development and maintenance of your plugin. It is now more common to get those scripts from ``📂 vendor`` and ``📂 node_modules`` directories.
* ``📂 vendor`` directory contains:

  * PHP libraries for your plugin,
  * helpful tools provided by ``empty`` model.

* ``📂 node_modules`` directory contains JavaScript libraries for your plugin.
* ``🗋 composer.json`` files describes PHP dependencies for your project.
* ``🗋 package.json`` file describes JavaScript dependencies for your project.
* ``🗋 myplugin.xml`` file contains data description for :ref:`publishing your plugin <plugin_publication>`.
* ``🗋 myplugin.png`` image is often included in previous XML file as a representation for `GLPI plugins catalog <http://plugins.glpi-project.org>`_
* ``🗋 setup.php`` file is meant to :ref:`instantiate your plugin <plugin_minimal_setupphp>`.
* ``🗋 hook.php`` file :ref:`contains your plugin basic functions <plugin_minimal_hookphp>` (install/uninstall, hooks, etc).

.. _plugin_minimal_setupphp:

minimal setup.php
^^^^^^^^^^^^^^^^^

After running ``plugin.sh`` script, there must be a ``🗋 setup.php`` file in your ``📂 myplugin`` directory.

It contains the following code:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   define('PLUGIN_MYPLUGIN_VERSION', '0.0.1');

An optional constant declaration for your plugin version number used later in the ``plugin_version_myplugin`` function.

**🗋 setup.php**

.. code-block:: php
   :lineno-start: 3

   <?php

   function plugin_init_myplugin() {
      global $PLUGIN_HOOKS;

      //hooks declarations here...
   }

This instanciation function is important, we will declare later here `Hooks` on GLPI internal API.
It's systematically called on **all** GLPI pages except if the ``_check_prerequisites`` fails (see below).

**🗋 setup.php**

.. code-block:: php
   :lineno-start: 9

   <?php

   // Minimal GLPI version, inclusive
   define("PLUGIN_MYPLUGIN_MIN_GLPI_VERSION", "10.0.0");

   // Maximum GLPI version, exclusive
   define("PLUGIN_MYPLUGIN_MAX_GLPI_VERSION", "10.0.99");

   function plugin_version_myplugin()
   {
       return [
           'name'           => 'MonNouveauPlugin',
           'version'        => PLUGIN_MYPLUGIN_VERSION,
           'author'         => '<a href="http://www.teclib.com">Teclib\'</a>',
           'license'        => 'MIT',
           'homepage'       => '',
           'requirements'   => [
               'glpi' => [
                   'min' => PLUGIN_MYPLUGIN_MIN_GLPI_VERSION,
                   'max' => PLUGIN_MYPLUGIN_MAX_GLPI_VERSION,
               ]
       ];
   }

This function specifies data that will be displayed in the ``Setup > Plugins`` menu of GLPI as well as some minimal constraints.
We reuse the constant ``PLUGIN_MYPLUGIN_VERSION`` declared above.
You can of course change data according to your needs.

.. note::

    ℹ️ **Choosing a license**

    The choice of a license is **important** and has many consequences on the future use of your developments. Depending on your preferences, you can choose a more permissive or restrictive orientation.
    Websites that can be of help exists, like https://choosealicense.com/.

    In our example, `MIT <https://fr.wikipedia.org/wiki/Licence_MIT>`_ license has been choose.
    It's a very popular choice which gives user enough liberty using your work. It just asks to keep the notice (license text) and respect the copyright. You can't be dispossessed of your work, paternity must be kept.

**🗋 setup.php**

.. code-block:: php
   :lineno-start: 32

   <?php

   function plugin_myplugin_check_config($verbose = false)
   {
       if (true) { // Your configuration check
           return true;
       }

       if ($verbose) {
           _e('Installed / not configured', 'myplugin');
       }

       return false;
   }

This function is systematically called on **all** GLPI pages.
It allows to automatically deactivate plugin if defined criteria are not or no longer met (returning ``false``).

.. _plugin_minimal_hookphp:

minimal hook.php
^^^^^^^^^^^^^^^^

This file must contains installation and uninstallation functions:

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   function plugin_myplugin_install()
   {
       return true;
   }

   function plugin_myplugin_uninstall()
   {
       return true;
   }

When all steps are OK, we must return ``true``.
We will populate these functions later while creating/removing database tables.


Install your plugin
^^^^^^^^^^^^^^^^^^^

.. image:: /_static/images/install_plugin.png
   :alt: my plugin in confiuguration

Following those first steps, you should be able to install and activate your plugin from ``Setup > Plugins`` menu.


Creating an object
------------------

| 📝 In this part, we will add an itemtype to our plugin and make it interact with GLPI.
| This will be a parent object that will regroup several "assets".
| We will name it "Superasset".

.. _commondntm_usage:

`CommonDBTM`_ usage and classes creation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This super class adds the ability to manage items in the database.
Your working classes (in the ``src`` directory) can inherit from it and are called "itemtype" by convention.

.. note::

    ℹ️ **Conventions:**

    * Classes must respect `PSR-12 naming conventions <https://www.php-fig.org/psr/psr-12/>`_. We maintain a :doc:`guide on coding standards <../codingstandards>`

    * :ref:`SQL tables <dbnaming_conventions>` related to your classes must respect that naming convention: ``glpi_plugin_pluginkey_names``

        * a global ``glpi_`` prefix
        * a prefix for plugins ``plugin_``
        * plugin key ``myplugin_``
        * itemtype name in plural form ``superassets``

    * :ref:`Tables columns <dbfields>` must also follow some conventions:

        * there must be an ``auto-incremented primary`` field named ``id``
        * foreign keys names use that referenced table name without the global ``glpi_`` prefix and with and ``_id`` suffix. example: ``plugin_myotherclasses_id`` references ``glpi_plugin_myotherclasses`` table

        **Warning!** GLPI does not use database foreign keys constraints. Therefore you must not use ``FOREIGN`` or ``CONSTRAINT`` keys.

    * Some extra advice:

        * always end your files with an extra carriage return
        * never use the closing PHP tag ``?>`` - see https://www.php.net/manual/en/language.basic-syntax.instruction-separation.php

        Main reason for that is to avoid concatenation errors when using require/include functions, and prevent unexpected outputs.

We will create our first class in ``🗋 Superasset.php`` file in our plugin ``📂src`` directory:

.. raw:: html

   <pre>
   📂glpi
      📂plugins
         📂myplugin
            ...
            📂src
               🗋 Superasset.php
            ...
   </pre>

We declare a few parts:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php
   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;

   class Superasset extends CommonDBTM
   {
       // right management, we'll change this later
       static $rightname = 'computer';

       /**
        *  Name of the itemtype
        */
       static function getTypeName($nb=0)
       {
           return _n('Super-asset', 'Super-assets', $nb);
       }
   }

.. warning::

    ⚠️ ``namespace`` must be `CamelCase <https://en.wikipedia.org/wiki/Camel_case>`_

.. note::

    ℹ️  Here are most common `CommonDBTM`_ inherited methods:

    `add(array $input) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1229-L1240>`_
    :  Add an new object in database table.
    ``input`` parameter contains table fields.
    If add goes well, the object will be populated with provided data.
    It returns the id of the new added line, or ``false`` if there were an error.

    .. code-block:: php
       :linenos:

        <?php

        namespace GlpiPlugin\Myplugin;

        $superasset = new Superasset;
        $superassets_id = $superasset->add([
            'name' => 'My super asset'
        ]);
        if (!superassets_id) {
            //super asset has not been created :'(
        }

    `getFromDB(integer $id) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L285-L292>`_
    :  load an item from database into current object using its id.
    Fetched data will be available from ``fields`` object property.
    It returns ``false`` if the object does not exists.

    .. code-block:: php
        :lineno-start: 11

        <?php

        if ($superasset->getFromDB($superassets_id)) {
            //super $superassets_id has been lodaded.
            //you can access its data from $superasset->fields
        }

    `update(array $input) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1561-L1570>`_
    :  update fields of ``id`` identified line with ``$input`` parameter.
    The ``id`` key must be part of ``$input``.
    Returns a boolean.

    .. code-block:: php
        :lineno-start: 16

        <?php

        if (
            $superasset->update([
                'id'      => $superassets_id,
                'comment' => 'my comments'
            ])
        ) {
            //super asset comment has been updated in databse.
        }

    `delete(array $input, bool $force = false) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2027-L2036>`_
    :  remove ``id`` identified line corresponding.
    The ``id`` key must be part of ``$input``.
    ``$force`` parameter indicates if the line must be place in trashbin (``false``, and a ``is_deleted`` field must be present in the table) or removed (``true``).
    Returns a boolean.

    .. code-block:: php
        :lineno-start: 23

        <?php

        if ($superasset->delete(['id' => $superassets_id])) {
            //super asset has been moved to trashbin
        }

        if ($superasset->delete(['id' => $superassets_id], true)) {
            //super asset is no longer present in database.
            //a message will be displayed to user on next displayed page.
        }

Installation
^^^^^^^^^^^^

In the ``plugin_myplugin_install`` function of your ``🗋 hook.php`` file, we will manage the creation of the database table corresponding to our itemtype ``Superasset``.

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use DBConnection;
   use GlpiPlugin\Myplugin\Superasset;
   use Migration;

   function plugin_myplugin_install()
   {
       global $DB;

       $default_charset   = DBConnection::getDefaultCharset();
       $default_collation = DBConnection::getDefaultCollation();

       // instantiate migration with version
       $migration = new Migration(PLUGIN_MYPLUGIN_VERSION);

       // create table only if it does not exist yet!
       $table = Superasset::getTable();
       if (!$DB->tableExists($table)) {
           //table creation query
           $query = "CREATE TABLE `$table` (
                     `id`         int unsigned NOT NULL AUTO_INCREMENT,
                     `is_deleted` TINYINT NOT NULL DEFAULT '0',
                     `name`      VARCHAR(255) NOT NULL,
                     PRIMARY KEY  (`id`)
                    ) ENGINE=InnoDB
                    DEFAULT CHARSET={$default_charset}
                    COLLATE={$default_collation}";
           $DB->queryOrDie($query, $DB->error());
       }

       //execute the whole migration
       $migration->executeMigration();

       return true;
   }

In addition, of a primary key, ``VARCHAR`` field to store a name entered by the user and a flag for the the trashbin.

.. note::
    📝 You of course can add some other fields with other types (stay reasonable 😉).

To handle migration from a version to another of our plugin, we will use GLPI `Migration`_ class.

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use Migration;

   function plugin_myplugin_install()
   {
       global $DB;

       // instantiate migration with version
       $migration = new Migration(PLUGIN_MYPLUGIN_VERSION);

       ...

       if ($DB->tableExists($table)) {
           // missing field
           $migration->addField(
               $table,
               'fieldname',
               'string'
           );

           // missing index
           $migration->addKey(
               $table,
               'fieldname'
           );
       }

       //execute the whole migration
       $migration->executeMigration();

       return true;
   }

.. warning::

  ℹ️ `Migration`_ class provides several methods that permit to manipulate tables and fields.
  All calls will be stored in queue that will be executed when calling ``executeMigration`` method.

  Here are some examples:

  `addField($table, $field, $type, $options) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L389-L407>`_
    adds a new field to a table

  `changeField($table, $oldfield, $newfield, $type, $options) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L462-L479>`_
    change a field name or type

  `dropField($table, $field) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L534-L542>`_
    drops a field

  `dropTable($table) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L553-L560>`_
    drops a table

  `renameTable($oldtable, $newtable) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L654-L662>`_
    rename a table

  See `Migration`_ documentation for all other possibilities.

  .. raw:: html

    <hr />

  ``$type`` parameter of different functions is the same as the private `Migration::fieldFormat() method <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L252-L262>`_ it allows shortcut for most common SQL types (bool, string, integer, date, datetime, text, longtext,  autoincrement, char)


Uninstallation
^^^^^^^^^^^^^^

To uninstall our plugin, we want to clean all related data.

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;

   function plugin_myplugin_uninstall()
   {
       global $DB;

       $tables = [
           Superasset::getTable(),
       ];

       foreach ($tables as $table) {
           if ($DB->tableExists($table)) {
               $DB->doQueryOrDie(
                   "DROP TABLE `$table`",
                   $DB->error()
               );
           }
       }

      return true;
   }


Framework usage
^^^^^^^^^^^^^^^

Some useful functions

.. code-block:: php

   <?php

   Toolbox::logError($var1, $var2, ...);

This method stored in ``glpi/files/_log/php-errors.log`` file content of its parameters (may be strings, arrays, objects, etc).

.. code-block:: php

   <?php

   Html::printCleanArray($var);

This method will display a "debug" array of the provided variable. It only accepts ``array`` type.


Common actions on an object
---------------------------

.. note::

    📝 We will now add most common actions to our ``Superasset`` itemtype:

    * display a list and a form to add/edit
    * define add/edit/delete routes

In our ``front`` directory, we will need two new files.

.. raw:: html

   <pre>
   📂 glpi
      📂 plugins
         📂 myplugin
            ...
            📂 front
               🗋 superasset.php
               🗋 superasset.form.php
            ...
   </pre>


.. warning::

    ℹ️ Into those files, we will import GLPI framework with the following:

    .. code-block:: php

        <?php

        include ('../../../inc/includes.php');

First file (``superasset.php``) will display list of items stored in our table.

It will use the internal search engine ``show`` method of the :doc:`search engine <../devapi/search>`.

**🗋 front/superasset.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;
   use Search;
   use Html;

   include ('../../../inc/includes.php');

   Html::header(
       Superasset::getTypeName(),
       $_SERVER['PHP_SELF'],
       "plugins",
       Superasset::class,
       "superasset"
   );
   Search::show(Superasset::class);
   Html::footer();

``header`` and ``footer`` methods from `Html`_ class permit to rely on GLPI graphical user interface (menu, breadcrumb, page footer, etc).

Second file (``superasset.form.php`` - with ``.form`` suffix) will handle CRUD actions.

**🗋 front/superasset.form.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;
   use Html;

   include ('../../../inc/includes.php');

   $supperasset = new Superasset();

   if (isset($_POST["add"])) {
       $newID = $supperasset->add($_POST);

       if ($_SESSION['glpibackcreated']) {
           Html::redirect(Superasset::getFormURL()."?id=".$newID);
       }
       Html::back();

   } else if (isset($_POST["delete"])) {
       $supperasset->delete($_POST);
       $supperasset->redirectToList();

   } else if (isset($_POST["restore"])) {
       $supperasset->restore($_POST);
       $supperasset->redirectToList();

   } else if (isset($_POST["purge"])) {
       $supperasset->delete($_POST, 1);
       $supperasset->redirectToList();

   } else if (isset($_POST["update"])) {
       $supperasset->update($_POST);
       \Html::back();

   } else {
       // fill id, if missing
       isset($_GET['id'])
           ? $ID = intval($_GET['id'])
           : $ID = 0;

       // display form
       Html::header(
          Superasset::getTypeName(),
          $_SERVER['PHP_SELF'],
          "plugins",
          Superasset::class,
          "superasset"
       );
       $supperasset->display(['id' => $ID]);
       Html::footer();
   }

All common actions defined here are handled from `CommonDBTM`_ class.
For missing display action, we will create a ``showForm`` method in our ``Superasset`` class.
Note this one already exists in ``CommonDBTM`` and is displayed using a generic Twig template.

We will use our own template that will extends the generic one (because it only displays common fields).

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Glpi\Application\View\TemplateRenderer;

   class Superasset extends CommonDBTM
   {

        ...

       function showForm($ID, $options=[])
       {
           $this->initForm($ID, $options);
           // @myplugin is a shortcut to the **templates** directory of your plugin
           TemplateRenderer::getInstance()->display('@myplugin/superasset.form.html.twig', [
               'item'   => $this,
               'params' => $options,
           ]);

           return true;
       }
   }

**🗋 templates/superasset.form.html.twig**

.. code-block:: twig
   :linenos:

   {% extends "generic_show_form.html.twig" %}
   {% import "components/form/fields_macros.html.twig" as fields %}

   {% block more_fields %}
       blabla
   {% endblock %}

After that step, a call in our browser to `http://glpi/plugins/myplugin/front/superasset.form.php` should display the creation form.

.. warning::

    ℹ️  ``🗋 components/form/fields_macros.html.twig`` file imported in the example includes Twig functions or macros to display common HTML fields like:

    ``{{ fields.textField(name, value, label = '', options = {}) }}``
    : HTML code for a ``text`` input.

    ``{{ fields.hiddenField(name, value, label = '', options = {}) }``
    : HTML code for a ``hidden`` input.

    ``{{ dateField(name, value, label = '', options = {}) }``
    : HTML code for a date picker (using `flatpickr <https://flatpickr.js.org/>`_)

    ``{{ datetimeField(name, value, label = '', options = {}) }``
    : HTML code for a datetime picker (using `flatpickr <https://flatpickr.js.org/>`_)

    See ``🗋 templates/components/form/fields_macros.html.twig`` file in source code for more details and capacities.


Adding to menu and breadcrumb
-----------------------------

We would like to access our pages without entering their URL in our browser.

We'll therefore define our first `Hook` in our plugin ``init``.

Open ``setup.php`` and edit ``plugin_init_myplugin`` function:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;

   function plugin_init_myplugin()
   {
       ...

       // add menu hook
       $PLUGIN_HOOKS['menu_toadd']['myplugin'] = [
           // insert into 'plugin menu'
           'plugins' => Superasset::class
       ];
   }

This `hook` indicates our ``Superasset`` itemtype defines a menu display function.
Edit our class and add related methods:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;

   class Superasset extends CommonDBTM
   {
       ...

       /**
        * Define menu name
        */
       static function getMenuName($nb = 0)
       {
           // call class label
           return self::getTypeName($nb);
       }

       /**
        * Define additionnal links used in breacrumbs and sub-menu
        *
        * A default implementation is provided by CommonDBTM
        */
       static function getMenuContent()
       {
           $title  = self::getMenuName(Session::getPluralNumber());
           $search = self::getSearchURL(false);
           $form   = self::getFormURL(false);

           // define base menu
           $menu = [
               'title' => __("My plugin", 'myplugin'),
               'page'  => $search,

               // define sub-options
               // we may have multiple pages under the "Plugin > My type" menu
               'options' => [
                   'superasset' => [
                       'title' => $title,
                       'page'  => $search,

                       //define standard icons in sub-menu
                       'links' => [
                           'search' => $search,
                           'add'    => $form
                       ]
                   ]
               ]
           ];

           return $menu;
       }
   }

``getMenuContent`` function may seem redundant at first, but each of the coded entries relates to different parts of the display.
The ``options`` part is used to have a fourth level of breadcrumb and thus have a clickable submenu in your entry page.

.. image:: /_static/images/breadcrumbs.png
   :alt: Breadcrumb

Each ``page`` key is used to indicate on which URL the current part applies.

.. note::

    ℹ️ GLPI menu is loaded in ``$_SESSION['glpimenu']`` on login.
    To see your changes, either use the ``DEBUG`` mode, or disconnect and reconnect.

.. note::

    ℹ️ It is possible to have only one menu level for the plugin (3 globally), just move the ``links`` part to the first level of the ``$menu`` array.

.. note::

    ℹ️ It is also possible to define custom ``links``.
    You just need to replace the key (for example, add or search) with an html containing an image tag:

    .. code-block:: php

        'links' = [
            '<img src="path/to/my.png" title="my custom link">' => $url
        ]

Defining tabs
-------------

GLPI proposes three methods to define tabs:

`defineTabs(array $options = []) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonGLPI.php#L292-L302>`_: declares classes that provides tabs to current class.

`getTabNameForItem(CommonGLPI $item, boolean $withtemplate = 0) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonGLPI.php#L598-L611>`_: declares titles displayed for tabs.

`displayTabContentForItem(CommonGLPI $item, integer $tabnum = 1, boolean $withtemplate = 0) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonGLPI.php#L617-L628>`_: allow displaying tabs contents.

Standards tabs
^^^^^^^^^^^^^^

Some GLPI internal API classes allows you to add a behaviour with minimal code.

It's true for notes (`Notepad`_) and history (`Log`_).

Here is an example for both of them:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Notepad;
   use Log;

   class Superasset extends CommonDBTM
   {
       // permits to automaticaly store logs for this itemtype
       // in glpi_logs table
       public $dohistory = true;

       ...

       function defineTabs($options = [])
       {
           $tabs = [];
           $this->addDefaultFormTab($tabs)
               ->addStandardTab(Notepad::class, $tabs, $options)
               ->addStandardTab(Log::class, $tabs, $options);

           return $tabs;
       }
   }

Display of an instance of your itemtype from the page ``front/superasset.php?id=1`` should now have 3 tabs:

* Main tab with your itemtype name
* Notes tab
* History tab


Custom tabs
^^^^^^^^^^^

On a similar basis, we can target another class of our plugin:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Notepad;
   use Log;

   class Superasset extends CommonDBTM
   {
       // permits to automaticaly store logs for this itemtype
       // in glpi_logs table
       public $dohistory = true;

       ...

       function defineTabs($options = [])
       {
           $tabs = [];
           $this->addDefaultFormTab($tabs)
               ->addStandardTab(Superasset_Item::class, $tabs, $options);
               ->addStandardTab(Notepad::class, $tabs, $options)
               ->addStandardTab(Log::class, $tabs, $options);

           return $tabs;
       }

In this new class we will define two other methods to control title and content of the tab:

**🗋 src/Superasset_Item.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Glpi\Application\View\TemplateRenderer;

   class Superasset_Item extends CommonDBTM
   {
       /**
        * Tabs title
        */
       function getTabNameForItem(CommonGLPI $item, $withtemplate = 0)
       {
           switch ($item->getType()) {
               case Superasset::class:
                   $nb = countElementsInTable(self::getTable(),
                       [
                           'plugin_myplugin_superassets_id' => $item->getID()
                       ]
                   );
                   return self::createTabEntry(self::getTypeName($nb), $nb);
           }
           return '';
       }

       /**
        * Display tabs content
        */
       static function displayTabContentForItem(CommonGLPI $item, $tabnum = 1, $withtemplate = 0)
       {
           switch ($item->getType()) {
               case Superasset::class:
                   return self::showForSuperasset($item, $withtemplate);
           }

           return true;
       }

       /**
        * Specific function for display only items of Superasset
        */
       static function showForSuperasset(Superasset $superasset, $withtemplate = 0)
       {
           TemplateRenderer::getInstance()->display('@myplugin/superasset_item_.html.twig', [
               'superasset' => $superasset,
           ]);
       }
   }

As previously, we will use a Twig template to handle display.

**🗋 templates/superasset_item.html.twig**

.. code-block:: twig
   :linenos:

   {% import "components/form/fields_macros.html.twig" as fields %}

   example content

.. note::

    📝 **Exercise**:
    For the rest of this part, you will need to complete our plugin to allow the installation/uninstallation of the data of this new class ``Superasset_Item``.

    Table should contains following fields:

    * an identifier (id)
    * a foreign key to ``plugin_myplugin_superassets`` table
    * two fields to link with an itemtype:

       * ``itemtype`` which will store the itemtype class to link to (`Computer`_ for example)
       * ``items_id`` the id of the linked asset

    Your plugin must be re-installed or updated for the table creation to be done.
    You can force the plugin status to change by incrementing the version number in the ``setup.php`` file.

    For the exercise, we will only display computers (`Computer`_) displayed with the following code:

    .. code-block:: twig

        {{ fields.dropdownField(
            'Computer',
            'items_id',
            '',
            __('Add a computer')
        ) }}

    We will include a mini form to insert related items in our table. Form actions can be handled from ``myplugin/front/supperasset.form.php`` file.

    Note GLPI forms submitted as ``POST`` will be protected with a CRSF token..
    You can include a hidden field to validate the form:

    .. code-block:: twig

        <input type="hidden" name="_glpi_csrf_token" value="{{ csrf_token() }}">

    We will also display a list of computers already associated below the form.

.. _using-core-objects:

Using core objects
^^^^^^^^^^^^^^^^^^

We can also allow our class to add tabs on core objects.
We will declare this in a new line in our ``init`` function:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Computer;

   function plugin_init_myplugin()
   {
      ...

       Plugin::registerClass(GlpiPlugin\Myplugin\Superasset_Item::class, [
           'addtabon' => Computer::class
       ]);
   }

Title and content for this tab are done as previously with:

* ``CommonDBTM::getTabNameForItem()``
* ``CommonDBTM::displayTabContentForItem()``

.. note::

    📝 **Exercise**:
    Complete previous methods to display on computers a new tab with associated ``Superasset``.

Defining Search options
-----------------------

:ref:`Search options <search_options>` is an array of columns for GLPI search engine. They are used to know for each itemtype how the database must be queried, and how data should be displayed.

In our class, we must declare a ``rawSearchOptions`` method:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;

   class Superasset extends CommonDBTM
   {
       ...

       function rawSearchOptions()
       {
           $options = [];

           $options[] = [
               'id'   => 'common',
               'name' => __('Characteristics')
           ];

           $options[] = [
               'id'    => 1,
               'table' => self::getTable(),
               'field' => 'name',
               'name'  => __('Name'),
               'datatype' => 'itemlink'
           ];

           $options[] = [
               'id'    => 2,
               'table' => self::getTable(),
               'field' => 'id',
               'name'  => __('ID')
           ];

           $options[] = [
               'id'           => 3,
               'table'        => Superasset_Item::getTable(),
               'field'        => 'id',
               'name'         => __('Number of associated assets', 'myplugin'),
               'datatype'     => 'count',
               'forcegroupby' => true,
               'usehaving'    => true,
               'joinparams'   => [
                   'jointype' => 'child',
               ]
           ];

           return $options;
       }
   }

Following this addition, we should be able to select our new columns from our asset list page:

.. image:: /_static/images/search.png
   :alt: Search form

Those options will also be present in search criteria list of that page.

Each ``option`` is identified by an ``id`` key.
This key is used in other parts of GLPI.
It **must be absolutely unique**.
By convention, '1' and '2' are "reserved" for the object name and ID.

The :ref:`search options documentation <search_options>` describes all possible options.

Using other objects
^^^^^^^^^^^^^^^^^^^

It is also possible to improve another itemtype search options.
As an example, we would like to display associated "Superasset" on in the computer list:

**🗋 hook.php**

.. code-block:: php
   :lineno-start: 50

   <?php

   use GlpiPlugin\Myplugin\Superasset;
   use GlpiPlugin\Myplugin\Superasset_Item;

   ...

   function plugin_myplugin_getAddSearchOptionsNew($itemtype)
   {
       $sopt = [];

       if ($itemtype == 'Computer') {
           $sopt[] = [
               'id'           => 12345,
               'table'        => Superasset::getTable(),
               'field'        => 'name',
               'name'         => __('Associated Superassets', 'myplugin'),
               'datatype'     => 'itemlink',
               'forcegroupby' => true,
               'usehaving'    => true,
               'joinparams'   => [
                   'beforejoin' => [
                       'table'      => Superasset_Item::getTable(),
                       'joinparams' => [
                           'jointype' => 'itemtype_item',
                       ]
                   ]
               ]
           ];
       }

       return $sopt;
   }

As previously, you must provide an ``id`` for your new search options that does not override existing ones for ``Computer``.

You can use a script from the ``tools`` folder of the GLPI git repository (not present in the "release" archives) to help you list the **id** already declared (by the core and plugins present on your computer) for a particular itemtype.

.. code-block:: shell

   /usr/bin/php /path/to/glpi/tools/getsearchoptions.php --type=Computer

Search engine display preferences
---------------------------------

We just have added new columns to our itemtype list.
Those columns are handled by ``DisplayPreference`` object (``glpi_displaypreferences`` table).
They can be defined as global (set ``0`` for ``users_id`` field) or personal (set ``users_id`` field to the user id). They are sorted (``rank`` field) and target an itemtype plus a ``searchoption`` (``num`` field).

.. warning::

    **⚠️ Warning**
    Global preferences are applied to all users that don't have any personal preferences set.

.. note::

    📝 **Exercise**:
    You will change installation and uninstallation functions of your plugin to add and remove global preferences so objects list display some columns.

Standard events hooks
---------------------

During a GLPI object life cycle, we can intervene via our plugin before and after each event (add, modify, delete).

For our own objects, following methods can be implemented:

* `prepareInputForAdd <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1536-L1543>`_
* `post_addItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1549-L1554>`_
* `prepareInputForUpdate <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1977-L1984>`_
* `post_updateItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1990-L1997>`_
* `pre_deleteItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2248-L2254>`_
* `post_deleteItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2148-L2153>`_
* `post_purgeItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2158-L2163>`_

For every event applied on the database, we have a method that is executed before, and another after.

.. note::

    📝 **Exercise**:
    Add required methods to ``PluginMypluginSuperasset`` class to check the ``name`` field is properly filled when adding and updating.

    On effective removal, we must ensure linked data from other tables are also removed.

Plugins can also intercept standard core events to apply changes (or even refuse the event). Here are the names of the `hooks`:

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Plugin\Hooks;

   ...

   Hooks::PRE_ITEM_ADD;
   Hooks::ITEM_ADD;
   Hooks::PRE_ITEM_DELETE;
   Hooks::ITEM_DELETE;
   Hooks::PRE_ITEM_PURGE;
   Hooks::ITEM_PURGE;
   Hooks::PRE_ITEM_RESTORE;
   Hooks::ITEM_RESTORE;
   Hooks::PRE_ITEM_UPDATE;
   Hooks::ITEM_UPDATE;

More information are available from :ref:`hooks documentation <standards_hooks>` especially on :ref:`standard events <business_related_hooks>` part.

For all those calls, we will get an instance of the current object in parameter of our ``callback`` function. We will be able to access its current fields (``$item->fields``) or those sent by the form (``$item->input``).
As all PHP objects, this instance will be passed by reference.

We will declare one of those hooks usage in the plugin init function and add a ``callback`` function:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;

   ...

   function plugin_init_myplugin()
   {
      ...

       // callback a function (declared in hook.php)
       $PLUGIN_HOOKS['item_update']['myplugin'] = [
           'Computer' => 'myplugin_computer_updated'
       ];

       // callback a class method
       $PLUGIN_HOOKS['item_add']['myplugin'] = [
            'Computer' => [
                 Superasset::class, 'computerUpdated'
            ]
       ];
   }

In both cases (``hook.php`` function or class method), the prototype of the functions will be made on this model:

.. code-block:: php
   :linenos:

   <?php

   use CommonDBTM;
   use Session;

   function hookCallback(CommonDBTM $item)
   {
       ...

       // if we need to stop the process (valid for pre* hooks)
       if ($mycondition) {
           // clean input
           $item->input = [];

           // store a message in session for warn user
           Session::addMessageAfterRedirect('Action forbidden because...');

           return;
      }
   }

.. note::

    📝 **Exercise**:
    Use a `hook` to intercept the purge of a computer and remove associated with a ``Superasset`` lines if any.

Importing libraries (JavaScript / CSS)
--------------------------------------

Plugins can declare import of additional libraries from their ``init`` function.

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Plugin\Hooks;

   function plugin_init_myplugin()
   {
       ...

       // css & js
       $PLUGIN_HOOKS[Hooks::ADD_CSS]['myplugin'] = 'myplugin.css';
       $PLUGIN_HOOKS[Hooks::ADD_JAVASCRIPT]['myplugin'] = [
           'js/common.js',
       ];

       // on ticket page (in edition)
       if (strpos($_SERVER['REQUEST_URI'], "ticket.form.php") !== false
           && isset($_GET['id'])) {
           $PLUGIN_HOOKS['add_javascript']['myplugin'][] = 'js/ticket.js.php';
       }

       ...
   }

Several things to remember:

* Loading paths are relative to plugin directory.
* Scripts declared this way will be loaded on **all** GLPI pages. You must check the current page in the ``init`` function.
* You can rely on ``Html::requireJs()`` method to load external resources. Paths will be prefixed with GLPI root URL at load.
* If you want to modify page DOM and especially what is displayed in main form, you should call your code twice (on page load and on current tab load) and add a class to check the effective application of your code:

.. code-block:: javascript
   :linenos:

   $(function() {
       doStuff();
       $(".glpi_tabs").on("tabsload", function(event, ui) {
           doStuff();
       });
   });

   var doStuff = function()
   {
       if (! $("html").hasClass("stuff-added")) {
           $("html").addClass("stuff-added");

           // do stuff you need
           ...

       }
   };

.. note::

    📝 **Exercises**:

    #. Add a new icon in preferences menu to display main GLPI configuration. You can use `tabler-icons <https://tabler-icons.io/>`_:

      * ``<a href='...' class='ti ti-mood-smile'></a>``

    #. On ticket edition page, add an icon to self-associate as a requester on the model of the one present for the "assigned to" part.

Display hooks
-------------

Since GLPI 9.1.2, it is possible to display data in native objects forms via new hooks.
See :ref:`display related hooks <display_related_hooks>` in plugins documentation.

As previous `hooks`, declaration will look like:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Plugin\Hooks;
   use GlpiPlugin\Myplugin\Superasset;

   function plugin_init_myplugin()
   {
      ...

       $PLUGIN_HOOKS[Hooks::PRE_ITEM_FORM]['myplugin'] = [
           Superasset::class, 'preItemFormComputer'
       ];
   }

.. warning::

    ℹ️ **Important**
    Those display hooks are a bit different from other hooks regarding parameters that are passed to callback underlying method.
    We will obtain an array with the following keys:

       * ``item`` with current ``CommonDBTM`` object
       * ``options``, an array passed from current object ``showForm()`` method

    example of a call from core:

    .. code-block:: php

        <?php

        Plugin::doHook("pre_item_form", ['item' => $this, 'options' => &$options]);

.. note::

    📝 **Exercice**:
    Add the number of associated ``Superasset`` in the computer form header.
    It should be a link to the :ref:`previous added tab <using-core-objects>` to computers.
    This link will target the same page, but with the ``forcetab=PluginMypluginSuperasset$1`` parameter.

Adding a configuration page
---------------------------

We will add a tab in GLPI configuration so some parts of our plugin can be optional.

We previously added a tab to the form for computers using hooks in ``setup.php`` file. We will define two configuration options to enable/disable those tabs.

GLPI provides a ``glpi_configs`` table to store software configuration. It allows plugins to save their own data without defining additional tables.

First of all, let's create a new ``Config.php`` class in the ``src/`` folder with the following skeleton:

**🗋 src/Config.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use Config;
   use CommonGLPI;
   use Dropdown;
   use Html;
   use Session;
   use Glpi\Application\View\TemplateRenderer;

   class Config extends \Config
   {

       static function getTypeName($nb = 0)
       {
           return __('My plugin', 'myplugin');
       }

       static function getConfig()
       {
           return Config::getConfigurationValues('plugin:myplugin');
       }

       function getTabNameForItem(CommonGLPI $item, $withtemplate = 0)
       {
           switch ($item->getType()) {
               case Config::class:
                   return self::createTabEntry(self::getTypeName());
           }
           return '';
       }

       static function displayTabContentForItem(
           CommonGLPI $item,
           $tabnum = 1,
           $withtemplate = 0
       ) {
           switch ($item->getType()) {
               case Config::class:
                   return self::showForConfig($item, $withtemplate);
           }

           return true;
       }

       static function showForConfig(
           Config $config,
           $withtemplate = 0
       ) {
           global $CFG_GLPI;

           if (!self::canView()) {
               return false;
           }

           $current_config = self::getConfig();
           $canedit        = Session::haveRight(self::$rightname, UPDATE);

           TemplateRenderer::getInstance()->display('@myplugin/config.html.twig', [
               'current_config' => $current_config,
               'can_edit'       => $canedit
           ]);
       }
   }

Once again, we manage display from a dedicated template file:

**🗋 templates/config.html.twig**

.. code-block:: twig
   :linenos:

   {% import "components/form/fields_macros.html.twig" as fields %}

   {% if can_edit %}
       <form name="form" action="{{ "Config"|itemtype_form_path }}" method="POST">
           <input type="hidden" name="config_class" value="GlpiPlugin\\Myplugin\\Config">
           <input type="hidden" name="config_context" value="plugin:myplugin">
           <input type="hidden" name="_glpi_csrf_token" value="{{ csrf_token() }}">

           {{ fields.dropdownYesNo(
               'myplugin_computer_tab',
               current_config['myplugin_computer_tab'],
               __("Display tab in computer", 'myplugin')
           ) }}

           {{ fields.dropdownYesNo(
               'myplugin_computer_form',
               current_config['myplugin_computer_form'],
               __("Display information in computer form", 'myplugin')
           ) }}

           <button type="submit" class="btn btn-primary mx-1" name="update" value="1">
               <i class="ti ti-device-floppy"></i>
               <span>{{ _x('button', 'Save') }}</span>
           </button>
       </form>
   {% endif %}

This skeleton retrieves the calls to a tab in the ``Setup > General`` menu to display the dedicated form.
It is useless to add a ``front`` file because the GLPI ``Config`` object already offers a form display.

Note that we display, from the ``myplugin_computer_form`` two yes/no fields named ``myplugin_computer_tab`` and ``myplugin_computer_form``.

.. note::

    ✍️ Complete ``setup.php`` file by defining the new tab in the ``Config`` class.

    You also have to add those new configuration entries management to install/uninstall methods.
    You can use the following:

    .. code-block:: php

        <?php

        use Config;

        Config::setConfigurationValues('##context##', [
            '##config_name##' => '##config_default_value##'
        ]);

    .. code-block:: php

        <?php

        use Config;

        $config = new Config();
        $config->deleteByCriteria(['context' => '##context##']);

    Do not forget to replace ``##`` surrounded terms with your own values!


Managing rights
---------------

To limit access to our plugin features to some of our users, we can use the GLPI `Profile`_ class.

This will check ``$rightname`` property of class that inherits `CommonDBTM`_ for all standard events.
Those check are done by static ``can*`` functions:


* `canCreate <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonGLPI.php#L169-L175>`_ for `add <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1230-L1240>`_
* `canUpdate <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonGLPI.php#L202-L210>`_ for `update <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1561-L1570>`_
* `canDelete <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonGLPI.php#L219-L226>`_ for `delete <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2027-L2036>`_
* `canPurge <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonGLPI.php#L235-L242>`_ for `delete <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2027-L2036>`_ when ``$force`` parameter is set to ``true``

In order to customize rights, we will redefine those static methods in our classes.

If we need to check a right manually in our code, the `Session`_ class provides some methods:

.. code-block:: php
   :linenos:

   <?php

   use Session;

   if (Session::haveRight(self::$rightname, CREATE)) {
      // OK
   }

   // we can also test a set multiple rights with AND operator
   if (Session::haveRightsAnd(self::$rightname, [CREATE, READ])) {
      // OK
   }

   // also with OR operator
   if (Session::haveRightsOr(self::$rightname, [CREATE, READ])) {
      // OK
   }

   // check a specific right (not your class one)
   if (Session::haveRight('ticket', CREATE)) {
      // OK
   }

Above methods return a boolean. If we need to stop the page with a message to the user, we can use equivalent methods with ``check`` instead of ``have`` prefix:

* `checkRight <https://github.com/glpi-project/glpi/blob/10.0.15/src/Session.php#L1109-L1117>`_
* `checkRightsOr <https://github.com/glpi-project/glpi/blob/10.0.15/src/Session.php#L1128-L1136>`_

.. warning::

    ℹ️ If you need to check a right in an SQL query, use bitwise operators ``&`` and ``|``:

    .. code-block:: php

        <?php

        $iterator = $DB->request([
            'SELECT' => 'glpi_profiles_users.users_id',
            'FROM' => 'glpi_profiles_users',
            'INNER JOIN' => [
                'glpi_profiles' => [
                    'ON' => [
                        'glpi_profiles_users' => 'profiles_id'
                         'glpi_profiles' => 'id'
                    ]
                ],
                'glpi_profilerights' => [
                    'ON' => [
                        'glpi_profilerights' => 'profiles_id',
                         'glpi_profiles' => 'id'
                    ]
                ]
            ],
            'WHERE' => [
                'glpi_profilerights.name' => 'ticket',
                'glpi_profilerights.rights' => ['&', (READ | CREATE)];
            ]
        ]);

    In this code example, the ``READ | CREATE`` make a bit sum, and the ``&`` operator compare the value at logical level with the table.

Possible values for standard rights can be found in the ``inc/define.php`` file of GLPI:

.. code-block:: php
   :linenos:

   <?php

   ...

   define("READ", 1);
   define("UPDATE", 2);
   define("CREATE", 4);
   define("DELETE", 8);
   define("PURGE", 16);
   define("ALLSTANDARDRIGHT", 31);
   define("READNOTE", 32);
   define("UPDATENOTE", 64);
   define("UNLOCK", 128);

Add a new right
^^^^^^^^^^^^^^^

.. note::

    ✍️ We :ref:`previously defined a property <commondntm_usage>` ``$rightname = 'computer'`` on which we've automatically rights as ``super-admin``.
    We will now create a specific right for the plugin.

First of all, let's create a new class dedicated to profiles management:

**🗋 src/Profile.php**

.. code-block:: php
   :linenos:

   <?php
   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use CommonGLPI;
   use Html;
   use Profile as Glpi_Profile;

   class Profile extends CommonDBTM
   {
       public static $rightname = 'profile';

       static function getTypeName($nb = 0)
       {
           return __("My plugin", 'myplugin');
       }

       public function getTabNameForItem(CommonGLPI $item, $withtemplate = 0)
       {
           if (
               $item instanceof Glpi_Profile
               && $item->getField('id')
           ) {
               return self::createTabEntry(self::getTypeName());
           }
           return '';
       }

       static function displayTabContentForItem(
           CommonGLPI $item,
           $tabnum = 1,
           $withtemplate = 0
       ) {
           if (
               $item instanceof Glpi_Profile
               && $item->getField('id')
           ) {
               return self::showForProfile($item->getID());
           }

           return true;
       }

       static function getAllRights($all = false)
       {
           $rights = [
               [
                   'itemtype' => Superasset::class,
                   'label'    => Superasset::getTypeName(),
                   'field'    => 'myplugin::superasset'
               ]
           ];

           return $rights;
       }


       static function showForProfile($profiles_id = 0)
       {
           $profile = new Glpi_Profile();
           $profile->getFromDB($profiles_id);

           TemplateRenderer::getInstance()->display('@myplugin/profile.html.twig', [
               'can_edit' => self::canUpdate(),
               'profile'  => $profile
               'rights'   => self::getAllRights()
           ]);
       }
   }

Once again, display will be done from a Twig template:

**🗋 templates/profile.html.twig**

.. code-block:: twig
   :linenos:

   {% import "components/form/fields_macros.html.twig" as fields %}
   <div class='firstbloc'>
       <form name="form" action="{{ "Profile"|itemtype_form_path }}" method="POST">
           <input type="hidden" name="id" value="{{ profile.fields['id'] }}">
           <input type="hidden" name="_glpi_csrf_token" value="{{ csrf_token() }}">

           {% if can_edit %}
               <button type="submit" class="btn btn-primary mx-1" name="update" value="1">
                   <i class="ti ti-device-floppy"></i>
                   <span>{{ _x('button', 'Save') }}</span>
               </button>
           {% endif %}
       </form>
   </div>

We declare a new tab on ``Profile`` object from our ``init`` function:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Plugin;
   use Profile;
   use GlpiPlugin\Myplugin\Profile as MyPlugin_Profile;

   function plugin_init_myplugin()
   {
      ...

       Plugin::registerClass(MyPlugin_Profile::class, [
           'addtabon' => Profile::class
       ]);
   }

And we tell installer to setup a minimal right for current profile (``super-admin``):

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Profile as MyPlugin_Profile;
   use ProfileRight;

   function plugin_myplugin_install() {
      ...

      // add rights to current profile
      foreach (MyPlugin_Profile::getAllRights() as $right) {
         ProfileRight::addProfileRights([$right['field']]);
      }

      return true;
   }

   function plugin_myplugin_uninstall() {
      ...

      // delete rights for current profile
      foreach (MyPlugin_Profile::getAllRights() as $right) {
         ProfileRight::deleteProfileRights([$right['field']]);
      }

   }

Then, wa can define rights from ``Administration > Profiles`` menu and can change the ``$rightname`` property of our class to ``myplugin::superasset``.

Extending standard rights
^^^^^^^^^^^^^^^^^^^^^^^^^

If we need specific rights for our plugin, for example the right to perform associations, we must override the ``getRights`` function in the class defining the rights.

In defined above example of the ``PluginMypluginProfile`` class, we added a ``getAllRights`` method which indicates that the right ``myplugin::superasset`` is defined in the ``PluginMypluginSuperasset`` class.
This one inherits from ``CommonDBTM`` and has a ``getRights`` method that we can override:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   ...

   class Superasset extends CommonDBTM
   {
       const RIGHT_ONE = 128;

       ...

       function getRights($interface = 'central')
       {
           // if we need to keep standard rights
           $rights = parent::getRights();

           // define an additional right
           $rights[self::RIGHT_ONE] = __("My specific rights", "myplugin");

           return $rights;
       }
   }


Massive actions
---------------

GLPI massive actions allow applying modifications to a selection.

.. image:: ../devapi/images/massiveactions.png
   :alt: massive actions control

By default, GLPI proposes following actions:

* `Edit`: to edit fields that are defined in search options (excepted those where ``massiveaction`` is set to ``false``)
* `Put in trashbin`/`Delete`

It is possible to declare :ref:`extra massive actions <massiveactions_specific>`.

To achieve that in your plugin, you must declare a hook in the ``init`` function:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   function plugin_init_myplugin()
   {
       ...

       $PLUGIN_HOOKS['use_massive_action']['myplugin'] = true;
   }

Then, in the ``Superasset`` class, you must add 3 methods:

* ``getSpecificMassiveActions``: massive actions declaration.
* ``showMassiveActionsSubForm``: sub-form display.
* ``processMassiveActionsForOneItemtype``: handle form submit.

Here is a minimal implementation example:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Html;
   use MassiveAction;

   class Superasset extends CommonDBTM
   {
       ...

       function getSpecificMassiveActions($checkitem = NULL)
       {
           $actions = parent::getSpecificMassiveActions($checkitem);

           // add a single massive action
           $class        = __CLASS__;
           $action_key   = "myaction_key";
           $action_label = "My new massive action";
           $actions[$class . MassiveAction::CLASS_ACTION_SEPARATOR . $action_key] = $action_label;

           return $actions;
       }

       static function showMassiveActionsSubForm(MassiveAction $ma)
       {
           switch ($ma->getAction()) {
               case 'myaction_key':
                   echo __("fill the input");
                   echo Html::input('myinput');
                   echo Html::submit(__('Do it'), ['name' => 'massiveaction']) . "</span>";

                   break;
           }

           return parent::showMassiveActionsSubForm($ma);
       }

       static function processMassiveActionsForOneItemtype(
           MassiveAction $ma,
           CommonDBTM $item,
           array $ids
       ) {
           switch ($ma->getAction()) {
               case 'myaction_key':
                   $input = $ma->getInput();

                   foreach ($ids as $id) {

                       if (
                           $item->getFromDB($id)
                           && $item->doIt($input)
                       ) {
                           $ma->itemDone($item->getType(), $id, MassiveAction::ACTION_OK);
                       } else {
                           $ma->itemDone($item->getType(), $id, MassiveAction::ACTION_KO);
                           $ma->addMessage(__("Something went wrong"));
                       }
                   }
                   return;
           }

           parent::processMassiveActionsForOneItemtype($ma, $item, $ids);
       }
   }

.. note::

    📝 **Exercise**:
    With the help of the official documentation on :doc:`massive actions <../devapi/massiveactions>`, complete in your plugin the above methods to allow the linking with a computer from "Super assets" massive actions.

    You can display a list of computers with:

    .. code-block:: php

        Computer::dropdown();

It is also possible to add massive actions to GLPI native objects.
To achieve that, you must declare a ``_MassiveActions`` function in the ``hook.php`` file:

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use Computer;
   use MassiveAction;
   use GlpiPlugin\Myplugin\Superasset;

   ...

   function plugin_myplugin_MassiveActions($type)
   {
      $actions = [];
      switch ($type) {
         case Computer::class:
            $class = Superasset::class;
            $key   = 'DoIt';
            $label = __("plugin_example_DoIt", 'example');
            $actions[$class.MassiveAction::CLASS_ACTION_SEPARATOR.$key]
               = $label;

            break;
      }
      return $actions;
   }

Sub form display and processing are done the same way as you did for your plugin itemtypes.

.. note::

    📝 **Exercise**:
    As the previous exercise, add a massive action to link a computer to a "Super asset" from the computer list.

    Do not forget to use unique keys and labels.

Notifications
-------------

.. warning::
    ⚠️ Access to an SMTP server is recommended; it must be properly configured in ``Setup > Notifications`` menu.
    On a development environment, you can install `mailhog <https://github.com/mailhog/MailHog>`_ or `mailcatcher <https://mailcatcher.me/>`_ which expose a local SMTP server and allow you to get emails sent by GLPI in a graphical interface.

    Please also note that GLPI queues all notifications rather than sending them directly. The only exception to this is the test email notification.
    All "pending" notifications are visible in the ``Administration > Notification queue`` menu.
    You can send notifications immediately from this menu or by forcing the ``queuednotification`` automatic action.

The GLPI notification system allows sending alerts to the actors of a recorded event.
By default, notifications can be sent by email or as browser notifications, but other channels may be available from plugins (or you can add your own one).

That system is divided in several classes:

* ``Notification``: the triggering item. It receives common data like name, if it is active, sending mode, event, content (``NotificationTemplate``), etc.

   .. image:: /_static/images/Notification.png
      :alt: Add notification form

* ``NotificationTarget``: defines notification recipients.
    It is possible to define recipients based on the triggering item (author, assignee) or static recipients (a specific user, all users of a specific group, etc).

   .. image:: /_static/images/NotificationTarget.png
      :alt: Choose actor form

* ``NotificationTemplate``: notification templates are used to build the content, which can be chosen from Notification form. CSS can be defined in the templates and it receives one or more ``NotificationTemplateTranslation`` instances.

   .. image:: /_static/images/NotificationTemplate.png
      :alt: Notification template form

* ``NotificationTemplateTranslation``: defines the translated template content. If no language is specified, it will be the default translation. If no template translation exists for a user's language, the default translation will be used.

    The content is dynamically generated with tags provided to the user and completed by HTML.

   .. image:: /_static/images/NotificationTemplateTranslation.png
      :alt: Template translation form

All of these notification-related object are natively managed by GLPI core and does not require any development intervention from us.

We can however trigger a notification execution via the following code:

.. code-block:: php

   <?php

   use NotificationEvent;

   NotificationEvent::raiseEvent($event, $item);

The ``event`` key corresponds to the triggering event name defined in the ``Notification`` object and the ``item`` key to the triggering item.
Therefore, the ``raiseEvent`` method will search the ``glpi_notifications`` table for an active line with these 2 characteristics.

To use this trigger in our plugin, we will add a new class ``PluginMypluginNotificationTargetSuperasset``.
This ones targets our ``Superasset`` object. It is the standard way to develop notifications in GLPI. We have an itemtype with its own life and a notification object related to it.

**🗋 src/NotificationTargetSuperasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use NotificationTarget;

   class NotificationTargetSuperasset extends NotificationTarget
   {

       function getEvents()
       {
           return [
               'my_event_key' => __('My event label', 'myplugin')
           ];
       }

       function getDatasForTemplate($event, $options = [])
       {
           $this->datas['##myplugin.name##'] = __('Name');
       }
   }

We have to declare our ``Superasset`` object can send notifications in our ``init`` function:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Plugin;
   use GlpiPlugin\Myplugin\Superasset;

   function plugin_init_myplugin()
   {
      ...

       Plugin::registerClass(Superasset::class, [
           'notificationtemplates_types' => true
       ]);
   }

With this minimal code it's possible to create using the GLPI UI, a new notification targeting our ``Superasset`` itemtype and with the 'My event label' event and then use the ``raiseEvent`` method with these parameters.

.. note::

    📝 **Exercise**:
    Along with an effective sending test, you will manage installation and uninstallation of notification and related objects (templates, translations).

    You can see an example (still incomplete) on :doc:`notifications in plugins documentation <notifications>`.

Automatic actions
-----------------

This GLPI feature provides a task scheduler executed silently from user usage (GLPI mode) or by the server in command line (CLI mode) via a call to the ``front/cron.php`` file of GLPI.

.. image:: /_static/images/crontask.png
   :alt:

To add one or more automatic actions to our class, we will add those methods:

* ``cronInfo``: possible actions for the class, and associated labels
* ``cron*Action*``: a method for each action defined in ``cronInfo``. Those are called to manage each action.

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;

   class Superasset extends CommonDBTM
   {
       ...

       static function cronInfo($name)
       {

           switch ($name) {
               case 'myaction':
                   return ['description' => __('action desc', 'myplugin')];
           }
           return [];
       }

       static function cronMyaction($task = NULL)
       {
           // do the action

           return true;
       }
   }

To tell GLPI that the automatic action exists, you just have to register it:

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use CronTask;

   function plugin_myplugin_install()
   {

       ...

       CronTask::register(
           PluginMypluginSuperasset::class,
           'myaction',
           HOUR_TIMESTAMP,
           [
               'comment'   => '',
               'mode'      => \CronTask::MODE_EXTERNAL
           ]
       );
   }

No need to manage uninstallation (`unregister`) as GLPI will handle that itself when the plugin is uninstalled.

.. _plugin_publication:

Publishing your plugin
----------------------

Catalog
^^^^^^^

When you consider your plugin is ready and covers a real need, you can submit it to the community.

The `plugins catalog <http://plugins.glpi-project.org/>`_ allows GLPI users to discover, download and follow plugins provided by the community as well as first-party plugins provided by Teclib'.

Just publish your code to an publicly accessible GIT repository (`github <https://github.com/>`_, `gitlab <https://gitlab.com>`_, ...) with an `open source license <https://choosealicense.com/>`_ of your choice and prepare an XML description file of your plugin.
The XML file must follow this structure:

.. code-block:: xml
   :linenos:

   <root>
      <name>Displayed name</name>
      <key>System name</key>
      <state>stable</state>
      <logo>http://link/to/logo/with/dimensions/40px/40px</logo>
      <description>
         <short>
            <en>short description of the plugin, displayed on list, text only</en>
            <lang>...</lang>
         </short>
         <long>
            <en>short description of the plugin, displayed on detail, Markdown accepted</en>
            <lang>...</lang>
         </long>
      </description>
      <homepage>http://link/to/your/page</homepage>
      <download>http://link/to/your/files</download>
      <issues>http://link/to/your/issues</issues>
      <readme>http://link/to/your/readme</readme>
      <authors>
         <author>Your name</author>
      </authors>
      <versions>
         <version>
            <num>1.0</num>
            <compatibility>10.0</compatibility>
            <download_url>http://link/to/your/download/glpi-myplugin-1.0.tar.bz2</download_url>
         </version>
      </versions>
      <langs>
         <lang>en_GB</lang>
         <lang>...</lang>
      </langs>
      <license>GPL v2+</license>
      <tags>
         <en>
            <tag>tag1</tag>
         </en>
         <lang>
            <tag>tag1</tag>
         </lang>
      </tags>
      <screenshots>
         <screenshot>http://link/to/your/screenshot</screenshot>
         <screenshot>http://link/to/your/screenshot</screenshot>
         <screenshot>...</screenshot>
      </screenshots>
   </root>

To market this plugin to a wide range of users, you should add a detailed description in several languages and provide screenshots that represent your plugin.

Finally, submit your XML file on the `dedicated page <http://plugins.glpi-project.org/#/submit>`_ of the plugins catalog (registration is required).

.. note::

   Path to plugin XML file must display the raw XML file itself. For example, the following URL for the `exmple` plugin would be incorrect:

   ::

      https://github.com/pluginsGLPI/example/blob/main/example.xml

   The correct one (use Github UI `raw` button) would be:

   ::

      https://raw.githubusercontent.com/pluginsGLPI/example/refs/heads/main/example.xml

Teclib' will receive a notification for this submission and after some checks, will activate the publication on the catalog.


Marketplace
^^^^^^^^^^^

By following these steps and recommendations, you will be able to make your plugin available on the GLPI Marketplace, thus offering users simplified installation and updates. We would like to thank you for this contribution, which helps enrich the GLPI ecosystem for the entire community.

1. **Preparation**:

a. Your plugin archive should contain a directory with a name corresponding to the plugin's technical name. All your plugin's files should be placed in this directory.

    Example:

    for a plugin whose ``plugin_init_`` function is ``plugin_init_oauthimap`` in ``setup.php``, the technical name of its directory must be ``oauthimap``.
    The plugin's files should be located inside a directory named ``oauthimap``.

b. Make sure your XML file contains a ``<key>`` element that exactly matches this directory name (no spaces, no accents, no uppercase letters).

    Example: ``<key>oauthimap</key>``

c. In the ``<versions>`` section of your XML file, for each version of your plugin (with version number and compatibility),
   add a ``download_url`` tag containing the URL where the plugin archive can be downloaded.

Example:

  ::

      <versions>
        <version>
          <num>1.0</num>
          <compatibility>~10.0.0</compatibility>
          <download_url>https://link/to/your/plugin/file-1.0.tar.gz</download_url>
        </version>
      </versions>

1. **Public Access**:

 - Make sure the URL of the XML file and the plugin archive download URL are publicly accessible.
 - Ensure that the plugin archive is properly structured and downloadable using the URL provided in the XML file.

Technical Requirements and Recommendations
******************************************

1. **Compliance with Coding Standards**:

 - Follow the recommendations in the GLPI Developer Documentation: `GLPI Developer Documentation <https://glpi-developer-documentation.readthedocs.io/>`_
 - Ensure your code complies with GLPI coding standards and does not trigger errors from tools like phpcs.

2. **Code Security and Quality**:

 - Avoid raw SQL queries. Always use GLPI framework methods (see :doc:`Querying <../devapi/database/dbiterator>` and :doc:`Updating <..//devapi/database/dbupdate>`) — **this is mandatory starting from GLPI 11**.
 - Use Twig for templating.
 - Properly enforce permissions in all front-end (front/*) and AJAX (ajax/*) files — **this is mandatory**.
 - The plugin may be rejected if it contains backdoors or obvious security flaws.

3. **Compatibility and Updates**:

 - Make sure your plugin is compatible with a maintained version of GLPI.
 - Keep your plugin up to date to ensure continued compatibility with future GLPI versions.


Submission Process
******************

.. note:: Before continuing, your plugin must be published on the `plugins catalog <http://plugins.glpi-project.org/>`_, see above.

1. **Validation and Approval**:

 - By default, plugins accepted on the Plugins Website are not automatically available on the Marketplace. For security and relevance reasons, the GLPI team must review key technical aspects before approving Marketplace availability.
 - If your plugin is already listed on the Plugins Website and you want to distribute it on the Marketplace, please send an email to the GLPI team at glpi@teclib.com.
 - Depending on the results of the review, the team may approve the plugin for availability on the on-premise GLPI Marketplace, and/or the Cloud instance Marketplace (which has stricter security requirements).

2. **Lifecycle and Maintenance**

 - Ongoing Monitoring:

  - After approval and publication, regularly monitor your plugin’s performance and security to ensure continued compliance with GLPI requirements.

 - Plugin Deactivation:

  - The GLPI team reserves the right to deactivate the plugin from the Marketplace if, at any point, it no longer meets requirements, causes a major bug, or presents a critical security vulnerability.

Therefore, it is crucial to maintain your plugin and promptly address any reported issues.


Miscellaneous
-------------

Querying database
^^^^^^^^^^^^^^^^^

Rely on :doc:`DBmysqlIterator <../devapi/database/dbiterator>`. It provides an exhaustive ``query builder``.

.. code-block:: php
   :linenos:

   <?php


   // => SELECT * FROM `glpi_computers`
   $iterator = $DB->request(['FROM' => 'glpi_computers']);
   foreach ($ierator as $row) {
       //... work on each row ...
   }

   $DB->request([
       'FROM' => ['glpi_computers', 'glpi_computerdisks'],
       'LEFT JOIN' => [
           'glpi_computerdisks' => [
               'ON' => [
                   'glpi_computers' => 'id',
                   'glpi_computerdisks' => 'computer_id'
               ]
           ]
       ]
   ]);

Dashboards
^^^^^^^^^^

Since GLPI 9.5, dashboards are available from:

* Central page
* Assets menu
* Assistance menu
* Ticket search results (mini dashboard)

This feature is split into several concepts - sub classes:

* a placement grid (``Glpi\Dashboard\Grid``)
* a widget collection (``Glpi\Dashboard\Widget``) to graphically display data
* a data provider collection (``Glpi\Dashboard\Provider``) that queries the database
* rights (``Glpi\Dashboard\Right``) on each dashboard
* filters (``Glpi\Dashboard\Filter``) that can be displayed in a dashboard header and impacting providers.

With these classes, we can build a dashboard that will display cards on its grid.
A card is a combination of a widget, a data provider, a place on grid and various options (like a background colour for example).

Completing existing concepts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

From your plugin, you can complete these concepts with your own data and code.

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Plugin\Hooks;
   use GlpiPlugin\Myplugin\Dashboard;

   function plugin_init_myplugin()
   {
       ...

       // add new widgets to the dashboard
       $PLUGIN_HOOKS[Hooks::DASHBOARD_TYPES]['myplugin'] = [
           Dashboard::class => 'getTypes',
       ];

       // add new cards to the dashboard
       $PLUGIN_HOOKS[Hooks::DASHBOARD_CARDS]['myplugin'] = [
           Dashboard::class => 'getCards',
       ];
   }

We will create a dedicated class for our dashboards:

**🗋 src/Dashboard.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   class Dashboard
   {
       static function getTypes()
       {
           return [
               'example' => [
                   'label'    => __("Plugin Example", 'myplugin'),
                   'function' => __class__ . "::cardWidget",
                   'image'    => "https://via.placeholder.com/100x86?text=example",
               ],
               'example_static' => [
                   'label'    => __("Plugin Example (static)", 'myplugin'),
                   'function' => __class__ . "::cardWidgetWithoutProvider",
                   'image'    => "https://via.placeholder.com/100x86?text=example+static",
               ],
           ];
       }

       static function getCards($cards = [])
       {
           if (is_null($cards)) {
               $cards = [];
           }
           $new_cards =  [
               'plugin_example_card' => [
                   'widgettype'   => ["example"],
                   'label'        => __("Plugin Example card"),
                   'provider'     => "PluginExampleExample::cardDataProvider",
               ],
               'plugin_example_card_without_provider' => [
                   'widgettype'   => ["example_static"],
                   'label'        => __("Plugin Example card without provider"),
               ],
               'plugin_example_card_with_core_widget' => [
                   'widgettype'   => ["bigNumber"],
                   'label'        => __("Plugin Example card with core provider"),
                   'provider'     => "PluginExampleExample::cardBigNumberProvider",
               ],
           ];

           return array_merge($cards, $new_cards);
      }

       static function cardWidget(array $params = [])
       {
           $default = [
               'data'  => [],
               'title' => '',
               // this property is "pretty" mandatory,
               // as it contains the colors selected when adding widget on the grid send
               // without it, your card will be transparent
               'color' => '',
           ];
           $p = array_merge($default, $params);

           // you need to encapsulate your html in div.card to benefit core style
           $html = "<div class='card' style='background-color: {$p["color"]};'>";
           $html.= "<h2>{$p['title']}</h2>";
           $html.= "<ul>";
           foreach ($p['data'] as $line) {
               $html.= "<li>$line</li>";
           }
           $html.= "</ul>";
           $html.= "</div>";

           return $html;
       }

       static function cardWidgetWithoutProvider(array $params = [])
       {
         $default = [
            // this property is "pretty" mandatory,
            // as it contains the colors selected when adding widget on the grid send
            // without it, your card will be transparent
            'color' => '',
         ];
         $p = array_merge($default, $params);

         // you need to encapsulate your html in div.card to benefit core style
         $html = "<div class='card' style='background-color: {$p["color"]};'>
                     static html (+optional javascript) as card is not matched with a data provider
                     <img src='https://www.linux.org/images/logo.png'>
                  </div>";

         return $html;
      }

       static function cardBigNumberProvider(array $params = [])
       {
           $default_params = [
               'label' => null,
               'icon'  => null,
           ];
           $params = array_merge($default_params, $params);

           return [
               'number' => rand(),
               'url'    => "https://www.linux.org/",
               'label'  => "plugin example - some text",
               'icon'   => "fab fa-linux", // font awesome icon
           ];
      }
   }

A few explanations on those methods:

* ``getTypes()``: define available widgets for cards and methods to call for display.
* ``getCards()``: define available cards for dashboards (when added to the grid). As previously explained, each is defined from a label, widget and optional data provider (from core or your plugin) combination
* ``cardWidget()``: use provided parameters to display HTML. You are free to delegate display to a Twig template, and use your favourite JavaScript library.
* ``cardWidgetWithoutProvider()``: almost the same as the ``cardWidget()``, but does not use parameters and just returns a static HTML.
* ``cardBigNumberProvider()``: provider and expected return example when grid will display card.

Display your own dashboard
~~~~~~~~~~~~~~~~~~~~~~~~~~

GLPI dashboards system is modular and you can use it in your own displays.

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Dashboard\Grid;

   $dashboard = new Grid('myplugin_example_dashboard', 10, 10, 'myplugin');
   $dashboard->show();

By adding a context (``myplugin``), you can filter dashboards available in the dropdown list at the top right of the grid. You will not see GLPI core ones (central, assistance, etc.).

Translating your plugins
^^^^^^^^^^^^^^^^^^^^^^^^

In many places in current document, code exmaples takes care of using `gettext`_ GLPI notations to display strings to users.
Even if your plugin will be private, it is a good practice to keep this `gettext`_ usage.

See :doc:`developper guide translation documentation <../devapi/translations>` for more explanations and list of PHP functions that can be used.

* On your local instance, you can use software like `poedit <https://poedit.net>`_ to manage your translations.
* You can also rely on online services like `Transifex <https://www.transifex.com>`_ or `Weblate <https://weblate.org>`_ (both are free for open source projects).

If you have used the `Empty`_ plugin skeleton, you will benefit from command line tools to manage your locales:

.. code-block:: shell

   # extract strings to translate from your source code
   # and put them in the locales/myplugin.pot file
   vendor/bin/extract-locales

.. warning::

    ℹ️  It is possible your translations are not updated after compiling MO files, a restart of your PHP (or web server, depending on your configuration) may be required.

REST API
--------

Since GLPI (since 9.1 release) has an external API in REST format. An XMLRPC format is also still available, but is deprecated.

.. image:: /_static/images/API.png
   :alt: API configuration

Configuration
^^^^^^^^^^^^^

For security reasons, API is disabled bu default.
From the ``Setup > General, API tab`` menu, you can enable it.

It's available from your instance at:

* ``http://path/to/glpi/apirest.php``
* ``http://path/to/glpi/apixmlrpc.php``

The first link includes an integrated documentation when you access it from a simple browser (a link is provided as soon as the API is active).

For the rest of the configuration:

* login allows to use ``login`` / ``password`` as well as web interface
* token connection use the token displayed in user preferences

  .. image:: /_static/images/api_external_token.png
     :alt: external token

* API clients allow to limit API access from some IP addresses and log if necessary. A client allowing access from any IP is provided by default.

----

You can use the `API usage bootstrap <https://github.com/orthagh/glpi_boostrap_api>`_.
This one is written in PHP and relies on `Guzzle <http://docs.guzzlephp.org/>`_ library to handle HTTP requests.

By default, it does a connection with login details defined in the ``config.inc.php`` file (that you must create by copying the ``config.inc.example`` file).

.. warning::

    ⚠️ Make sure the script is working as expected before continuing.

API usage
^^^^^^^^^

To learn this part, with the help of integrated documentation (or `latest stable GLPI API documentation on github <https://github.com/glpi-project/glpi/blob/master/apirest.md>`_), we will do several exercises:

.. note::

   📝 **Exercise**: Test a new connection using GLPI user external token

.. note::

   📝 **Exercise**: Close the session at the end of your script.

.. note::

   📝 **Exercise**: Simulate computer life cycle:

    * add a computer and some volumes (``Item_Disk``),
    * edit several fields,
    * add commercial and administrative information (``Infocom``),
    * display its detail in a PHP page,
    * put it in the trashbin,
    * and then remove it completely.

.. note::

   📝 **Exercise**: Retrieve computers list and display them an HTML array. The `endpoint` to use us "Search items".
   If you want to display columns labels, you will have to use the "List searchOptions" `endpoint`.

----

.. _Empty:  https://github.com/pluginsGLPI/empty
.. _Composer: https://getcomposer.org/download/
.. _Npm: https://www.npmjs.com/
.. _CommonDBTM: https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php
.. _Computer: https://github.com/glpi-project/glpi/blob/10.0.15/src/Computer.php
.. _Html: https://github.com/glpi-project/glpi/blob/10.0.15/src/Html.php
.. _Migration: https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php
.. _Notepad: https://github.com/glpi-project/glpi/blob/10.0.15/src/Notepad.php
.. _Log: https://github.com/glpi-project/glpi/blob/10.0.15/src/Log.php
.. _Profile: https://github.com/glpi-project/glpi/blob/10.0.15/src/Profile.php
.. _Session: https://github.com/glpi-project/glpi/blob/10.0.15/src/Session.php
.. _gettext: https://www.gnu.org/software/gettext/
.. _Metabase: http://www.metabase.com/
.. _informatique décisionnelle: https://fr.wikipedia.org/wiki/Informatique_d%C3%A9cisionnelle
