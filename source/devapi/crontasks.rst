Cron tasks
----------

Goals
^^^^^

Provide a scheduler for background tasks used by GLPI and its plugins. The scheduler wakes up thanks to user activity or from the operating system's scheduler. On each execution, it executes a limited number of tasks.


The entry point of cron tasks is the file front/cron.php. IT is called from the command line or from a web page when a user browses in GLPI.
