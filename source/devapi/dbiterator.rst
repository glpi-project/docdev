DBIterator
----------

Goals
^^^^^

Provide a simple request generator:

* without having to write SQL
* without having to quote table and field name
* without having to take care of freeing resources
* iterable

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

Arguments
^^^^^^^^^

The ``request`` method takes two arguments:

* `table name(s)`: a `string` or an `array` of `string`
  (optional when given as ``FROM`` option)
* `option(s)`: `array` of options


Giving full SQL statement
^^^^^^^^^^^^^^^^^^^^^^^^^

If the only option is a full SQL statement, it will be used.
This usage is deprecated, and should be avoid when possible.

Without option
^^^^^^^^^^^^^^

In this case, all the data from the selected table is iterated:

.. code-block:: php

   <?php
   $DB->request([FROM => 'glpi_computers']);
   // => SELECT * FROM `glpi_computers`

   $DB->request('glpi_computers');
   // => SELECT * FROM `glpi_computers`

Fields selection
^^^^^^^^^^^^^^^^

Using one of the ``SELECT``, ``FIELDS``, ``DISTINCT FIELDS``
or ``SELECT DISTINCT`` options

.. code-block:: php

   <?php
   $DB->request(['SELECT' => 'id', 'FROM' => 'glpi_computers']);
   // => SELECT `id` FROM `glpi_computers`

   $DB->request('glpi_computers', ['FIELDS' => 'id']);
   // => SELECT `id` FROM `glpi_computers`

   $DB->request(['SELECT DISTINCT' => 'id', 'FROM' => 'glpi_computers']);
   // => SELECT DISTINCT `name` FROM `glpi_computers`

   $DB->request('glpi_computers', ['DISTINCT FIELDS' => 'name']);
   // => SELECT DISTINCT `name` FROM `glpi_computers`

The fields array can also contain per table sub-array:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['FIELDS' => ['glpi_computers' => ['id', 'name']]]);
   // => SELECT `glpi_computers`.`id`, `glpi_computers`.`name` FROM `glpi_computers`"

Multiple tables, native join
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You need to use criteria, usually a ``FKEY``, to describe howto join the tables:

.. code-block:: php

   <?php
   $DB->request(['FROM' => ['glpi_computers', 'glpi_computerdisks'],
                 'FKEY' => ['glpi_computers'=>'id',
                            'glpi_computerdisks'=>'computer_id']]);
   $DB->request(['glpi_computers', 'glpi_computerdisks'],
                ['FKEY' => ['glpi_computers'=>'id',
                            'glpi_computerdisks'=>'computer_id']]);
   // => SELECT * FROM `glpi_computers`, `glpi_computerdisks`
   //       WHERE `glpi_computers`.`id` = `glpi_computerdisks`.`computer_id`

Left join
^^^^^^^^^

Using the ``JOIN`` option, with some criteria, usually a ``FKEY``:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', 
                ['JOIN' => ['glpi_computerdisks' => ['FKEY' => ['glpi_computers'=>'id', 
                                                                'glpi_computerdisks'=>'computer_id']]]]);
   // => SELECT * FROM `glpi_computers`
   //       LEFT JOIN `glpi_computerdisks`
   //         ON (`glpi_computers`.`id` = `glpi_computerdisks`.`computer_id`)

Counting
^^^^^^^^

Using the ``COUNT`` option:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['COUNT' => 'cpt']);
   // => SELECT COUNT(*) AS cpt FROM `glpi_computers`

Order
^^^^^

Using the ``ORDER`` option, with value a field or an array of field. Field name can also contains ASC or DESC suffix.

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['ORDER' => 'name']);
   // => SELECT * FROM `glpi_computers` ORDER BY `name`

   $DB->request('glpi_computers', ['ORDER' => ['date_mod DESC', 'name ASC']]);
   // => SELECT * FROM `glpi_computers` ORDER BY `date_mod` DESC, `name` ASC

Request pager
^^^^^^^^^^^^^

Using the ``START`` and ``LIMIT`` options:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['START' => 5, 'LIMIT' => 10]);
   // => SELECT * FROM `glpi_computers` LIMIT 10 OFFSET 5"

Criteria
^^^^^^^^

Other option are considered as an array of criteria (implicit logicical ``AND``)

Simple criteria
+++++++++++++++

A field name and its wanted value:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['is_deleted' => 0]);
   // => SELECT * FROM `glpi_computers` WHERE `is_deleted` = 0

   $DB->request('glpi_computers', ['is_deleted' => 0
                                   'name'       => 'foo']);
   // => SELECT * FROM `glpi_computers` WHERE `is_deleted` = 0 AND `name` = 'foo'

   $DB->request('glpi_computers', ['users_id' => [1,5,7]]);
   // => SELECT * FROM `glpi_computers` WHERE `users_id` IN (1, 5, 7)

Logical ``OR``, ``AND``, ``NOT``
++++++++++++++++++++++++++++++++

Using the ``OR``, ``AND``, or ``NOT`` option with an array of criteria:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['OR' => ['is_deleted' => 0,
                                            'name'       => 'foo']]);
   // => SELECT * FROM `glpi_computers` WHERE (`is_deleted` = 0 OR `name` = 'foo')"

   $DB->request('glpi_computers', ['NOT' => ['id' => [1,2,7]]]);
   // => SELECT * FROM `glpi_computers` WHERE NOT (`id` IN (1, 2, 7))

Operators
+++++++++

Default operator is ``=``, but other operators can be used, by giving an array containing operator and value.

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['date_mod' => ['>' , '2016-10-01']]);
   // => SELECT * FROM `glpi_computers` WHERE `date_mod` > '2016-10-01'

   $DB->request('glpi_computers', ['name' => ['LIKE' , 'pc00%']]);
   // => SELECT * FROM `glpi_computers` WHERE `name` LIKE 'pc00%'

Know operators are ``=``, ``<``, ``<=``, ``>``, ``>=``, ``LIKE``, ``REGEXP``, ``NOT LIKE`` and ``NOT REGEX``.

