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

Arrays
------

Arrays must be declared using the short notation syntax (``[]``), long notation (``array()``) is forbidden.

true, false and null
--------------------

``true``, ``false`` and ``null`` constants mut be lowercase.

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

The PHP closing tag ``?>`` must be avoided on full PHP files (so in most of GLPI's files!).

Functions
---------

Function names must be written in *camelCaps*:

.. code-block:: php

   <?php
   function userName($a, $b = 'foo') {
      //do something here!
   }

Space after opening parenthesis and before closing parenthesis are forbidden. For parematers which have a default value; add a space before and after the equel sign.

If parameters add block doc for these parameters, please see the `Comments`_ section for any example.

If function from parent add

.. code-block:: php

   <?php
   function getMenuContent()

If it's a new function, add in block doc (see the `Comments`_ section):

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

Static or Non static?
^^^^^^^^^^^^^^^^^^^^^

Some methods in the source code as `declared as static <http://php.net/manual/fr/language.oop5.static.php>`_; some are not.

For sure, you cannot make static calls on a non static method. In order to call such a method, you will have to get an object instance, and the call the method on it:

.. code-block:: php

   <?php

   $object = new MyObject();
   $object->nonStaticMethod();

It may be different calling static classes. In that case; you can either:

* call statically the method from the object; like ``MyObject::staticMethod()``,
* call statically the method from an object instance; like ``$object::staticMethod()``,
* call non statically the method from an object instance; like ``$object->staticMethod()``.
* use `late static building <http://php.net/manual/en/language.oop5.late-static-bindings.php>`_; like ``static::staticMethod()``.

When you do not have any object instance yet; the first solution is probably the best one. No need to instanciate an object to just call a static method from it.

On the other hand; if you already have an object instance; you should better use any of the solution but the late static binding. That way; you will save performances since this way to go do have a cost.

Classes
-------

Class names must be written in `CamelCase`:

GLPI do not use `PHP namespaces <http://php.net/manual/en/language.namespaces.php>`_ right now; so be careful when creating new classes to take a name that does not exists yet.

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

To be more visible, don't put inline block comments into ``/* */`` but comment each line with ``//``. Put docblocks comments into ``/** */``.

Each function or method must be documented, as well as all its parameters (see `Variables types`_ below), and its return.

For each method or function documentation, you'll need at least to have a description, the version it was introduced, the parameters list, the return type; each blocks separated with a blank line. As an example, for a void function:

.. code-block:: php

   <?php
   /**
    * Describe what the method does. Be concise :)
    *
    * You may want to add some more words about what the function
    * does, if needed. This is optionnal, but you can be more
    * descriptive here:
    * - it does something
    * - and also something else
    * - but it doesn't make coffee, unfortunately.
    *
    * @since 9.2
    *
    * @param string  $param       A parameter, for something
    * @param boolean $other_param Another parameter
    *
    * @return void
    */
   function myMethod($param, $other_param) {
      //[...]
   }

Some other informations way be added; if the function requires it.

Refer to the `PHPDocumentor website <https://phpdoc.org/docs/latest>`_ to get more informations on documentation. The `latest GLPI API documentation <https://forge.glpi-project.org/projects/glpi/embedded/index.html>`_ is also available online.

Please follow the order defined below:

 #. Description,
 #. Long description, if any,
 #. `@deprecated`.
 #. `@since`,
 #. `@var`,
 #. `@param`,
 #. `@return`,
 #. `@see`,
 #. `@throw`,
 #. `@todo`,

Parameters documentation
^^^^^^^^^^^^^^^^^^^^^^^^

Each parameter must be documented in its own line, begining with the ``@param`` tag, followed by the `Variables types`_, followed by the param name (``$param``), and finally with the description itself.
If your parameter can be of different types, you can list them separated with a ``|`` or you can use the ``mixed`` type; it's up to you!

All parameters names and description must be aligned vertically on the longest (plu one character); see the above example.

Override method: @inheritDoc? @see? docblock? no docblock?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There are many question regarding the way to document a child method in a child class.

Many editors use the ``{@inheritDoc}`` tag without anything else. **This is wrong**. This *inline* tag is confusing for many users; for more details, see the `PHPDocumentor documentation about it <https://www.phpdoc.org/docs/latest/guides/inheritance.html#the-inheritdoc-tag>`_.
This tag usage is not forbidden, but make sure to use it properly, or just avoid it. An usage exemple:

.. code-block:: php

   <?php

   abstract class MyClass {
      /**
       * This is the documentation block for the curent method.
       * It does something.
       *
       * @param string $sthing Something to send to the method
       *
       * @return string
       */
      abstract public function myMethod($sthing);
   }

   class MyChildClass extends MyClass {
      /**
       * {@inheritDoc} Something is done differently for a reason.
       *
       * @param string $sthing Something to send to the method
       *
       * @return string
       */
      public function myMethod($sthing) {
         [...]
      }

Something we can see quite often is just the usage of the ``@see`` tag to make reference to the parent method. **This is wrong**. The ``@see`` tag is designed to reference another method that would help to understand this one; not to make a reference to its parent (you can also take a look at `PHPDocumentor documentation about it <https://www.phpdoc.org/docs/latest/references/phpdoc/tags/see.html>`_. While generating, parent class and methods are automaticaly discovered; a link to the parent will be automatically added.
An usage example:

.. code-block:: php

   <?php
   /**
    * Adds something
    *
    * @param string $type  Type of thing
    * @param string $value The value
    *
    * @return boolean
    */
   public function add($type, $value) {
      // [...]
   }

   /**
    * Adds myType entry
    *
    * @param string $value The value
    *
    * @return boolean
    * @see add()
    */
   public function addMyType($value) {
      return $this->addType('myType', $value);
   }

Finally, should I add a docblock, or nothing?

PHPDocumentor and various tools will just use parent docblock verbatim if nothing is specified on child methods. So, if the child method acts just as its parent (extending an abstract class, or some super class like ``CommonGLPI`` or ``CommonDBTM``); you may just omit the docblock entirely. The alternative is to copy paste parent docblock entirely; but that way, it would be required to change all children docblocks when parent if changed.

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


Quotes / double quotes
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
* Indentation: 3 spaces

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

   phpcs --standard=vendor/glpi-project/coding-standard/GlpiStandard/ inc/ front/ ajax/ tests/

If the above command does not provide any output, then, all is OK :)

An example error output would looks like:

.. code-block:: bash

   phpcs --standard=vendor/glpi-project/coding-standard/GlpiStandard/ inc/ front/ ajax/ tests/
   
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
