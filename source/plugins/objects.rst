Adding and managing objects
---------------------------

In most of the cases; your plugin will have to manage several objects

Define an object
++++++++++++++++

Objects definitions will be stored into the ``inc/`` directory of your plugin. File name will be the name of your class, lowercased; the class name will be the concatenation of your plugin name and your class name.

For example, if you want to create the ``MyObject`` in ``MyExamplePlugin``; you will create the ``inc/myobject.class.php`` file; and the class name will be ``MyExamplePluginMyObject``.

Your object will extends one of the :doc:`common core types <../devapi/mainobjects>` (``CommonDBTM`` in our example).

Extra operations are aslo described in the :doc:`tips and tricks page <tips>`, you may want to take a look at it.

Add a front for my object (CRUD)
++++++++++++++++++++++++++++++++

The goal is to build CRUD (Create, Read, Update, Delete) and list views for your object.

You will need:

* a class for your object (``inc/myobject.class.php``),
* a front file to handle display (``front/myobject.php``),
* a front file to handle form display (``front/myobject.form.php``).

First, create the ``inc/myobject.class.php`` file that looks like:

.. code-block:: php

   <?php
   class PluginMyExampleMyObject extends CommonDBTM {
      public function showForm($ID, $options = []) {
         global $CFG_GLPI;

         $this->initForm($ID, $options);
         $this->showFormHeader($options);

         if (!isset($options['display'])) {
            //display per default
            $options['display'] = true;
         }

         $params = $options;
         //do not display called elements per default; they'll be displayed or returned here
         $params['display'] = false;

         $out = '<tr>';
         $out .= '<th>' . __('My label', 'myexampleplugin') . '</th>'

         $objectName = autoName(
            $this->fields["name"],
            "name",
            (isset($options['withtemplate']) && $options['withtemplate']==2),
            $this->getType(),
            $this->fields["entities_id"]
         );

         $out .= '<td>';
         $out .= Html::autocompletionTextField(
            $this,
            'name',
            [
               'value'     => $objectName,
               'display'   => false
            ]
         );
         $out .= '</td>';

         $out .= $this->showFormButtons($params);

         if ($options['display'] == true) {
            echo $out;
         } else {
            return $out;
         }
      }
   }

The ``inc/myobject.php`` file will be in charge to list objects. It should look like:

.. code-block:: php

   <?php
   include ("../../../inc/includes.php");

   // Check if plugin is activated...
   $plugin = new Plugin();
   if (!$plugin->isInstalled('myexampleplugin') || !$plugin->isActivated('myexampleplugin')) {
      Html::displayNotFoundError();
   }

   //check for ACLs
   if (PluginMyExampleMyObject::canView()) {
      //View is granted: display the list.

      //Add page header
      Html::header(
         __('My example plugin', 'myexampleplugin'),
         $_SERVER['PHP_SELF'],
         'assets',
         'pluginmyexamplemyobject',
         'myobject'
      );

      Search::show('PluginMyExampleMyObject');

      Html::footer();
   } else {
      //View is not granted.
      Html::displayRightError();
   }

And finally, the ``front/myobject.form.php`` will be in charge of CRUD operations:

.. code-block:: php

   <?php
   include ("../../../inc/includes.php");

   // Check if plugin is activated...
   $plugin = new Plugin();
   if (!$plugin->isInstalled('myexampleplugin') || !$plugin->isActivated('myexampleplugin')) {
      Html::displayNotFoundError();
   }

   $object = new PluginMyExampleMyObject();

   if (isset($_POST['add'])) {
      //Check CREATE ACL
      $object->check(-1, CREATE, $_POST);
      //Do object creation
      $newid = $object->add($_POST);
      //Redirect to newly created object form
      Html::redirect("{$CFG_GLPI['root_doc']}/plugins/front/myobject.form.php?id=$newid");
   } else if (isset($_POST['update'])) {
      //Check UPDATE ACL
      $object->check($_POST['id'], UPDATE);
      //Do object update
      $object->update($_POST);
      //Redirect to object form
      Html::back();
   } else if (isset($_POST['delete'])) {
      //Check DELETE ACL
      $object->check($_POST['id'], DELETE);
      //Put object in dustbin
      $object->delete($_POST);
      //Redirect to objects list
      $object->redirectToList();
   } else if (isset($_POST['purge'])) {
      //Check PURGE ACL
      $object->check($_POST['id'], PURGE);
      //Do object purge
      $object->delete($_POST, 1);
      //Redirect to objects list
      Html::redirect("{$CFG_GLPI['root_doc']}/plugins/front/myobject.php");
   } else {
      //per default, display object
      $withtemplate = (isset($_GET['withtemplate']) ? $_GET['withtemplate'] : 0);
      $object->display(
         [
            'id'           => $_GET['id'],
            'withtemplate' => $withtemplate
         ]
      );
   }
