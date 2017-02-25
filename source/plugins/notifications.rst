Notifications
-------------

Goals
^^^^^

Send email notifications to users when some event occurs


Add events on a notification in GLPI core
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is needed when the plugin needs to create a new event for an itemtype which belongs to GLPI core.

The folowing example creates an event `plugin_exemple` for Tickets.

In setup.php, hook the function `plugin_example_get_events()`.

.. code-block:: php

   <?php
   // File setup.php
   function plugin_init_example() {
      if ($plugin->isActivated('example')) {
         // ...

         $PLUGIN_HOOKS['item_get_events']['example'] = array('NotificationTargetTicket' => 'plugin_example_add_events');

         // ...
      }
   }

In hook.php

.. code-block:: php

   <?php
   // File hook.php
   function plugin_example_add_events(NotificationTargetTicket $target) {
      $target->events['plugin_example'] = __("Example event", 'example');
   }

.. note::

   GLPI also supports hook methods.


Add data on a event in GLPI core
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is needed when the plugin needs to create new placeholders in a notification which belongs to GLPI core.

The following example defines new data placeholders for Tickets.

In setup.php, hook the function `plugin_example_get_datas()`.

.. code-block:: php

   <?php
   // File setup.php
   function plugin_init_example() {
      if ($plugin->isActivated('example')) {
         // ...

         $PLUGIN_HOOKS['item_get_datas']['example'] = array('NotificationTargetTicket' => 'plugin_example_get_datas');

         // ...
      }
   }

In hook.php

.. code-block:: php

   <?php
   // File hook.php
   function plugin_example_get_datas(NotificationTargetTicket $target) {
      $target->datas['##ticket.example##'] = __("Example datas", 'example');
   }

.. note::

   GLPI also supports hook methods.

Create a new notification
^^^^^^^^^^^^^^^^^^^^^^^^^

If a plugin needs to create a notification for its own itemtype, it needs to create a notification and a notification template.

In the installation or upgrade code

Let's assume the plugin features SSL certificate management. When a SSL certificate comes to its end, the plugin should alert someone to renew it.

.. code-block:: php

   <?php
   // File hook.php

   function plugin_example_install() {
      // plain text version of the notification
      $contentText = 'The SSL certificate ##certificate.name## will expire soon.';
      $contentText.= 'Please, consider renew it quickly.';

      // HTML version of the notification
      $contentHtml = '<p>The SSL certificate <strong>##certificate.name##</strong> will expire soon.</p>';
      $contentHtml.= '<p>Please, consider renew it quickly.</p>';

      // Create the notification template
      $template = new NotificationTemplate();
      $templateId = $template->add([
            'name'      => 'SSL Certificates',
            'comment'   => 'Alert when a certificate comes to its end',
            'itemtype'  => 'PluginExampleCertificate',
      ]);

      // Create the default translation for the notification
      $translation = new NotificationTemplateTranslation();
      $translation->add([
            'notificationtemplates_id' => $templateId,
            'language'                 => '',                               // this is the default translation
            'subject'                  => 'A certificate comes to its end', // Sublect of the notification
            'content_text'             => $contentText,                     // text for plain text email
            'content_html'             => $contentHtml                      // text for HTML email
      ]);

      // Create the notification
      $notification = new Notification();
      $notificationId = $notification->add([
            'name'                     => 'SSL Certificates',
            'comment'                  => 'Notifications about SSL certificates',
            'entities_id'              => 0,
            'is_recursive'             => 1,
            'is_active'                => 1,
            'itemtype'                 => 'PluginExampleCertificate,
            'notificationtemplates_id' => $templateId,
            'event'                    => PluginExampleNotificationTargetCertificate::EVENT_EXPIRATION,
            'mode'                     => 'mail'
      ]);

      $notificationTarget = new PluginExampleNotificationTargetCertificate();
   }

.. Note::

   In the notification creation, the code uses ther constant `PluginExampleNotificationTargetCertificate::EVENT_EXPIRATION`. Don't forget to define it.

.. code-block:: php

   <?php
   // File inc/notificationtargetcertificate.class.php
   class PluginExampleNotificationTargetCertificate extends CommonDBTM
   {
      const EVENT_EXPIRATION = 'certificate expiration';
   }

The plugin uses hooks to define events supported by the notification, and data available in the message.

.. code-block:: php

   <?php
   // File setup.php
   function plugin_init_example() {
      if ($plugin->isActivated('example')) {
         // ...

         // Hook the static method PluginExampleNotificationTargetCertificate::getData()
         $PLUGIN_HOOKS['item_get_datas']['example'] = array(
               'NotificationTargetTicket' => array('PluginExampleNotificationTargetCertificate', 'getData')
         );

         // ...
      }
   }

.. Note::

   It is probably more convenient to use methods in `PluginExampleNotificationTargetCertificate` for notifications on itemtypes provided by the plugin itself.

.. code-block:: php

   <?php
   // File inc/notificationtargetcertificate.class.php
   class PluginExampleNotificationTargetCertificate extends CommonDBTM
   {
      // ...

      public static function getEvents($target) {
         return array(
               self::EVENT_GUEST_INVITATION => __('Invitation', 'exemple')
         );
      }

   }
