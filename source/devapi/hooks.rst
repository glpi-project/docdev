Hooks
-----

GLPI provides a certain amount of "hooks". Their goal is for plugins (mainly) to work on certain places of the framework; like when an item has been added, updated, deleted, ...

This page describes curreent existing hooks; but not the way they must be implemented from plugins. Please refer to the plugins development documentation.

.. todo::

   Write plugins develppoment documentation hooks parts and add a link to it!

Standards Hooks
^^^^^^^^^^^^^^^

Unclassified
++++++++++++

display_central
   Displays something on central page

Items business related
++++++++++++++++++++++

item_empty
   When an item has been emptied

post_prepareadd
   TODO

pre_item_add
   Before an item has been added

item_add
   While adding an item

pre_item_update
   Before an item is updated

item_update
   While updating an item

pre_item_purge
   Before an item is purged

item_purge
   While an item is purged

pre_item_restore
   Before an item is restored

item_restore
   While an item is restored

pre_item_delete
   Before an item is deleted

item_delete
   While an item is deleted

Items display related
+++++++++++++++++++++

pre_item_form
   Before an item is displayed; just after the form header if any; or at the beginnning of the form. Waits for a ``<tr>``.


post_item_form
   After an item form has been displayed; just before the dates or the save buttons. Waits for a ``<tr>``.

Functions hooks
^^^^^^^^^^^^^^^

unlock_fields
   TODO

restrict_ldap_auth
   TODO

Merge hooks
^^^^^^^^^^^


