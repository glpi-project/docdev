Updating
--------

.. versionadded:: 9.3

Just as SQL `SELECT` queries, you should avoid plain SQL and use methods provided by the famework from the ``DB`` object.

General
^^^^^^^

Escaping of data is currently provided automatically by the framework for all data passed from `GET` or `POST`; you do not have to take care of them (this will change in a future version). You have to take care of escaping data when you use values that came from elsewhere.

The `WHERE` part of `UPDATE` and `DELETE` methods uses the same :ref:`criteria capabilities <query_criteria>` than `SELECT` queries.

Inserting a row
^^^^^^^^^^^^^^^

You can insert a row in the database using the ``insert()``:

.. code-block:: php

   <?php

   $DB->insert(
      'glpi_my_table', [
         'a_field'      => 'My value',
         'other_field'  => 'Other value'
      ]
   );
   // => INSERT INTO `glpi_my_table` (`a_field`, `other_field`) VALUES ('My value', Other value)

An ``insertOrDie()`` method is also provided.

Updating a row
^^^^^^^^^^^^^^

You can update rows in the database using the ``update()`` method:

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

An ``updateOrDie()`` method is also provided.

.. versionadded:: 9.3.1

When issuing an `UPDATE` query, you can use an `ORDER` and/or a `LIMIT` clause along with the where (which remains **mandatory**). In order to achieve that, use an indexed array with appropriate keys:

.. code-block:: php

   <?php
   $DB->update(
      'my_table', [
         'my_field'  => 'my value'
      ], [
         'WHERE'  => ['field' => 'value'],
         'ORDER'  => ['date DESC', 'id ASC'],
         'LIMIT'  => 1
      ]
   );

Removing a row
^^^^^^^^^^^^^^

You can remove rows from the database using the ``delete()`` method:

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
   $stmt = $DB->prepare($insert_query);

   foreach ($data as $row) {
      $stmt->bind_params(
         'ss',
         $row['field'],
         $row['other']
      );
      $stmt->execute();
   }

Just like the `buildInsert()` method used here, `buildUpdate` and `buildDelete` methods are available. They take exactly the same arguments as "non build" methods.

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
   $query = $it->getSql();
   // => SELECT FROM `my_table` WHERE `something` = ? AND `foo` = 'bar'
   $stmt = $DB->prepare($query);
   // [...]
