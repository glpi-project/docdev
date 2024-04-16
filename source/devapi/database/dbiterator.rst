Querying
--------

GLPI framework provides a simple request generator:

* without having to write SQL
* without having to quote table and field name
* without escaping values to prevent SQL injections
* without having to take care of freeing resources
* iterable
* countable

Basic usage
^^^^^^^^^^^

.. code-block:: php

   <?php
   foreach ($DB->request(...) as $id => $row) {
      //... work on each row ...
   }

   $req = $DB->request(...);
   if ($row = $req->next()) {
     // ... work on a single row
   }

   $req = $DB->request(...);
   if (count($req)) {
     // ... work on result
   }

Arguments
^^^^^^^^^

The ``request`` method takes as argument an array of criteria with explicit SQL clauses (`FROM`, `WHERE` and so on)


.. note::

   To make a database query that could not be done using recommanded way (calling SQL functions such as ``NOW()``, ``ADD_DATE()``, ... for example), you can do:

   .. code-block:: php

      <?php
      $DB->doQuery('SELECT id FROM glpi_users WHERE end_date > NOW()');

   **Keep in mind you have to ensure that kind of query is proprely escaped!**

FROM clause
^^^^^^^^^^^

The SQL ``FROM`` clause can be a string or an array of strings:

.. code-block:: php

   <?php
   $DB->request(['FROM' => 'glpi_computers']);
   // => SELECT * FROM `glpi_computers`

   $DB->request(['FROM' => ['glpi_computers', 'glpi_monitors']);
   // => SELECT * FROM `glpi_computers`, `glpi_monitors`

Fields selection
^^^^^^^^^^^^^^^^

You can use either the ``SELECT`` or ``FIELDS`` options, an additional ``DISTINCT`` option might be specified.

.. note::

   .. versionchanged:: 9.5.0

   Using ``DISTINCT FIELDS`` or ``SELECT DISTINCT`` options is deprecated.

.. code-block:: php

   <?php
   $DB->request(['SELECT' => 'id', 'FROM' => 'glpi_computers']);
   // => SELECT `id` FROM `glpi_computers`

   $DB->request(['SELECT' => 'name', 'DISTINCT' => true, 'FROM' => 'glpi_computers']);
   // => SELECT DISTINCT `name` FROM `glpi_computers`

The fields array can also contain per table sub-array:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['FIELDS' => ['glpi_computers' => ['id', 'name']]]);
   // => SELECT `glpi_computers`.`id`, `glpi_computers`.`name` FROM `glpi_computers`"

Using JOINs
^^^^^^^^^^^

You need to use criteria, usually a ``FKEY`` to describe how to join the tables.

.. note::

   .. versionadded:: 9.3.1

   The ``ON`` keyword can aslo be used as an alias of ``FKEY``.

Multiple tables, native join
++++++++++++++++++++++++++++

You need to use criteria, usually a ``FKEY`` (or the ``ON`` equivalent), to describe how to join the tables:

.. code-block:: php

   <?php
   $DB->request(['FROM' => ['glpi_computers', 'glpi_computerdisks'],
                 'FKEY' => ['glpi_computers'=>'id',
                            'glpi_computerdisks'=>'computer_id']]);
   // => SELECT * FROM `glpi_computers`, `glpi_computerdisks`
   //       WHERE `glpi_computers`.`id` = `glpi_computerdisks`.`computer_id`

Left join
+++++++++

Using the ``LEFT JOIN`` option, with some criteria, usually a ``FKEY`` (or the ``ON`` equivalent):

.. code-block:: php

   <?php
   $DB->request(['FROM'      => 'glpi_computers',
                 'LEFT JOIN' => ['glpi_computerdisks' => ['FKEY' => ['glpi_computers'     => 'id',
                                                                     'glpi_computerdisks' => 'computer_id']]]]);
   // => SELECT * FROM `glpi_computers`
   //       LEFT JOIN `glpi_computerdisks`
   //         ON (`glpi_computers`.`id` = `glpi_computerdisks`.`computer_id`)

Inner join
++++++++++

Using the ``INNER JOIN`` option, with some criteria, usually a ``FKEY`` (or the ``ON`` equivalent):

.. code-block:: php

   <?php
   $DB->request(['FROM'       => 'glpi_computers',
                 'INNER JOIN' => ['glpi_computerdisks' => ['FKEY' => ['glpi_computers'     => 'id',
                                                                      'glpi_computerdisks' => 'computer_id']]]]);
   // => SELECT * FROM `glpi_computers`
   //       INNER JOIN `glpi_computerdisks`
   //         ON (`glpi_computers`.`id` = `glpi_computerdisks`.`computer_id`)

Right join
++++++++++

Using the ``RIGHT JOIN`` option, with some criteria, usually a ``FKEY`` (or the ``ON`` equivalent):

.. code-block:: php

   <?php
   $DB->request(['FROM'       => 'glpi_computers',
                 'RIGHT JOIN' => ['glpi_computerdisks' => ['FKEY' => ['glpi_computers'     => 'id',
                                                                      'glpi_computerdisks' => 'computer_id']]]]);
   // => SELECT * FROM `glpi_computers`
   //       RIGHT JOIN `glpi_computerdisks`
   //         ON (`glpi_computers`.`id` = `glpi_computerdisks`.`computer_id`)

Join criterion
++++++++++++++

.. versionadded:: 9.3.1

It is also possible to add an extra criterion for any `JOIN` clause. You have to pass an array with first key equal to ``AND`` or ``OR`` and any iterator valid criterion:

.. code-block:: php

   <?php
   $DB->request([
      'FROM'       => 'glpi_computers',
      'INNER JOIN' => [
         'glpi_computerdisks' => [
            'FKEY' => [
               'glpi_computers'     => 'id',
               'glpi_computerdisks' => 'computer_id',
               ['OR' => ['glpi_computers.field' => ['>', 42]]]
            ]
         ]
      ]
   ]);

   // => SELECT * FROM `glpi_computers`
   //       INNER JOIN `glpi_computerdisks`
   //         ON (`glpi_computers`.`id` = `glpi_computerdisks`.`computer_id` OR 
   //              `glpi_computers`.`field` > '42'
   //            )


UNION queries
^^^^^^^^^^^^^

.. versionadded:: 9.4.0

An union query is an object, which contains an array of :ref:`sub_queries`. You just have to give a list of Subqueries
you have already prepared, or arrays of parameters that will be used to build them.

.. code-block:: php

   <?php
   $sub1 = new \QuerySubQuery([
      'SELECT' => 'field1 AS myfield',
      'FROM'   => 'table1'
   ]);
   $sub2 = new \QuerySubQuery([
      'SELECT' => 'field2 AS myfield',
      'FROM'   => 'table2'
   ]);
   $union = new \QueryUnion([$sub1, $sub2]);
   $DB->request([
      'FROM'       => $union
   ]);

   // => SELECT * FROM (
   //       SELECT `field1` AS `myfield` FROM `table1`
   //       UNION ALL
   //       SELECT `field2` AS `myfield` FROM `table2`
   //    )

As you can see on the above example, a ``UNION ALL`` query is built. If you want your results to be deduplicated,
(standard ``UNION``):

.. code-block:: php

  <?php
   //...
   //passing true as second argument will activate deduplication.
   $union = new \QueryUnion([$sub1, $sub2], true);
   //...

.. warning::

   Keep in mind that deduplicate a UNION query may have a huge cost on database server.

   Most of the time, you can issue a ``UNION ALL`` and dedup in the code.

Counting
^^^^^^^^

Using the ``COUNT`` option:

.. code-block:: php

   <?php
   $DB->request(['FROM' => 'glpi_computers', 'COUNT' => 'cpt']);
   // => SELECT COUNT(*) AS cpt FROM `glpi_computers`


Grouping
^^^^^^^^

Using the ``GROUPBY`` option, which contains a field name or an array of field names.

.. code-block:: php

   <?php
   $DB->request(['FROM' => 'glpi_computers', 'GROUPBY' => 'name']);
   // => SELECT * FROM `glpi_computers` GROUP BY `name`

Order
^^^^^

Using the ``ORDER`` option, with value a field or an array of fields. Field name can also contains ASC or DESC suffix.

.. code-block:: php

   <?php
   $DB->request(['FROM' => 'glpi_computers', 'ORDER' => 'name']);
   // => SELECT * FROM `glpi_computers` ORDER BY `name`

Request pager
^^^^^^^^^^^^^

Using the ``START`` and ``LIMIT`` options:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['START' => 5, 'LIMIT' => 10]);
   // => SELECT * FROM `glpi_computers` LIMIT 10 OFFSET 5"

.. _query_criteria:

Criteria
^^^^^^^^

Other option are considered as an array of criteria (implicit logicical ``AND``)

The ``WHERE`` can also be used for legibility.


Simple criteria
+++++++++++++++

A field name and its wanted value:

.. code-block:: php

   <?php
   $DB->request(['FROM' => 'glpi_computers', 'WHERE' => ['is_deleted' => 0]]);
   // => SELECT * FROM `glpi_computers` WHERE `is_deleted` = 0

   $DB->request(['FROM' => 'glpi_computers', 'WHERE' => ['is_deleted' => 0, 'name' => 'foo']]);
   // => SELECT * FROM `glpi_computers` WHERE `is_deleted` = 0 AND `name` = 'foo'

   $DB->request('FROM' => 'glpi_computers', 'WHERE' => ['users_id' => [1,5,7]]]);
   // => SELECT * FROM `glpi_computers` WHERE `users_id` IN (1, 5, 7)

Logical ``OR``, ``AND``, ``NOT``
++++++++++++++++++++++++++++++++

Using the ``OR``, ``AND``, or ``NOT`` option with an array of criteria:

.. code-block:: php

   <?php
   $DB->request([
       'FROM' => 'glpi_computers',
       'WHERE' => [
           'OR' => [
               'is_deleted' => 0,
               'name'       => 'foo'
           ]
       ]
    ]);
   // => SELECT * FROM `glpi_computers` WHERE (`is_deleted` = 0 OR `name` = 'foo')"

   $DB->request([
       'FROM' => 'glpi_computers',
       'WHERE' => [
           'NOT' => [
               'id' => [1,2,7]
           ]
       ]
   ]);
   // => SELECT * FROM `glpi_computers` WHERE NOT (`id` IN (1, 2, 7))


Using a more complex expression with ``AND`` and ``OR``:

.. code-block:: php

    <?php
    $DB->request([
        'FROM' => 'glpi_computers',
        'WHERE' => [
            'is_deleted' => 0,
            ['OR' => ['name' => 'foo', 'otherserial' => 'otherunique']],
            ['OR' => ['locations_id' => 1, 'serial' => 'unique']]
        ]
    ]);
    // => SELECT * FROM `glpi_computers` WHERE `is_deleted` = '0' AND ((`name` = 'foo' OR `otherserial` = 'otherunique')) AND ((`locations_id` = '1' OR `serial` = 'unique'))

Operators
+++++++++

Default operator is ``=``, but other operators can be used, by giving an array containing operator and value.

.. code-block:: php

   <?php
   $DB->request([
       'FROM' => 'glpi_computers',
       'WHERE' => [
           'date_mod' => ['>' , '2016-10-01']
       ]
   ]);
   // => SELECT * FROM `glpi_computers` WHERE `date_mod` > '2016-10-01'

   $DB->request(['FROM' => 'glpi_computers', 'WHERE' => ['name' => ['LIKE' , 'pc00%']]]);
   // => SELECT * FROM `glpi_computers` WHERE `name` LIKE 'pc00%'

Known operators are ``=``, ``!=``, ``<``, ``<=``, ``>``, ``>=``, ``LIKE``, ``REGEXP``, ``NOT LIKE``, ``NOT REGEX``, ``&`` (BITWISE AND), and ``|`` (BITWISE OR).

Aliases
+++++++

You can use SQL aliases (SQL ``AS`` keyword). To achieve that, just write the alias you want on the table name or the field name; then use it in your parameters:

.. code-block:: php

   <?php
   $DB->request(['FROM' => 'glpi_computers AS c']);
   // => SELECT * FROM `glpi_computers` AS `c`

   $DB->request(['SELECT' => 'field AS f', 'FROM' => 'glpi_computers AS c']);
   // => SELECT `field` AS `f` FROM `glpi_computers` AS `c`

Aggregate functions
+++++++++++++++++++

.. versionadded:: 9.3.1

You can use some aggregation SQL functions on fields: ``COUNT``, ``SUM``, ``AVG``, ``MIN`` and ``MAX`` are supported. Just set the function as the key in your fields array:

.. code-block:: php

   <?php
   $DB->request(['SELECT' => ['COUNT' => 'field', 'bar'], 'FROM' => 'glpi_computers', 'GROUPBY' => 'field']);
   // => SELECT COUNT(`field`), `bar` FROM `glpi_computers` GROUP BY `field`

   $DB->request(['SELECT' => ['bar', 'SUM' => 'amount AS total'], 'FROM' => 'glpi_computers', 'GROUPBY' => 'amount']);
   // => SELECT `bar`, SUM(`amount`) AS `total` FROM `glpi_computers` GROUP BY `amount`

.. _sub_queries:

Sub queries
+++++++++++

.. versionadded:: 9.3.1

You can use subqueries, using the specific `QuerySubQuery` class. It takes two arguments: the first is an array of criteria to get the query built, and the second is an optional operator to use. Allowed operators are the same than documented below plus `IN` and `NOT IN`. Default operator is `IN`.

.. code-block:: php

   <?php
   $sub_query = new \QuerySubQuery([
      'SELECT' => 'id',
      'FROM'   => 'subtable',
      'WHERE'  => [
         'subfield' => 'subvalue'
      ]
   ]);
   $DB->request(['FROM' => 'glpi_computers', 'WHERE' => ['field' => $sub_query]]);
   // => SELECT * FROM `glpi_computers` WHERE `field` IN (SELECT `id` FROM `subtable` WHERE `subfield` = 'subvalue')

   $sub_query = new \QuerySubQuery([
      'SELECT' => 'id',
      'FROM'   => 'subtable',
      'WHERE'  => [
         'subfield' => 'subvalue'
      ]
   ]);
   $DB->request(['FROM' => 'glpi_computers', 'WHERE' => ['NOT' => ['field' => $sub_query]]]);
   // => SELECT * FROM `glpi_computers` WHERE NOT `field` IN (SELECT `id` FROM `subtable` WHERE `subfield` = 'subvalue')

   $sub_query = new \QuerySubQuery([
      'SELECT' => 'id',
      'FROM'   => 'subtable',
      'WHERE'  => [
         'subfield' => 'subvalue'
      ]
   ], 'myalias');
   $DB->request(['FROM' => 'glpi_computers', 'SELECT' => [$sub_query, 'id']]);
   // => SELECT (SELECT `id` FROM `subtable` WHERE `subfield` = 'subvalue') AS `myalias`, id FROM `glpi_computers`

What if iterator does not provide what I'm looking for?
+++++++++++++++++++++++++++++++++++++++++++++++++++++++

Even if we do our best to get as many things as possible implemented in the iterator, there are several things that are missing... Consider for example you want to use the SQL `NOW()` function, or want to use a value based on another field: there is no native way to achieve that.

Right now, there is a `QueryExpression` class that would permit to do such things on values (an not on fields since it is not possible to use a class instance as an array key).

.. warning::

   The `QueryExpression` class will pass raw SQL. You are in charge to escape name and values you use into it!

For example, to use the SQL `NOW()` function:

.. code-block:: php

   <?php
   $DB->request([
      'FROM'   => 'my_table',
      'WHERE'  => [
         'date_end'  => ['>', new \QueryExpression('NOW()')]
      ]
   ]);
   // SELECT * FROM `my_table` WHERE `date_end` > NOW()

Another example with a field value:

.. code-block:: php

   <?php
   $DB->request([
      'FROM'   => 'my_table',
      'WHERE'  => [
         'field'  => new \QueryExpression(DBmysql::quoteName('other_field'))
      ]
   ]);
   // SELECT * FROM `my_table` WHERE `field` = `other_field`

.. versionadded:: 9.3.1

You can also use some function or non supported stuff on field part by using a `RAW` entry in the query:

.. code-block:: php

   <?php
   $DB->request([
      'FROM'   => 'my_table',
      'WHERE'  => [
        'RAW'  => [
            'LOWER(' . DBmysql::quoteName('field') . ')' => strtolower('Value')
        ]
      ]
   ]);
   // SELECT * FROM `my_table` WHERE LOWER(`field`) = 'value'

.. versionadded:: 9.5.0

You can use a QueryExpression object in the FIELDS statement:

.. code-block:: php

   <?php
   $DB->request([
      'FIELDS'    => [
         'glpi_computers' => ['id'],
         new QueryExpression("CONCAT(`glpi_computers`.`name`, '.', `glpi_domains`.`name`) AS `fullname`")
      ],
      'FROM'      => 'glpi_computers',
      'LEFT JOIN' => [
         'glpi_domains' => [
            'FKEY' => [
               'glpi_computers' => 'domains_id',
               'glpi_domains' => 'id',
            ]
         ]
      ]
   ]);
   // => SELECT `glpi_computers`.`id`, CONCAT(`glpi_computers`.`name`, '.', `glpi_domains`.`name`) AS `fullname` FROM `glpi_computers` LEFT JOIN `glpi_domains` ON (`glpi_computers`.`domains_id` = `glpi_domains`.`id`)

You can use a QueryExpression object in the FROM statement:

.. code-block:: php

   <?php
   $DB->request([
      'FROM'      => new QueryExpression('(SELECT * FROM glpi_computers) as computers'),
   ]);
   // => SELECT * FROM (SELECT * FROM glpi_computers) as computers
