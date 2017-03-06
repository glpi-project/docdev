Automatic actions
-----------------

Goals
^^^^^

Plugins may need to run automatic actions in backgroupd, or at regular interval. GLPI provides a task scheduler for itself and its plugins.

Implement an automatic action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A plugin must implement its automatic action the same way as GLPI does, except the method is located in a plugin's itemtype. See :doc:`crontasks <../devapi/crontasks>`.

Register an automatic action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The plugin must register tasks to make GLPI know about them. This is done in the plugin's installer.

.. code-block:: php

   <?php
   CronTask::register('PluginExampleAutopurge', 'PurgeComputers', HOUR_TIMESTAMP,
         array(
         'comment'   => __('purge deleted computers from the database', 'example'),
         'mode'      => CronTask::MODE_EXTERNAL
   ));

GLPI will call once per hour the static method PluginExampleAutopurge::cronPurgeComputers(). Note the actual name of the method is prefixed by *cron*. The method may receive as argument an instance of CronTask.

The ``register`` method takes four arguments:

* `itemtype`: a `string` containing an itemtype name containing the automatic action implementation
* `name`: a `string` containing the name of a method
* `frequency` the period of time between two executions in seconds (see inc/define.php for convenient constants)
* `options` an array of options

Unregister a task
^^^^^^^^^^^^^^^^^

GLPI unregisters tasks of a plugin when it cleans or uninstalls it.


