Logging Systems and history
===========================

GLPI has distinct logging systems that must not be confused:

PHP logs
--------

It reports code errors. It can be used for debugging. It should remain empty.
It runs on Monolog (PSR-3 standard).

Output: ``files/_log/php-errors.log`` and ``files/_log/access-errors.log``

There are 3 handlers:

- ``src/Glpi/Log/ErrorLogHandler.php`` which outputs PHP errors and exceptions in ``files/_log/php-errors.log``.
- ``src/Glpi/Log/AccessLogHandler.php`` which outputs ``files/_log/access-errors.log``: HTTP access errors (4xx).
- ``tests/src/Log/TestHandler.php`` used only in automated testing context, contents are in memory only.

Usage
~~~~~

Developers can read or empty the logs using regular system utilities (tail, cat, ...).
Throwing an uncactched exception will write contents php-errors.log file. What is logged depend on configuration (see below).

Configuration
~~~~~~~~~~~~~

Logging level is declared with the ``GLPI_LOG_LVL`` constant; and rely on `available Monolog levels <https://github.com/Seldaek/monolog/blob/master/doc/01-usage.md#log-levels>`_. The default log level will change if debug mode is enabled on GUI or not. To change logging level to ``ERROR``, add the following to your ``local_define.php`` file:

The extra ``config/local_define.php`` file allow to change configuration.

.. code-block:: php

   <?php
   define('GLPI_LOG_LVL', \Monolog\Logger::ERROR);

.. note::

   Once you've declared a logging level, it will **always be used**. It will no longer take care of the debug mode.

By default, level is defined to `Warning` (see `\Glpi\Application\SystemConfigurator::computeConstants()`). In testing and development environments it's defined to `LogLevel::DEBUG` (see `\Glpi\Application\Environment::getConstantsOverride()`).

Event Log
---------

These logs are intended for GLPI administrators and can be viewed via the UI (Administration > Event logs).
For example it can log when a ticket is created.

- File: ``src/Glpi/Event.php``
- Method: ``Event::log($items_id, $type, $level, $service, $event)``
- Output: ``glpi_events`` database table
- View: in *administration > Logs : Event logs* (at the very top, do not confuse with the file ``event.log`` below)

Usage Example
~~~~~~~~~~~~~

.. code-block:: php

    // Log a successful login (level 3 = Important)
    Event::log(
        $user_id,
        "users",
        \User::getLogDefaultLevel(),
        "login",
        sprintf(__('%1$s log in from IP %2$s'), $login, $ip)
    );

Levels (``$level``) - GLPI Internal Scale (1-5)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **1 — Critical**: Critical security errors. Examples: Login failure.
- **2 — Severe**: Severe errors (currently unused).
- **3 — Important**: Important events. Examples: Successful logins.
- **4 — Notices (default)**: Standard events. Examples: Add, delete, tracking.
- **5 — Complete**: All events. Full details.

Configuration
~~~~~~~~~~~~~

It can be changed in *administration : Setup > General : Log Level*.
Global variable ``$CFG_GLPI["event_loglevel"]`` is then changed.

Behavior
~~~~~~~~

- Events are recorded if ``$level < $CFG_GLPI["event_loglevel"]``.
- Events with level ≤ 3 (more critical) are also written to ``files/_log/event.log`` via ``Toolbox::logInFile()`` (see File logs below).
- ``CommonDBTM::getLogDefaultLevel()`` returns the default level (4) for a class.

File logs - Toolbox::logInFile()
--------------------------------

`Toolbox::logInFile()` is a basic file Logging utility.

Direct file writing without level handling. Used for specific logs (cron, mail, ldap, etc.).
There is no level handling.

- File: ``src/Toolbox.php``
- Method: ``Toolbox::logInFile($name, $text, $force = false)`` — @todo documenter les autres méthodes.
- Output: ``files/_log/``: ``event.log``, ``mail.log``, ``cron.log``, ``ldap.log``, specified file name, etc.

Usage
~~~~~

.. code-block:: php

    // Log to files/_log/cron.log
    Toolbox::logInFile("cron", "Task executed successfully\n");

Configuration
~~~~~~~~~~~~~

Located at *administration : Setup > General : Logs in files (SQL, email, automatic action...)*, the ``switch`` allows to enable/disable this feature.
It can be forced using the ``force`` parameter of the method.


Other Toolbox methods
~~~~~~~~~~~~~~~~~~~~~

- ``Toolbox::logDebug()`` : it uses Php logger logs a php backtrace in ``php-errors`` file (same file as php logs (see PHP logs above)) with PSR level ``LogLevel::DEBUG``.

.. code-block:: php

    try {
        doSomethingThatMayTriggerAnException();
    } catch (Exception $e) {
        Toolbox::logDebug("Something wrong happend : " . $e->getMessage());
    }

- ``Toolbox::logInfo()`` : currently not used in glpi core, same as logDebug() with ``LogLevel::INFO``.
- ``Toolbox::backtrace()`` : may be deprecated soon, avoid using it, logs the php backtrace (or request filename) in a file (``php-errors`` by default, same file as php logs (see PHP logs above)).

Pitfalls & Tips
---------------

- `Toolbox::logInFile()` may log nothing if disabled in configuration.
- Event::log() (business logs) : Events with level ≤ 3 may also written to ``files/_log/event.log`` via ``Toolbox::logInFile()`` (if not disabled by configuration).

- Inverted Level Scales
   - ``Event::log()``: Lower level = more critical (1 = Critical)
   - ``Monolog``: Higher level = more critical (600 = Emergency)

- Files written in phpunit tests are written in ``tests/files/_log`` (and playright tests/e2e/files).