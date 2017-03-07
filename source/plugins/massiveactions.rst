Massive Actions
---------------

Plugins can use the core's :doc:`massive actions <../devapi/massiveactions>` for its own itemtypes.

They just need to aditionnaly define a hook in their init function (setup.php):

.. code-block:: php

   <?php

   function plugin_init_example() {
      $PLUGIN_HOOKS['use_massive_action']['example'] = 1;
   }

But they can also add specific massive actions to core's itemtypes.
First, in their ``hook.php`` file, they must declare a new definition into a ``plugin_pluginname_MassiveActions`` function, ex addition of new action for ``Computer``:

.. code-block:: php

   <?php

   function plugin_example_MassiveActions($type) {
      $actions = [];
      switch ($type) {
         case 'Computer' :
            $myclass      = PluginExampleExample;
            $action_key   = 'DoIt';
            $action_label = __("plugin_example_DoIt", 'example');
            $actions[$myclass.MassiveAction::CLASS_ACTION_SEPARATOR.$action_key]
               = $action_label;

            break;
      }

   }
   return $actions;
}

Next, in the class defined int the definition, we can use the ``showMassiveActionsSubForm`` and ``processMassiveActionsForOneItemtype`` in the same way as :ref:`core documentation for massive actions <massiveactions_specific_subform>`:

.. code-block:: php

   <?php

   class PluginExampleExample extends CommonDBTM {

      static function showMassiveActionsSubForm(MassiveAction $ma) {

         switch ($ma->getAction()) {
            case 'DoIt':
               echo __("fill the input");
               echo Html::input('myinput');
               echo Html::submit(__('Do it'), array('name' => 'massiveaction'))."</span>";

               return true;
       }
         return parent::showMassiveActionsSubForm($ma);
      }

      static function processMassiveActionsForOneItemtype(MassiveAction $ma, CommonDBTM $item,
                                                          array $ids) {
         global $DB;

         switch ($ma->getAction()) {
            case 'DoIt' :
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
   }