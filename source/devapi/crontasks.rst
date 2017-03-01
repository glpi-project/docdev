Automatic actions
-----------------

Goals
^^^^^

Provide a scheduler for background tasks used by GLPI and its plugins. 

Implementation overview
^^^^^^^^^^^^^^^^^^^^^^^

The scheduler wakes up thanks to user activity or from the operating system's scheduler. On each execution, it executes a limited number of automatic actions.

The entry point of automatic actions is the file front/cron.php. It is called from the command line or from a web page when a user browses in GLPI.

The automatic actions are defined by the class CronTask. GLPI defines a lot of them for its own needs. They are created in the installation or upgrade process.

Register an automatic actions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Automatic actions are defined in the empty schema located in ``install/mysql/``. To handle upgrade from a previous version, the new automatic actions must be added in the appropriate update file in ``install/``.

Implementation
^^^^^^^^^^^^^^

Automatic actions are implemented in static methods of itemtypes. The itemtype containing the automatic action should be an itemtype related to the action. However some automatic actions are related to themselves or cannot be related to an itemtype. Such automatic actions are implemented in CronTask.

When GLPI shows a list of automatic actions, it shows a short description for each item. The description is gathered in the static method ``cronInfo()`` in the itemtype containing the automatic actions.

.. Note::

   An itemtype may contain several automatic actions.

Example of implemtation from the class ``QueuedMail``:

.. code-block:: php

   <?php
   class QueuedMail extends CommonDBTM {

      // ...

      /**
       * Give cron information
       *
       * @param $name : task's name
       *
       * @return arrray of information
      **/
      static function cronInfo($name) {

         switch ($name) {
            case 'queuedmail' :
               return array('description' => __('Send mails in queue'),
                            'parameter'   => __('Maximum emails to send at once'));
         }
         return array();
      }

      /**
       * Cron action on queued mails : send mails in queue
       *
       * @param CronTask $task for log, if NULL display (default NULL)
       *
       * @return integer 1 if an action was done, 0 if not
      **/
      static function cronQueuedMail($task=NULL) {
         global $DB, $CFG_GLPI;

         if (!$CFG_GLPI["use_mailing"]) {
            return 0;
         }
         $cron_status = 0;

         // Send mail at least 1 minute after adding in queue to be sure that process on it is finished
         $send_time = date("Y-m-d H:i:s", strtotime("+1 minutes"));
         $query       = "SELECT `glpi_queuedmails`.*
                         FROM `glpi_queuedmails`
                         WHERE NOT `glpi_queuedmails`.`is_deleted`
                               AND `glpi_queuedmails`.`send_time` < '".$send_time."'
                         ORDER BY `glpi_queuedmails`.`send_time` ASC
                         LIMIT 0, ".$task->fields['param'];

         $mail = new self();
         foreach ($DB->request($query) as $data) {
            if ($mail->sendMailById($data['id'])) {
               $cron_status = 1;
               if (!is_null($task)) {
                  $task->addVolume(1);
               }
            }
         }
         return $cron_status;
      }

      // ...

   }

If the argument $task is a CronTask object, the automatic action must increment the quantoty of actions done. In this example, each email actually sent increments the volume by 1.
