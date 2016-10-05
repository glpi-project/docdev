Querying database
-----------------

To query database, you can use hte ``$DB::query()`` method.

.. warning::

   Whether this is possible to query database directly using this method, it should be avoid when possible, and you'd better use :doc:`DBIterator <dbiterator>` instead.


To make a database query that could not be done using ``$DB->request()``, to call SQL functions  (``NOW()``, ``ADD_DATE()``, ...) for example, you can use the ``query()`` method:

.. code-block:: php

   <?php
   $DB->query('SELECT id FROM glpi_users WHERE end_date > NOW()');
