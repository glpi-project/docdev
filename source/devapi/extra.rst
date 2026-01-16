Extra
-----

The extra ``config/local_define.php`` file will be loaded if present. It permit you to change some GLPI framework configurations.

Override mailing recipient
^^^^^^^^^^^^^^^^^^^^^^^^^^

In some cases, during development, you may want to test notifications that can be sent. Problem is you will have to make sure you are not going to sent fake email to your real users if you rely on a production database copy for example.

You can define a unique email recipient for all emails that will be sent from GLPI. Original recipient address will be added as part of the message (for you to know who was originally targeted). To get all sent emails delivered on the `you@host.org` email address, use the ``GLPI_FORCE_MAIL`` in the ``local_define.php`` file:

.. code-block:: php

   <?php
   define('GLPI_FORCE_MAIL', 'you@host.org');
