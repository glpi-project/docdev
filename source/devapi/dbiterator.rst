DBIterator
----------

Goals
^^^^^

Provide a simple request generator:

* without having to write SQL
* without having to quote table and field name
* without having to take care of freeing resources
* iteratable

Basic usage
^^^^^^^^^^^

.. code-block:: php

   <?php
   foreach ($DB->request(...) as $id => $row) {
      //... work on 1 row ...
   }

Arguments
^^^^^^^^^

The ``request`` method takes two arguments:

* `table name(s)`: a `string` or an `array` of `string`
* `option(s)`: `array` of options


Without option
^^^^^^^^^^^^^^

In this case, all the data from the selected table is iterated:

.. code-block:: php

   <?php
   $DB->request('glpi_computers');
   // => SELECT * FROM `glpi_computers`

Fields selection
^^^^^^^^^^^^^^^^

Using the ``FIELDS`` or ``DISTINCT FIELDS`` option

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['FIELDS' => 'id']);
   // => SELECT `id` FROM `glpi_computers`

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
   $DB->request('glpi_computers', 
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

Request pager
^^^^^^^^^^^^^

Using the ``START`` and ``LIMIT`` options:

.. code-block:: php

   <?php
   $DB->request('glpi_computers', ['START' => 5, 'LIMIT' => 10]);
   // => SELECT * FROM `glpi_computers` LIMIT 10 OFFSET 5"

Criteria
^^^^^^^^

Other option are considered as an array of critiria (implicit logicical ``AND``)

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
