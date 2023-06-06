Notification modes
------------------

Core GLPI provides two notifications modes as of today:

* email (sends email),
* ajax (send browser notifications if/when user is logged)

It is possible to extends this mechanism in order to create another mode to use. Let's take a tour... We'll take example of a plugin designed to send SMS to the users.

Required configuration
^^^^^^^^^^^^^^^^^^^^^^

A few steps are required to setup the mode. In the ``init`` method (``setup.php`` file); register the mode:

.. code-block:: php

   <?php
   public function plugin_init_sms {
      //[...]

      if ($plugin->isActivated('sms')) {
         Notification_NotificationTemplate::registerMode(
            Notification_NotificationTemplate::MODE_SMS, //mode itself
            __('SMS', 'plugin_sms'),                //label
            'sms'                                   //plugin name
         );
      }

      //[...]
   }

.. note::

   GLPI will look for classes named like ``Plugin{NAME}Notification{MODE}``.

   In the above example; we have used one the the provided (but not yet used) modes from the core. If you need a mode that does not exists, you can of course create yours!

In order to make you new notification active, you will have to declare a ``notifications_{MODE}`` variable in the main configuration: You will add it at install time, and remove it on uninstall... In the ``hook.php`` file:

.. code-block:: php

   <?php

   function plugin_sms_install() {
      Config::setConfigurationValues('core', ['notifications_sms' => 0]);
      return true;
   }

   function plugin_sms_uninstall() {
      $config = new Config();
      $config->deleteConfigurationValues('core', ['notifications_sms']);
      return true;
   }

Settings
^^^^^^^^

You will probably need some configuration settings to get your notifications mode to work. You can register and retrieve additional configuration values using core ``Config`` object:

.. code-block:: php

   <?php
   //set configuration
   Config::setConfigurationValues(
      'plugin:sms', //context
      [ //values
         'server' => '',
         'port'   => ''
      ]
   );

   //get configuration
   $conf = Config::getConfigurationValues('plugin:sms');
   //$conf will be ['server' => '', 'port' => '']

That said, we need to create a class to handle the settings, and a front file to display them. The class must be named ``PluginSmsNotificationSmsSetting`` and must be in the ``inc/notificationsmssetting.class.php``. It have to extends the ``NotificationSetting`` core class :

.. code-block:: php

   <?php
   if (!defined('GLPI_ROOT')) {
      die("Sorry. You can't access this file directly");
   }

   /**
   *  This class manages the sms notifications settings
   */
   class PluginSmsNotificationSmsSetting extends NotificationSetting {


      static function getTypeName($nb=0) {
         return __('SMS followups configuration', 'sms');
      }


      public function getEnableLabel() {
         return __('Enable followups via SMS', 'sms');
      }


      static public function getMode() {
         return Notification_NotificationTemplate::MODE_SMS;
      }


      function showFormConfig($options = []) {
         global $CFG_GLPI;

         $conf = Config::getConfigurationValues('plugin:sms');
         $params = [
            'display'   => true
         ];
         $params = array_merge($params, $options);

         $out = "<form action='".Toolbox::getItemTypeFormURL(__CLASS__)."' method='post'>";
         $out .= Html::hidden('config_context', ['value' => 'plugin:sms']);
         $out .= "<div>";
         $out .= "<input type='hidden' name='id' value='1'>";
         $out .= "<table class='tab_cadre_fixe'>";
         $out .= "<tr class='tab_bg_1'><th colspan='4'>"._n('SMS notification', 'SMS notifications', Session::getPluralNumber(), 'sms')."</th></tr>";

         if ($CFG_GLPI['notifications_sms']) {
            //TODO
            $out .= "<tr><td colspan='4'>" . __('SMS notifications are not implemented yet.', 'sms') .  "</td></tr>";
         } else {
            $out .= "<tr><td colspan='4'>" . __('Notifications are disabled.')  . " <a href='{$CFG_GLPI['root_doc']}/front/setup.notification.php'>" . _('See configuration') .  "</td></tr>";
         }
         $options['candel']     = false;
         if ($CFG_GLPI['notifications_sms']) {
            $options['addbuttons'] = array('test_sms_send' => __('Send a test SMS to you', 'sms'));
         }

         //Ignore display parameter since showFormButtons is now ready :/ (from all but tests)
         echo $out;

         $this->showFormButtons($options);
      }
   }

The front form file, located at ``front/notificationsmssetting.form.php`` will be quite simple. It handles the display of the configuration form, update of the values, and test send (if any):

.. code-block:: php

   <?php
   include ('../../../inc/includes.php');

   Session::checkRight("config", UPDATE);
   $notificationsms = new PluginSmsNotificationSmsSetting();

   if (!empty($_POST["test_sms_send"])) {
      PluginSmsNotificationSms::testNotification();
      Html::back();
   } else if (!empty($_POST["update"])) {
      $config = new Config();
      $config->update($_POST);
      Html::back();
   }

   Html::header(Notification::getTypeName(Session::getPluralNumber()), $_SERVER['PHP_SELF'], "config", "notification", "config");

   $notificationsms->display(array('id' => 1));

   Html::footer();

Event
^^^^^

Once the new mode has been enabled; it will try to raise core events. You will need to create an event class named ``PluginSmsNotificationEventSms`` that implements ``NotificationEventInterface`` and extends ``NotificationEventAbstract`` in the ``inc/notificationeventsms.php``.

Methods to implement are:

* ``getTargetFieldName``: defines the name of the target field;
* ``getTargetField``: populates if needed the target field to use. For a SMS plugin, it would retrieve the phone number from users table for example;
* ``canCron``: whether notification can be called from a crontask. For the SMS plugins, it would be true. It is set to false for ajax based events; because notifications are requested from user browser;
* ``getAdminData``: as global admin is not a real user; you can define here the data used to send the notification;
* ``getEntityAdminData``: same as the above, but for entities admins rather than global admin;
* ``send``: method that will really send data.

The ``raise`` method declared in the interface is implemented in the abstract class; since it should be used as it for every mode. If you want to do extra process in the ``raise`` method, you should override the ``extraRaise`` method. This is done in the core to add signatures in the mailing for example.

.. note::

   Notifications uses the ``QueueNotification`` to store its data. Each notification about to be sent will be stored in the relevant table. Rows are updated once the notification has really be send (set ``is_deleted`` to 1 and update ``sent_time``.

En example class for SMS Events would look like the following:

.. code-block:: php

   <?php
   class PluginSmsNotificationEventSms implements NotificationEventInterface {

      static public function getTargetFieldName() {
         return 'phone';
      }


      static public function getTargetField(&$data) {
         $field = self::getTargetFieldName();

         if (!isset($data[$field])
            && isset($data['users_id'])) {
            // No phone set: get one for user
            $user = new user();
            $user->getFromDB($data['users_id']);

            $phone_fields = ['mobile', 'phone', 'phone2'];
            foreach ($phone_fields as $phone_field) {
               if (isset($user->fields[$phone_field]) && !empty($user->fields[$phone_field])) {
                  $data[$field] = $user->fields[$phone_field];
                  break;
               }
            }
         }

         if (!isset($data[$field])) {
            //Missing field; set to null
            $data[$field] = null;
         }

         return $field;
      }


      static public function canCron() {
         return true;
      }


      static public function getAdminData() {
         //no phone available for global admin right now
         return false;
      }


      static public function getEntityAdminsData($entity) {
         global $DB, $CFG_GLPI;

         $iterator = $DB->request([
            'FROM'   => 'glpi_entities',
            'WHERE'  => ['id' => $entity]
         ]);

         $admins = [];

         while ($row = $iterator->next()) {
            $admins[] = [
               'language'  => $CFG_GLPI['language'],
               'phone'     => $row['phone_number']
            ];
         }

         return $admins;
      }


      static public function send(array $data) {
         //data is an array of notifications to send. Process the array and send real SMS here!
         throw new \RuntimeException('Not yet implemented!');
      }
   }

Notification
^^^^^^^^^^^^

Finally, create a ``NotificationSms`` class that implements the ``NotificationInterface`` in the ``inc/notificationsms.php`` file.

Methods to implement are:

* ``check``: to validate data (checking if a mail address is well formed, ...);
* ``sendNotification``: to store raised event notification in the ``QueueNotification``;
* ``testNotification``: used from settings to send a test notification.

Again, the SMS example:

.. code-block:: php

   <?php
   class PluginSmsNotificationSms implements NotificationInterface {

      static function check($value, $options = []) {
         //Does nothing, but we could check if $value is actually what we expect as a phone number to send SMS.
         return true;
      }

      static function testNotification() {
         $instance = new self();
         //send a notification to current logged in user
         $instance->sendNotification([
            '_itemtype'                   => 'NotificationSms',
            '_items_id'                   => 1,
            '_notificationtemplates_id'   => 0,
            '_entities_id'                => 0,
            'fromname'                    => 'TEST',
            'subject'                     => 'Test notification',
            'content_text'                => "Hello, this is a test notification.",
            'to'                          => Session::getLoginUserID()
         ]);
      }


      function sendNotification($options=array()) {

         $data = array();
         $data['itemtype']                             = $options['_itemtype'];
         $data['items_id']                             = $options['_items_id'];
         $data['notificationtemplates_id']             = $options['_notificationtemplates_id'];
         $data['entities_id']                          = $options['_entities_id'];

         $data['sendername']                           = $options['fromname'];

         $data['name']                                 = $options['subject'];
         $data['body_text']                            = $options['content_text'];
         $data['recipient']                            = $options['to'];

         $data['mode'] = Notification_NotificationTemplate::MODE_SMS;

         $mailqueue = new QueuedMail();

         if (!$mailqueue->add(Toolbox::addslashes_deep($data))) {
            Session::addMessageAfterRedirect(__('Error inserting sms notification to queue', 'sms'), true, ERROR);
            return false;
         } else {
            //TRANS to be written in logs %1$s is the to email / %2$s is the subject of the mail
            Toolbox::logInFile("notification",
                              sprintf(__('%1$s: %2$s'),
                                       sprintf(__('An SMS notification to %s was added to queue', 'sms'),
                                             $options['to']),
                                       $options['subject']."\n"));
         }

         return true;
      }
   }
