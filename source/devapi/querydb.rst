Querying database
-----------------

To query database, you can use the ``$DB::request()`` method and give it a full SQL query.

.. warning::

   Whether this is possible to use full SQL t query database using this method, it should be avoid when possible, and you'd better use :doc:`DBIterator <dbiterator>` instead.

To make a database query that could not be done using DBIterator (calling SQL functions such as ``NOW()``, ``ADD_DATE()``, ... for example), you can do:

.. code-block:: php

   <?php
   $DB->request('SELECT id FROM glpi_users WHERE end_date > NOW()');
