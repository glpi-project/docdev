Hooks
-----

GLPI provides a certain amount of "hooks". Their goal is for plugins (mainly) to work on certain places of the framework; like when an item has been added, updated, deleted, ...

This page describes current existing hooks; but not the way they must be implemented from plugins. Please refer to the plugins development documentation.

Standards Hooks
^^^^^^^^^^^^^^^

Usage
+++++

Aside from their goals or when/where they're called; you will see three types of different hooks. Some will receive an item as parameter, others an array of parameters, and some won't receive anything. Basically, the way they're declared into your plugin, and the way you'll handle that will differ.

All hooks called are defined in the ``setup.php`` file of your plugin; into the ``$PLUGIN_HOOKS`` array. The first key is the hook name, the second your plugin name; values can be just text (to call a function declared in the ``hook.php`` file), or an array (to call a static method from an object):

.. code-block:: php

   <?php
   //call a function
   $PLUGIN_HOOKS['hook_name']['plugin_name'] = 'function_name';
   //call a static method from an object
   $PLUGIN_HOOKS['other_hook']['plugin_name'] = ['ObjectName', 'methodName'];

Without parameters
~~~~~~~~~~~~~~~~~~


Those hooks are called without any parameters; you cannot attach them to any itemtype; basically they'll permit youi to display extra informations. Let's say you want to call the ``display_login`` hook, in you ``setup.php`` you'll add something like:

.. code-block:: php

   <?php
   $PLUGIN_HOOKS['display_login']['myPlugin'] = 'myplugin_display_login';

You will also have to declare the function you want to call in you ``hook.php`` file:

.. code-block:: php

   <?php
   /**
     * Display informations on login page
     *
     * @return void
     */
   public function myplugin_display_login () {
      echo "That line will appear on the login page!";
   }

The hooks that are called without parameters are: ``display_central``, ``post_init init_session``, ``change_entity``, ``change_profile```, ``display_login`` and ``add_plugin_where``.

.. _hook_item_parameter:

With item as parameter
~~~~~~~~~~~~~~~~~~~~~~

Those hooks will send you an item instance as parameter; you'll have to attach them to the itemtypes you want to apply on. Let's say you want to call the ``pre_item_update`` hook for `Computer` and `Phone` item types, in your ``setup.php`` you'll add something like:

.. code-block:: php

   <?php
   $PLUGIN_HOOKS['pre_item_update']['myPlugin'] = [
      'Computer'  => 'myplugin_updateitem_called',
      'Phone'     => 'myplugin_updateitem_called'
   ];

You will also have to declare the function you want to call in you ``hook.php`` file:

.. code-block:: php

   <?php
   /**
    * Handle update item hook
    *
    * @param CommonDBTM $item Item instance
    *
    * @return void
    */
   public function myplugin_updateitem_called (CommonDBTM $item) {
      //do everything you want!
      //remember that $item is passed by reference (it is an abject)
      //so changes you will do here will be used by the core.
      if ($item::getType() === Computer::getType()) {
         //we're working with a computer
      } elseif ($item::getType() === Phone::getType()) {
         //we're working with a phone
      }
   }

The hooks that are called with item as parameter are: ``item_empty``, ``pre_item_add``, ``post_prepareadd``, ``item_add``, ``pre_item_update``, ``item_update``, ``pre_item_purge``, ``pre_item_delete``, ``item_purge``, ``item_delete``, ``pre_item_restore``, ``item_restore``, ``autoinventory_information``, ``item_add_targets``, ``item_get_events``, ``item_action_targets``, ``item_get_datas``.

With array of parameters
~~~~~~~~~~~~~~~~~~~~~~~~

These hooks will work just as the :ref:`hooks with item as parameter <hook_item_parameter>` expect they will send you an array of parameters instead of only an item instance. The array will contain two entries: ``item`` and ``options``, the first one is the item instance, the second options that have been passed:

.. code-block:: php

   <?php
   /**
    * Function that handle a hook with array of parameters
    *
    * @param array $params Array of parameters
    *
    * @return void
    */
   public function myplugin_params_hook(array $params) {
      print_r($params);
      //Will display:
      //Array
      //(
      //   [item] => Computer Object
      //      (...)
      //
      //   [options] => Array
      //      (
      //            [_target] => /front/computer.form.php
      //            [id] => 1
      //            [withtemplate] => 
      //            [tabnum] => 1
      //            [itemtype] => Computer
      //      )
      //)
   }

The hooks that are called with an array of parameters are: ``post_item_form``, ``pre_item_form``, ``pre_show_item``, ``post_show_item``, ``pre_show_tab``, ``post_show_tab``, ``item_transfer``.

Some hooks will receive a specific array as parameter, they will be detailled below.

Unclassified
++++++++++++

Hooks that cannot be classified in above categories :)

``add_javascript``
   Add javascript in **all** pages headers

   .. versionadded:: 9.2

      Minified javascript files are checked automatically. You will just have to provide a minified file along with the original to get it used!

      The name of the minified ``plugin.js`` file must be ``plugin.min.js``


``add_css``
   Add CSS stylesheet on **all** pages headers

   .. versionadded:: 9.2

      Minified CSS files are checked automatically. You will just have to provide a minified file along with the original to get it used!

      The name of the minified ``plugin.css`` file must be ``plugin.min.css``

``display_central``
   Displays something on central page

``display_login``
   Displays something on the login page

``status``
   Displays status

``post_init``
   After the framework initialization

``rule_matched``
   After a rule has matched.

   This hook will receive a specific array that looks like:

   .. code-block:: php

      <?php
      $hook_params = [
         'sub_type'  => 'an item type',
         'rule_id'   => 'tule id',
         'input'     => array(), //original input
         'output'    => array()  //output modified by rule
      ];

``init_session``
   At session initialization

``change_entity``
   When entity is changed

``change_profile``
   When profile is changed

Items business related
++++++++++++++++++++++

Hooks that can do some busines stuff on items.

``item_empty``
   When a new (empty) item has been created. Allow to change / add fields.

``post_prepareadd``
   Before an item has been added, after ``prepareInputForAdd()`` has been run, so after rule engine has ben run, allow to edit ``input`` property, setting it to false will stop the process.

``pre_item_add``
   Before an item has been added, allow to edit ``input`` property, setting it to false will stop the process.

``item_add``
   After adding an item, ``fields`` property can be used.

``pre_item_update``
   Before an item is updated, allow to edit ``input`` property, setting it to false will stop the process.

``item_update``
   While updating an item, ``fields`` and ``updates`` properties can be used.

``pre_item_purge``
   Before an item is purged, allow to edit ``input`` property, setting it to false will stop the process.

``item_purge``
   After an item is purged (not pushed to trash, see ``item_delete``). The ``fields`` property still available.

``pre_item_restore``
   Before an item is restored from trash.

``item_restore``
   After an item is restored from trash.

``pre_item_delete``
   Before an item is deleted (moved to trash), allow to edit ``input`` property, setting it to false will stop the process.

``item_delete``
   After an item is moved to tash.

``autoinventory_information``
   After an automated inventory has occured

``item_transfer``
   When an item is transfered from an entity to another

``item_can``
   .. versionadded:: 9.2

   Allow to restrict user rights (can't grant more right).
   If ``right`` property is set (called during CommonDBTM::can) changing it allow to
   deny evaluated access. Else (called from Search::addDefaultWhere) ``add_where``
   property can be set to filter search results.

``add_plugin_where``
   .. versionadded:: 9.2

   Permit to filter search results.

Items display related
+++++++++++++++++++++

Hooks that permits to add display on items.


``pre_item_form``
   .. versionadded:: 9.1.2

   Before an item is displayed; just after the form header if any; or at the beginnning of the form. Waits for a ``<tr>``.


``post_item_form``
   .. versionadded:: 9.1.2

   After an item form has been displayed; just before the dates or the save buttons. Waits for a ``<tr>``.

``pre_show_item``
   Before an item is displayed

``post_show_item``
   After an item has been displayed

``pre_show_tab``
   Before a tab is displayed

``post_show_tab``
   After a tab has been displayed

``show_item_stats``
   .. versionadded:: 9.2.1

   Add display from statistics tab of a item like ticket

Notifications
+++++++++++++
Hooks that are called from notifications

``item_add_targets``
   When a target has been added to an item

``item_get_events``
   After notifications events have been retrieved

``item_action_targets``
   After target addresses have been retrieved

``item_get_datas``
   After data for template have been retrieved

Functions hooks
^^^^^^^^^^^^^^^

Usage
+++++

Functions hooks declarations are the same than standards hooks one. The main difference is that the hook will wait as output what have been passed as argument.

.. code-block:: php

   <?php
   /**
    * Handle hook function
    *
    * @param array $$data Array of something (assuming that's what wer're receiving!)
    *
    * @return array
    */
   public function myplugin_updateitem_called ($data) {
      //do everything you want
      //return passed argument
      return $data;
   }


Existing hooks
++++++++++++++

``unlock_fields``
   After a fields has been unlocked. Will receive the ``$_POST`` array used for the call.

``restrict_ldap_auth``
   Aditional LDAP restrictions at connection. Must return a boolean. The ``dn`` string is passed as parameter.

``undiscloseConfigValue``
   Permit plugin to hide fields that should not appear from the API (like configuration fields, etc). Will receive the requested fields list.

``infocom``
   Additional infocom informations oin an item. Will receive an item instance as parameter, is expected to return a table line (``<tr>``).

``retrieve_more_field_from_ldap``
   Retrieve aditional fields from LDAP for a user. Will receive the current fields lists, is expected to return a fields list.

``retrieve_more_data_from_ldap``
   Retrieve aditional data from LDAP for a user. Will receive current fields list, is expected to return a fields list.

``display_locked_fields``
   To manage fields locks. Will receive an array with ``item`` and ``header`` entries. Is expected to output a table line (``<tr>``).

``migratetypes``
   Item types to migrate, will receive an array of types to be updated; must return an aray of item types to migrate.

Automatic hooks
^^^^^^^^^^^^^^^

Some hooks are automated; they'll be called if the relevant function exists in you plugin's ``hook.php`` file. Required function must be of the form ``plugin_{plugin_name}_{hook_name}``.

``MassiveActionsFieldsDisplay``
   Add massive actions. Will receive an array with ``item`` (the item type) and ``options`` (the search options) as input. These hook have to output its content, and to return true if there is some specific output, false otherwise.

``dynamicReport``
   Add parameters for print. Will receive the ``$_GET`` array used for query. Is expected to return an array of parameters to add.

``AssignToTicket``
   Declare types an ITIL object can be assigned to. Will receive an empty array adn is expected to return a list an array of type of the form:

   .. code-block:: php

      <?php
      return [
         'TypeClass' => 'label'
      ];

``MassiveActions``
   If plugin is parameted to provide massive actions (via ``$PLUGIN_HOOKS['use_massive_actions']``), will pass the item type as parameter, and expect an array of aditional massives actions of the form:

   .. code-block:: php

      <?php
      return [
         'Class::method' => 'label'
      ];

``getDropDown``
   To declare extra dropdowns. Will not receive any parameter, and is expected to return an array of the form:

   .. code-block:: php

      <?php
      return [
         'Class::method' => 'label'
      ];

``rulePrepareInputDataForProcess``
    Provide data to process rules. Will receive an array with ``item`` (data used to check criteria) and ``params`` (the parameters) keys. Is expected to retrun an array of rules.

``executeActions``
   Actions to execute for rule. Will receive an array with ``output``, ``params`` ans ``action`` keys. Is expected to return an array of actions to execute.

``preProcessRulePreviewResults``

   .. todo::

      Write documentation for this hook.

``use_rules``

   .. todo::

      Write documentation for this hook. It lloks at bit particular.

``ruleCollectionPrepareInputDataForProcess``
   Prepare input data for rules collections. Will receive an array of the form:

   .. code-block:: php

      <?php
      array(
         'rule_itemtype'   => 'name fo the rule itemtype',
         'values'          => array(
            'input'  => 'input array',
            'params' => 'array of parameters'
         )
      );

   Is expected to return an array.

``preProcessRuleCollectionPreviewResults``

.. todo::

      Write documentation for this hook.

``ruleImportComputer_addGlobalCriteria``
   Add global criteria for computer import. Will receive an array of global criteria, is expected to return global criteria array.

``ruleImportComputer_getSqlRestriction``
   Adds SQL restriction to links. Will receive an array of the form:

   .. code-block:: php

      <?php
      array(
         'where_entity' => 'where entity clause',
         'input'        => 'input array',
         'criteria'     => 'complex cirteria array',
         'sql_where'    => 'sql where clause as string',
         'sql_from'     => 'sql from clause as string'
      )

   Is expected to return the input array modified.

``getAddSearchOptions``
   Adds :ref:`search options <search_options>`, using "old" method. Will receive item type as string, is expected to return an array of search options.

``getAddSearchOptionsNew``
   Adds :ref:`search options <search_options>`, using "new" method. Will receive item type as string, is expected to return an **indexed** array of search options.
