Massive Actions
---------------

.. image:: images/massiveactions.png
   :alt: Massive action controls

Goals
^^^^^

Add to itemtypes :doc:`search lists <../devapi/search>`:

- a checkbox before each item,
- a checkbox to select all items checkboxes,
- an `Actions` button to apply modifications to each selected items.

Update item's fields
^^^^^^^^^^^^^^^^^^^^

The first option of the ``Actions`` button is ``Update``.
It permits to modify the fields content of the selected items.

The list of fields displayed in the sub list depends on the :ref:`search_options` of the current itemtype.
By default, all :ref:`search_options` are automatically displayed in this list.
To forbid this display for one field, you must define the key ``massiveaction`` to false in the :ref:`search_options` declaration, example:

.. code-block:: php

   <?php

   $tab[] = [
      'id'            => '1',
      'table'         => self::getTable(),
      'field'         => 'name',
      'name'          => __('Name'),
      'datatype'      => 'itemlink',
      'massiveaction' => false // <- NO MASSIVE ACTION
   ];

.. _massiveactions_specific:

Specific massive actions
^^^^^^^^^^^^^^^^^^^^^^^^

After the ``Update`` entry, we can declare additional specific massive actions for our current itemtype.

First, we need declare in our class a ``getSpecificMassiveActions`` method containing our massive action definitions:

.. code-block:: php

   <?php

   ...

   function getSpecificMassiveActions($checkitem=NULL) {
      $actions = parent::getSpecificMassiveActions($checkitem);

      // add a single massive action
      $class        = __CLASS__;
      $action_key   = "myaction_key";
      $action_label = "My new massive action";
      $actions[$class.MassiveAction::CLASS_ACTION_SEPARATOR.$action_key] = $action_label;

      return $actions;
   }

A single declaration is defined by these parts:

- a ``classname``
- a ``separator``: always ``MassiveAction::CLASS_ACTION_SEPARATOR``
- a ``key``
- and a ``label``

We can have multiple actions for the same class, and we may target different class from our current object.

.. _massiveactions_specific_subform:

Next, to display the form of our definitions, we need to declare a ``showMassiveActionsSubForm`` method:

.. code-block:: php

   <?php

   ...

   static function showMassiveActionsSubForm(MassiveAction $ma) {
      switch ($ma->getAction()) {
         case 'myaction_key':
            echo __("fill the input");
            echo Html::input('myinput');
            echo Html::submit(__('Do it'), array('name' => 'massiveaction'))."</span>";

            break;
      }

      return parent::showMassiveActionsSubForm($ma);
   }

.. _massiveactions_specific_process:

Finally, to process our definition, we need a ``processMassiveActionsForOneItemtype`` method:


.. code-block:: php

   <?php

   ...

   static function processMassiveActionsForOneItemtype(MassiveAction $ma, CommonDBTM $item,
                                                       array $ids) {
      switch ($ma->getAction()) {
         case 'myaction_key':
            $input = $ma->getInput();

            foreach ($ids as $id) {

               if ($item->getFromDB($id)
                   && $item->doIt($input)) {
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

Besides an instance of ``MassiveAction`` class ``$ma``, we have also an instance of the current ``itemtype`` ``$item and the list of selected id ``$ids``.

In this method, we could use some optional utility functions from the ``MassiveAction $ma`` object supplied in parameter :

- ``itemDone``, indicates the result of the current ``$id``, see constants of ``MassiveAction`` class. If we miss this call, the current ``$id`` will still be considered as OK.
- ``addMessage``, a string to send to the user for explaining the result when processing the current ``$id``
