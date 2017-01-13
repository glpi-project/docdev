Hooks
-----

GLPI provides a certain amount of "hooks". Their goal is for plugins (mainly) to work on certain places of the framework; like when an item has been added, updated, deleted, ...

This page describes curreent existing hooks; but not the way they must be implemented from plugins. Please refer to the plugins development documentation.

.. todo::

   Write plugins development documentation hooks parts and add a link to it!

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
