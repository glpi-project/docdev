Packaging
=========

Various Linux distributions provides packages (`deb`, `rpm`, ...) for GLPI (Debian, Mandriva, Fedora, Redhat/CentOS, ...) and for some plugins.

Here is some information about using and creating package:

* for users to understand how GLPI is installed
* for support to understand how GLPI work on this installation
* for packagers

Sources
-------

GLPI public tarball is designed for ends-user; it will not fit packaging requirements.
For example, this tarball bundle a lot of third party libraries, it does not ships unit tests, etc.

**A better candidate would be to retrieve directly a tarball from github as package source.**

Filesystem Hirerarchie Standard
-------------------------------

Most distributions requires that packages follows the  `FHS (Filesystem Hierarchy Standard) <http://www.pathname.com/fhs/>`_:

 * ``/etc/glpi`` for configuration files: ``config_db.php`` and ``config_db_slave.php``. Prior to 9.2 release, other files stay in ``glpi/config``; begining with 9.2, those files have been moved;
 * ``/usr/share/glpi`` for the web pages (read only dir);
 * ``/var/lib/glpi/files`` for GLPI data and state information (session, uploaded documents, cache, cron, plugins, ...);
 * ``/var/log/glpi`` for various GLPI log files.

The magic file ``/usr/share/glpi/config/config_path.php`` (not provided in the tarball) allows to configure various paths. The following example is the file used by `Remi <https://blog.remirepo.net/>`_ on its Fedora/Redhat repository:

.. code-block:: php

   <?php
   // Config
   define('GLPI_CONFIG_DIR',     '/etc/glpi');

   // Runtime Data
   define('GLPI_DOC_DIR',        '/var/lib/glpi/files');
   define('GLPI_CRON_DIR',       GLPI_DOC_DIR . '/_cron');
   define('GLPI_DUMP_DIR',       GLPI_DOC_DIR . '/_dumps');
   define('GLPI_GRAPH_DIR',      GLPI_DOC_DIR . '/_graphs');
   define('GLPI_LOCK_DIR',       GLPI_DOC_DIR . '/_lock');
   define('GLPI_PICTURE_DIR',    GLPI_DOC_DIR . '/_pictures');
   define('GLPI_PLUGIN_DOC_DIR', GLPI_DOC_DIR . '/_plugins');
   define('GLPI_RSS_DIR',        GLPI_DOC_DIR . '/_rss');
   define('GLPI_SESSION_DIR',    GLPI_DOC_DIR . '/_sessions');
   define('GLPI_TMP_DIR',        GLPI_DOC_DIR . '/_tmp');
   define('oGLPI_UPLOAD_DIR',     GLPI_DOC_DIR . '/_uploads');

   // Log
   define('GLPI_LOG_DIR',        '/var/log/glpi');

   // System libraries
   define('GLPI_HTMLAWED',       '/usr/share/php/htmLawed/htmLawed.php');

   // Fonts
   define('GLPI_FONT_FREESANS',  '/usr/share/fonts/gnu-free/FreeSans.ttf');

   //Use system cron
   define('GLPI_SYSTEM_CRON', true);

Apache Configuration File
-------------------------

Here is a configuration file sample for the Apache web server:

.. code-block:: apacheconf

   #To access via http://servername/glpi/
   Alias /glpi /usr/share/glpi

   # some people prefer a simple URL like http://glpi.example.com
   #<VirtualHost *:80>
   #  DocumentRoot /usr/share/glpi
   #  ServerName glpi.example.com
   #</VirtualHost>

   <Directory /usr/share/glpi>
       Options None
       AllowOverride None

       # to overwrite default configuration which could be less than recommanded value
       php_value memory_limit 64M

      <IfModule mod_authz_core.c>
         # Apache 2.4
         Require all granted
      </IfModule>
      <IfModule !mod_authz_core.c>
         # Apache 2.2
         Order Deny,Allow
         Allow from All
      </IfModule>
   </Directory>

   <Directory /usr/share/glpi/install>
       # 15" should be enough for migration in most case
       php_value max_execution_time 900
       php_value memory_limit 128M
   </Directory>

   # This sections remplace the .htaccess files provided in the tarball 
   <Directory /usr/share/glpi/config>
      <IfModule mod_authz_core.c>
         # Apache 2.4
         Require all denied
      </IfModule>
      <IfModule !mod_authz_core.c>
         # Apache 2.2
         Order Deny,Allow
         Deny from All
      </IfModule>
   </Directory>

   <Directory /usr/share/glpi/locales>
      <IfModule mod_authz_core.c>
         # Apache 2.4
         Require all denied
      </IfModule>
      <IfModule !mod_authz_core.c>
         # Apache 2.2
         Order Deny,Allow
         Deny from All
      </IfModule>
   </Directory>

   <Directory /usr/share/glpi/install/mysql>
      <IfModule mod_authz_core.c>
         # Apache 2.4
         Require all denied
      </IfModule>
      <IfModule !mod_authz_core.c>
         # Apache 2.2
         Order Deny,Allow
         Deny from All
      </IfModule>
   </Directory>

   <Directory /usr/share/glpi/scripts>
      <IfModule mod_authz_core.c>
         # Apache 2.4
         Require all denied
      </IfModule>
      <IfModule !mod_authz_core.c>
         # Apache 2.2
         Order Deny,Allow
         Deny from All
      </IfModule>
   </Directory>

Logs files rotation
-------------------

Here is a logrotate sample configuration file (``/etc/logrotate.d/glpi``):

.. code-block:: none

   # Rotate GLPI logs daily, only if not empty
   # Save 14 days old logs under compressed mode
   /var/log/glpi/*.log {
      daily
      rotate 14
      compress
      notifempty
      missingok
      create 644 apache apache
   }

SELinux stuff
-------------

For `SELinux <http://en.wikipedia.org/wiki/Selinux>`_ enabled distributions, you need to declare the correct context for the folders.

As an example, on Redhat based distributions:

 * ``/etc/glpi`` and ``/var/lib/glpi``: ``httpd_sys_script_rw_t``, the web server need to write the config file in the former and various data in the latter;
 * ``/var/log/glpi``: ``httpd_log_t`` (apache log type: write only, no delete).

Use system cron
---------------

GLPI provides an internal cron for automated tasks. Using a system cron allow a more consistent and regular execution, for example when no user connected on GLPI.

.. note::

   ``cron.php`` should be run as the web server user (``apache`` or ``www-data``)

You will need a crontab file, and to configure GLPI to use system cron. Sample cron configuration file (``/etc/cron.d/glpi``):

.. code-block:: none

   # GLPI core
   # Run cron from to execute task even when no user connected
   */4 * * * * apache /usr/bin/php /usr/share/glpi/front/cron.php

To tell GLPI it must use the system crontab, simply define the ``GLPI_SYSTEM_CRON`` constant to ``true`` in the ``config_path.php`` file:

.. code-block:: php

   <?php
   //[...]

   //Use system cron
   define('GLPI_SYSTEM_CRON', true);

Using system libraries
----------------------

Since most distributions prefers the use of system libraries (maintained separately); you can't rely on the vendor directory shipped in the public tarball; nor use composer.

The way to handle third party libraries is to provide an autoload file with paths to you system libraries. You'll find all requirements from the ``composer.json`` file provided along with GLPI:

.. code-block:: php

   <?php
   $vendor = '##DATADIR##/php';
   // Dependencies from composer.json
   // "ircmaxell/password-compat"
   // => useless for php >= 5.5
   //require_once $vendor . '/password_compat/password.php';
   // "jasig/phpcas"
   require_once '##DATADIR##/pear/CAS/Autoload.php';
   // "iamcal/lib_autolink"
   require_once $vendor . '/php-iamcal-lib-autolink/autoload.php';
   // "phpmailer/phpmailer"
   require_once $vendor . '/PHPMailer/PHPMailerAutoload.php';
   // "sabre/vobject"
   require_once $vendor . '/Sabre/VObject/autoload.php';
   // "simplepie/simplepie"
   require_once $vendor . '/php-simplepie/autoloader.php';
   // "tecnickcom/tcpdf"
   require_once $vendor . '/tcpdf/tcpdf.php';
   // "zendframework/zend-cache"
   // "zendframework/zend-i18n"
   // "zendframework/zend-loader"
   require_once $vendor . '/Zend/autoload.php';
   // "zetacomponents/graph"
   require_once $vendor . '/ezc/Graph/autoloader.php';
   // "ramsey/array_column"
   // => useless for php >= 5.5
   // "michelf/php-markdown"
   require_once $vendor . '/Michelf/markdown-autoload.php';
   // "true/punycode"
   if (file_exists($vendor . '/TrueBV/autoload.php')) {
      require_once $vendor . '/TrueBV/autoload.php';
   } else {
      require_once $vendor . '/TrueBV/Punycode.php';
   }

.. note::

   In the above example, the ``##DATADIR##`` value will be replaced by the correct value (``/usr/share/php`` for instance) from the specfile using macros. Adapt with your build system possibilities.


Using system fonts rather than bundled ones
-------------------------------------------

Some distribution prefers the use of system fonts (maintained separately).

GLPI use the `FreeSans.ttf <http://www.nongnu.org/freefont/>`_ font you can configure adding in the ``config_path.php``:

.. code-block:: php

   <?php
   //[...]

   define('GLPI_FONT_FREESANS',  '/path/to/FreeSans.ttf');

Notes
-----

This informations are taken from the Fedora/EPEL spec file.

Feel free to add information about other specific distribution tips.
