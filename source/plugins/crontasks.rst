Automatic actions
-----------------

Goals
^^^^^

Plugins may need to run automatic actions in background, or at regular interval. GLPI provides a task scheduler for itself and its plugins.

Implement an automatic action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A plugin must implement its automatic action the same way as GLPI does, except the method is located in a plugin's itemtype. See :doc:`crontasks <../devapi/crontasks>`.

Register an automatic action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A plugin must register its automatic action the same way as GLPI does in its upgrade process. See :doc:`crontasks <../devapi/crontasks>`.


Unregister a task
^^^^^^^^^^^^^^^^^

GLPI unregisters tasks of a plugin when it cleans or uninstalls it.


