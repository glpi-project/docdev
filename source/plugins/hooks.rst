Hooks
-----

GLPI provides a certain amount of "hooks". Their goal is for plugins (mainly) to work on certain places of the framework; like when an item has been added, updated, deleted, ...

This page describes current existing hooks; but not the way they must be implemented from plugins. Please refer to the plugins development documentation.

Usage
^^^^^

Aside from their goals or when/where they're called; you will see three types of different hooks. Some will receive an item as parameter, others an array of parameters, and some won't receive anything. Basically, the way they're declared into your plugin, and the way you'll handle that will differ.

All hooks called are defined in the ``setup.php`` file of your plugin; into the ``$PLUGIN_HOOKS`` array. The first key is the hook name, the second your plugin name; values can be just text (to call a function declared in the ``hook.php`` file), or an array (to call a static method from an object):

.. code-block:: php

   <?php
   $PLUGIN_HOOKS['hook_name']['plugin_name'] = 'function_name';
   $PLUGIN_HOOKS['other_hook']['plugin_name'] = ['ObjectName', 'methodName'];

Without parameters
++++++++++++++++++


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

The hooks that are called without parameters are: ``display_central``, ``post_init init_session``, ``change_entity``, ``change_profile`` and ``display_login``.

With item as parameter
++++++++++++++++++++++

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

With array of parameters
++++++++++++++++++++++++


Standards Hooks
^^^^^^^^^^^^^^^

Unclassified
++++++++++++

Hooks that cannot be classified in above categories :)

``display_central``
   Displays something on central page

``display_login``
   Displays something on the login page

``status``
   TODO

``post_init``
   After the framework initialization

``rule_matched``
   TODO

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
   When an item has been emptied

``post_prepareadd``
   TODO

``pre_item_add``
   Before an item has been added

``item_add``
   While adding an item

``pre_item_update``
   Before an item is updated

``item_update``
   While updating an item

``pre_item_purge``
   Before an item is purged

``item_purge``
   While an item is purged

``pre_item_restore``
   Before an item is restored

``item_restore``
   While an item is restored

``pre_item_delete``
   Before an item is deleted

``item_delete``
   While an item is deleted

``autoinventory_information``
   After an automated inventory has occured

``item_transfer``
   When an item is transfered from an entity to another

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

Functions hooks
^^^^^^^^^^^^^^^

``unlock_fields``
   TODO

``restrict_ldap_auth``
   TODO

``undiscloseConfigValue``
   TODO

``infocom``
   TODO

``retrieve_more_field_from_ldap``
   TODO

``retrieve_more_data_from_ldap``
   TODO

``display_locked_fields``
   TODO

``migratetypes``
   TODO

Notifications hooks
^^^^^^^^^^^^^^^^^^^
Hooks that are called from notifications

``item_add_targets``
   When a target has been added to an item

``item_get_events``
   TODO

``item_action_targets``
   TODO

``item_get_datas``
   TODO
