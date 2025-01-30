Extra
-----

The extra ``config/local_define.php`` file will be loaded if present. It permit you to change some GLPI framework configurations.

Change loging level
^^^^^^^^^^^^^^^^^^^^

Logging level is declared with the ``GLPI_LOG_LVL`` constant; and rely on `available Monolog levels <https://github.com/Seldaek/monolog/blob/master/doc/01-usage.md#log-levels>`_. The default log level will change if debug mode is enabled on GUI or not. To change logging level to ``ERROR``, add the following to your ``local_define.php`` file:

.. code-block:: php

   <?php
   define('GLPI_LOG_LVL', \Monolog\Logger::ERROR);

.. note::

   Once you've declared a logging level, it will **always be used**. It will no longer take care of the debug mode.

Override mailing recipient
^^^^^^^^^^^^^^^^^^^^^^^^^^

In some cases, during development, you may want to test notifications that can be sent. Problem is you will have to make sure you are not going to sent fake email to your real users if you rely on a production database copy for example.

You can define a unique email recipient for all emails that will be sent from GLPI. Original recipient address will be added as part of the message (for you to know who was originally targetted). To get all sent emails delivered on the `you@host.org` email addresse, use the ``GLPI_FORCE_MAIL`` in the ``local_define.php`` file:

.. code-block:: php

   <?php
   define('GLPI_FORCE_MAIL', 'you@host.org');

Disabling CSRF checks
^^^^^^^^^^^^^^^^^^^^^

.. warning::

   **Use it with cautions!**

   While disabling CSRF checks may be really interesting during debugging, keep in mind that enabling it again (which is the default) may cause issues you cannot see before.

CSRF checks will prevent for example a same form to be sent twice. While this is the expected behavior for the application, this may be a pain during development or debugging. You can therefore use the ``GLPI_USE_CSRF_CHECK`` constant in the ``local_define.php`` file:

.. code-block:: php

   <?php
   define('GLPI_USE_CSRF_CHECK', 0);
