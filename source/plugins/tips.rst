Tips & tricks
-------------

Add a tab on a core object
++++++++++++++++++++++++++

In order to add a new tab on a core object, you will have to:

* register your class against core object(s) telling it you will add a tab,
* use ``getTabNameForItem()`` to give tab a name,
* use ``displayTabContentForItem()`` to display tab contents.

First, in the ``plugin_init_{plugin_name}`` function, add the following:

.. code-block:: php

   <?php
   //[...]
   Plugin::registerClass(
      'PluginMyExampleMyClass', [
         'addtabon' => [
            'Computer',
            'Phone'
         ]
      ]
   );
   //[...]

Here, we request to add a tab on `Computer` and `Phone` objects.

Then, in your ``inc/myclass.php`` (in which ``PluginMyExampleMyClass`` is defined):

.. code-block:: php

   <?php
   function getTabNameForItem(CommonGLPI $item, $withtemplate=0) {
      switch ($item::getType()) {
         case Computer::getType():
         case Phone::getType():
            return __('Tab from my plugin', 'myexampleplugin');
            break;
      }
      return '';
   }

   static function displayTabContentForItem(CommonGLPI $item, $tabnum=1, $withtemplate=0) {
      switch ($item::getType()) {
         case Computer::getType():
            //display form for computers
            self::displayTabContentForComputer($item);
            break;
         case Phone::getType():
            self::displayTabContentForPhone($item);
            break;
      }
      if ($item->getType() == 'ObjetDuCoeur') {
         $monplugin = new self();
         $ID = $item->getField('id');
        // j'affiche le formulaire
         $monplugin->nomDeLaFonctionQuiAfficheraLeContenuDeMonOnglet();
      }
      return true;
   }

   private static function displayTabContentForComputer(Computer $item) {
      //...
   }

   private static function displayTabContentForPhone(Phone $item) {
      //...
   }

On the above example, we have used two different methods to display tab, depending on item type. You could of course use only one if there is no (or minor) differences at display.

Add a tab on one of my plugin objects
+++++++++++++++++++++++++++++++++++++

In order to add a new tab on your plugin object, you will have to:

* use ``defineTabs()`` to register the new tab,
* use ``getTabNameForItem()`` to give tab a name,
* use ``displayTabContentForItem()`` to display tab contents.


Then, in your ``inc/myclass.php``:

.. code-block:: php

   <?php
   function defineTabs($options=array()) {
      $ong = array();
      //add main tab for current object
      $this->addDefaultFormTab($ong);
      //add core Document tab
      $this->addStandardTab(__('Document'), $ong, $options);
      return $ong;
   }


   /**
    * Définition du nom de l'onglet
   **/
   function getTabNameForItem(CommonGLPI $item, $withtemplate=0) {
      switch ($item::getType()) {
         case __CLASS__:
            return __('My plugin', 'myexampleplugin');
            break;
      }
      return '';
   }


   /**
    * Définition du contenu de l'onglet
   **/
   static function displayTabContentForItem(CommonGLPI $item, $tabnum=1, $withtemplate=0) {
      switch ($item::getType()) {
         case __CLASS__:
            self::myStaticMethod();
            break;
      }
      return true;
   }

Add several tabs
++++++++++++++++

On the same model you create one tab, you may add several tabs.

.. code-block:: php

   <?php
   function getTabNameForItem(CommonGLPI $item, $withtemplate=0) {
      $ong = [
         __('My first tab', 'myexampleplugin'),
         __('My second tab', 'myexampleplugin')
         ];
      return $ong;
   }

   static function displayTabContentForItem(CommonGLPI $item, $tabnum=0, $withtemplate=0) {
      switch ($tabnum) {
         case 0 : //"My first tab"
            //do something
            break;
         case 1 : //"My second tab""
            //do something else
            break;
      }
      return true;
   }


Add an object in dropdowns
++++++++++++++++++++++++++

Just add the following to your object class (``inc/myobject.class.php``):

.. code-block:: php

   <?php
   function plugin_myexampleplugin_getDropdown() {
      return ['PluginMyExampleMyObject' => PluginMyExampleMyObject::getTypeName(2)];
   }
