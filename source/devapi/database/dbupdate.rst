Updating
--------

.. versionadded:: 9.3

Just as SQL `SELECT` queries, you should avoid plain SQL and use methods provided by the famework from the `DB object <https://forge.glpi-project.org/apidoc/class-DBmysql.html>`_.

.. note::

   To make a database query that could not be done using recommanded way (calling SQL functions such as ``NOW()``, ``ADD_DATE()``, ... for example), you can do:

   .. code-block:: php

      <?php
      $DB->query('UPDATE glpi_users SET date_mod = NOW()');

   Just like :doc:`querying database <dbiterator>`; you will have to rely on plain SQL when using not supported features, like SQL functions.

General
^^^^^^^

Escaping of data is currently provided automatically by the framework for all data passed from `GET` or `POST`; you do not have to take care of them (this will change in a future version). You have to take care of escaping data when you use values that came from elsewhere.

The `WHERE` part of `UPDATE` and `DELETE` methods uses the same :ref:`criteria capabilities <query_criteria>` than `SELECT` queries.

Inserting a row
^^^^^^^^^^^^^^^

You can insert a row in the database using the `insert() method <https://forge.glpi-project.org/apidoc/class-DBmysql.html#_insert>`_:

.. code-block:: php

   <?php

   $DB->insert(
      'glpi_my_table', [
         'a_field'      => 'My value',
         'other_field'  => 'Other value'
      ]
   );
   // => INSERT INTO `glpi_my_table` (`a_field`, `other_field`) VALUES ('My value', Other value)

An `insertOrDie() method <https://forge.glpi-project.org/apidoc/class-DBmysql.html#_insertOrDie>`_ is also provided.

Updating a row
^^^^^^^^^^^^^^

You can update rows in the database using the `update() method <https://forge.glpi-project.org/apidoc/class-DBmysql.html#_update>`_:

.. code-block:: php

   <?php

   $DB->update(
      'glpi_my_table', [
         'a_field'      => 'My value',
         'other_field'  => 'Other value'
      ], [
         'id' => 42
      ]
   );
   // => UPDATE `glpi_my_table` SET `a_field` = 'My value', `other_field` = 'Other value' WHERE `id` = 42

An `updateOrDie() method <https://forge.glpi-project.org/apidoc/class-DBmysql.html#_updateOrDie>`_ is also provided.

.. note::

   The ``update()`` method does not currently support using another field in set. You will therefore have to run queries like ``UPDATE glpi_my_table` SET `ranking` = ranking+1`` using the legacy way.

Removing a row
^^^^^^^^^^^^^^

You can remove rows from the database using the `delete() method <https://forge.glpi-project.org/apidoc/class-DBmysql.html#_delete>`_:

.. code-block:: php

   <?php

   $DB->delete(
      'glpi_my_table', [
         'id' => 42
      ]
   );
   // => DELETE FROM `glpi_my_table` WHERE `id` = 42

Use prepared statements
^^^^^^^^^^^^^^^^^^^^^^^

On some cases, you may want to use prepared statements to improve performances. In order to achieve that, you will have to create a query with some parameters (not named, since mysqli does not supports named parameters), then to prepare it, and finally to bind parameters and execute the statement.

Let's see an example with an insert statement:

.. code-block:: php

   <?php
   $insert_query = $DB->buildInsert(
      'my_table', [
         'field'  => new Queryparam(),
         'other'  => new Queryparam()
      ]
   );
   // => INSERT INTO `glpi_my_table` (`field`, `other`) VALUES (?, ?)
   $insert_stmt = $DB->prepare($insert_query);

   foreach ($data as $row) {
      $stmt->bind_params(
         'ss',
         $row['field'],
         $row['other']
      );
      $stmt->execute();
   }

Just like the `buildInsert()` method used here, `buildInsert` and `buildDelete` methods are available. They take exactly the same arguments as non build methods.

.. note::

   Note the use of the `Queryparam` object. This is used for the builder to be aware you are not passing a value, but a parameter (that must not be escaped nor quoted).

Preparing a `SELECT` query is a bit different:

.. code-block:: php

   <?php
   $it = new DBmysqlIterator();
   $it->buildQuery([
      'FROM'   => 'my_table',
      'WHERE'  => [
         'something' => new Queryparam(),
         'foo'       => 'bar'
   ]);
   // => SELECT FROM `my_table` WHERE `something` = ? AND `foo` = 'bar'
   // [...]
