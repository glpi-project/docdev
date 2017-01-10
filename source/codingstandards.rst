Coding standards
================

Indentation
-----------

- 3 spaces
- Max line width: 100

.. code-block:: php

   <?php
   // base level
       // level 1
           // level 2
       // level 1
   // base level

Spacing
-------

We've adopted "french spacing" rules in the code. The rule is:

* for *simple* punctuation (``,``, ``.``): use *one space after* the punctuation sign
* for *double* punctuation (``!``, ``?``, ``:``): use *one space after and one space before* the punctuation sign
* for *opening* punctuation (``(``, ``{``, ``[``): use *one space before* the punctuation sign
* for *closing* punctuation ( ``)``, ``}``, ``]``): use *one space after* the punctuation sign, excepted for line end, when followed by a semi-colon (``;``)

Of course, this rules only aplies on the source code, not on the strings (translatable strings, comments, ...)!

Control structures
------------------

Multiple conditions in several idented lines

.. code-block:: php

   <?php
   if ($test1) {
      for ($i=0 ; $i<$end ; $i++) {
         echo "test ".( $i<10 ? "0$i" : $i )."<br>";
      }
   }
   
   if ($a==$b
      || ($c==$d && $e==$f)) {
     ...
   } else if {
     ...
   }
   
   switch ($test2) {
      case 1 :
         echo "Case 1";
         break;
   
      case 2 :
         echo "Case 2";
         // No break here : because...
   
      default :
         echo "Default Case";
   }


Including files
---------------

Use ``include_once`` in order to include the file once and to raise warning if file does not exists:

.. code-block:: php

   include_once GLPI_ROOT."/inc/includes.php";


PHP tags
--------

Short tag (``<?``) is not allowed; use complete tags (``<?php``).

.. code-block:: php

   <?php
   // code

The PHP closing tag ``?>`` must be avoided on full PHP files (so, it must be in most of GLPI's files!).

Functions
---------

Function names must be written in *camelCaps*:

.. code-block:: php

   <?php
   function userName($a, $b) {
      //do something here!
   }

If parameters add block doc for these parameters.

.. code-block:: php

   <?php
   /**
    * decribe utility of the function
    *
    * @param $a      type(integer, array...)    utility of the param
    * @param $b      type(integer, array...)    utility of the param
    *
    * $return of the funtion (boolean, array...)
    *
   **/
   function userName($a, $b) {

If function from parent add

.. code-block:: php

   <?php
   /**
    * @see CommonGLPI::getMenuContent()
   **/
   function getMenuContent()

If it's a new function, add in block doc:

.. code-block:: php

   @since version 9.1

Call static methods
^^^^^^^^^^^^^^^^^^^

================= ===========
Function location How to call
================= ===========
class itself      ``self::theMethod()``
parent class      ``parent::theMethod()``
another class     ``ClassName::theMethod()``
================= ===========

Classes
-------

Class names must be written in `CamelCase`:

GLPI do not use `PHP namespaces <http://php.net/manual/en/language.namespaces.php>`_ right now; so be carefull when creating new classes to take a name that does not exists yet.

.. code-block:: php

   <?php
   class MyExampleClass estends AnotherClass {
      // do something
   }


Note: even if GLPI does not use namespaces, some libs does, you will have to take care of that. You can also if you wish use namespaces for PHP objects call.

For example, the folloging code:

.. code-block:: php

   <?php
   try {
      ...
      $something = new stdClass();
      ...
   } catch (Exception $e{
      ...
   }


Could also be written as (see the ``\``):

.. code-block:: php

   <?php
   try {
      ...
      $something = new \stdClass();
      ...
   } catch (\Exception $e{
      ...
   }

Variables and Constants
-----------------------

* Variable names must be as descriptive and as short as possible, stay clear and concise.
* In case of multiple words, use the ``_`` separator,
* Variables must be **lower case**,
* Global variables and constants must be **UPPER case**.

.. code-block:: php

   <?php
   $user         = 'glpi';
   // put elements in alphabetic order
   $users        = array('glpi', 'glpi2', 'glpi3');
   $users        = array('glpi1'   => 'valeur1',
                         'nexglpi' => array('down' => '1',
                                            'up'   => array('firstfield' => 'newvalue')),
                         'glpi2'   => 'valeur2');
   $users_groups = array('glpi', 'glpi2', 'glpi3');
   
   $CFG_GLPI = array();

Comments
--------

To be more visible, don't put inline block comments into ``/* */`` but comment each line with ``//``.

Each function or method must be documented, as well as all its parameters (see variables types below), and its return.


Variables types
---------------

Variables types for use in DocBlocks for Doxygen:

========= ===========
 Type     Description
========= ===========
mixed     A variable with undefined (or multiple) type
integer   Integer type variable (whole number)
float     Float type (point number)
boolean   Logical type (true or false)
string    String type (any value in ``""`` or ``' '``)
array     Array type
object    Object type
ressource Resource type (as returned from ``mysql_connect`` function)
========= ===========

Inserting comment in source code for doxygen.
Result : full doc for variables, functions, classes...


quotes / double quotes
----------------------

* You must use single quotes for indexes, constants declaration, translations, ...
* Use double quote in translated strings
* When you have to use tabulation character (``\t``), carriage return (``\n``) and so on, you should use double quotes.
* For performances reasons since PHP7, you may avoid strings concatenation.

Examples:

.. code-block:: php

   <?php
   //for that one, you should use double, but this is at your option...
   $a = "foo";
   
   //use double quotes here, for $foo to be interpreted
   //   => with double quotes, $a will be "Hello bar" if $foo = 'bar'
   //   => with single quotes, $a will be "Hello $foo"
   $a = "Hello $foo";
   
   //use single quotes for array keys
   $tab = [
      'lastname'  => 'john',
      'firstname' => 'doe'
   ];
   
   //Do not use concatenation to optimize PHP7
   //note that you cannot use functions call in {}
   $a = "Hello {$tab['firstname']}";
   
   //single quote translations
   $str = __('My string to translate');
   
   //Double quote for special characters
   $html = "<p>One paragraph</p>\n<p>Another one</p>";
   
   //single quote cases
   switch ($a) {
      case 'foo' : //use single quote here
         ...
      case 'bar' :
         ...
   }


Files
-----

* Name in lower case.
* Maximum line length: 100 characters
* Indenttion: 3 spaces

Database queries
----------------

* Queries must be written onto several lines, one statement item by line.
* All SQL words must be **UPPER case**.
* For MySQL, all item based must be slash protected (table name, field name, condition),
* All values from variable, even integer should be single quoted

.. code-block:: php

   <?php
   $query = "SELECT *
             FROM `glpi_computers`
             LEFT JOIN `xyzt` ON (`glpi_computers`.`fk_xyzt` = `xyzt`.`id`
                                  AND `xyzt`.`toto` = 'jk')
             WHERE @id@ = '32'
                   AND ( `glpi_computers`.`name` LIKE '%toto%'
                         OR `glpi_computers`.`name` LIKE '%tata%' )
             ORDER BY `glpi_computers`.`date_mod` ASC
             LIMIT 1";
   
   $query = "INSERT INTO `glpi_alerts`
                   (`itemtype`, `items_id`, `type`, `date`) // put field's names to avoid mistakes when names of fields change
             VALUE ('contract', '5', '2', NOW())";

Checking standards
------------------

In order to check some stabdards are respected, we provide some custom `PHP CodeSniffer <http://pear.php.net/package/PHP_CodeSniffer>`_ rules. From the GLPI directory, just run:

.. code-block:: bash

   phpcs --standard=tools/phpcs-rules.xml inc/ front/ ajax/ tests/

If the above command does not provide any output, then, all is OK :)

An example error output would looks like:

.. code-block:: bash

   phpcs --standard=tools/phpcs-rules.xml inc/ front/ ajax/ tests/
   
   FILE: /var/www/webapps/glpi/tests/HtmlTest.php
   ----------------------------------------------------------------------
   FOUND 3 ERRORS AFFECTING 3 LINES
   ----------------------------------------------------------------------
    40 | ERROR | [x] Line indented incorrectly; expected 3 spaces, found
       |       |     4
    59 | ERROR | [x] Line indented incorrectly; expected 3 spaces, found
       |       |     4
    64 | ERROR | [x] Line indented incorrectly; expected 3 spaces, found
       |       |     4
