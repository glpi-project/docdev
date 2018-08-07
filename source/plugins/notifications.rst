Notifications
-------------

Goals
^^^^^

Send email notifications to users when some event occurs


Add events on a notification in GLPI core
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is needed when the plugin needs to create a new event for an itemtype which belongs to GLPI core.

The folowing example creates an event `plugin_example` for Tickets.

In setup.php, hook the function `plugin_example_get_events()`.

.. code-block:: php

   <?php
   // File setup.php
   function plugin_init_example() {
      if ($plugin->isActivated('example')) {
         // ...

         // hook to declare aditional events for ticket notifications
         $PLUGIN_HOOKS['item_get_events']['example'] = array('NotificationTargetTicket' => 'plugin_example_add_events');

         // ...
      }
   }

In hook.php

.. code-block:: php

   <?php
   // File hook.php
   function plugin_example_add_events(NotificationTargetTicket $target) {
      // the localized event name is added to other events available in  the notification
      $target->events['plugin_example'] = __("Example event", 'example');
   }

.. note::

   GLPI also supports hook methods.


Add data on a event in GLPI core
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If the plugin needs to create new placeholders in a notification which belongs to GLPI core.

The following example defines new data placeholders for Ticket notifications.

In setup.php, hook the function `plugin_example_get_datas()`.

.. code-block:: php

   <?php
   // File setup.php
   function plugin_init_example() {
      if ($plugin->isActivated('example')) {
         // ...

         // hook to define additional placeholders for ticket notifications
         $PLUGIN_HOOKS['item_get_datas']['example'] = array('NotificationTargetTicket' => 'plugin_example_get_datas');

         // ...
      }
   }

In hook.php

.. code-block:: php

   <?php
   // File hook.php
   function plugin_example_get_datas(NotificationTargetTicket $target) {
      // replace the placeholder by an actual data provided by the plugin
      $target->datas['##ticket.example##'] = __("Example datas", 'example');
   }

.. note::

   GLPI also supports hook methods.

It is up to the plugin or the administrator of GLPI to update the notification templates in order to use the new placeholder.

Create a new notification
^^^^^^^^^^^^^^^^^^^^^^^^^

If a plugin needs to create a notification for its own itemtype, it needs to create a notification and a notification template. The plugin must create these items in the installation or upgrade code.

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
            'itemtype'                 => 'PluginExampleCertificate',
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
   class PluginExampleNotificationTargetCertificate extends NotificationTarget
   {
      const EVENT_EXPIRATION = 'expiration';
   }

.. code-block:: php

   <?php
   // File inc/notificationtargetcertificate.class.php
   class PluginExampleNotificationTargetCertificate extends NotificationTarget
   {
      // ...

      /**
       * Provide to GLPI the localized name of events
       *
       * @return string[] : associative array 'event_name' => 'localized name'
       */
      public static function getEvents() {
         return array(
               self::EVENT_EXPIRATION => __('Certificate expiration', 'exemple')
         );
      }

      /**
       * @param string $event
       *
       * @param array  $options
       */
      public fucntion getDatasForTemplate($event, $options) {
         switch ($event) {
            case self::EVENT_EXPIRATION:
               // use the name of the certificate to fill a placeholder in the notification
               $this->datas['##certificate.name##'] = $this->obj->getField('name');
               break;
         }
      }
   }
