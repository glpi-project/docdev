Cron tasks
----------

Goals
^^^^^

Plugins may need to run tasks in backgroupd, or at regular interval. GLPI provides a task scheduler for itself and its plugins.


Register a task
^^^^^^^^^^^^^^^

The plugin must register tasks to make GLPI know about them. This is done in the plugin's installer.


.. code-block:: php

   <?php
   CronTask::register('PluginExampleAutopurge', 'PurgeComputers', HOUR_TIMESTAMP,
         array(
         'comment'   => __('purge deleted computers from the database', 'example'),
         'mode'      => CronTask::MODE_EXTERNAL
   ));

GLPI will call once per hour the static method PluginExampleAutopurge::cronPurgeComputers(). Note the actual name of the method is prefixed by *cron*. The method receives as argument an instance of CronTask.

Implement a task
^^^^^^^^^^^^^^^^

.. code-block:: php

   <?php
   class PluginExampleAutopurge extends CommonDBTM
   {
      /**
       * purge deleted computers
       *
       * @param CronTask $task instance of CronTask 
       * @return void
       */
      public static function cronPurgeComputers(CronTask $task) {
         // log the task execution in CronTaskLog
         $task->log("Purge deleted computers");

         // count items to purge
         $volume = countElementsInTable(Computer::getTable(), "is_deleted = '1'");

         // do the purge
         $computer = new Computer();
         $computer->deleteByCriteria(array('is_deleted' => '1');

         // count actually purged items
         $volume = $volume - countElementsInTable(Computer::getTable(), "is_deleted = '1'");

         // report quantity of processed items
         $task->setVolume($volume);
      }
   }

The ``register`` method takes four arguments:

* `itemtype`: a `string` containing an itemtype name
* `name`: a `string` containing the name of a method
* `frequency` the period of time between two executions in seconds (see inc/define.php for convenient constants)
* `options` an array of options

Provide task data
^^^^^^^^^^^^^^^^^

GLPI expects additional data to display the list of tasks. The plugin should implement the methods `getTypeName()` and `cronInfo()`.

.. code-block:: php

   <?php
   class PluginExampleAutopurge extends CommonDBTM
   {
      /**
       * name of the itemtype
       *
       * @param integer $nb quantity
       * @return string
       */
      public static function getTypeName($nb) {
         return _n('Purge', 'Purges', $nb);
      }

     /**
      * get Cron description parameter for this class
      *
      * @param $name string name of the task
      *
      * @return array of string
      */
      static function cronInfo($name) {
         // an itemtype may implement several cron tasks
         // $name is the task name as defined on the call of CronTask::register()

         switch ($name) {
            case 'PurgeComputers':
               return array('description' => __('Purges deleted computers'));
         }
      }
   }


Unregister a task
^^^^^^^^^^^^^^^^^

GLPI unregisters tasks of a plugin when it cleans or uninstalls it.


