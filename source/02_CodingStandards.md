Coding standards
================

Indentation
-----------

- 3 spaces
- Max line width: 100

```
<?php
// base level
    // level 1
        // level 2
    // level 1
// base level
```

Control structures
------------------

Multiple conditions in several idented lines

```php
<?php
if ($test1) {
   for ($i=0 ; $i<$end ; $i++) {
      echo "test ".( $i<10 ? "0$i" : $i )."<br>";
   }
}

if ($a==$b
   || ($c==$d && $e==$f)) {
  ...
} elseif {
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
```

Including files
---------------

Use `include_once` in order to include the file once and to raise warning if file does not exists:
```
include_once(GLPI_ROOT."/inc/includes.php");
```


PHP tags
--------

Short tag (`<?`) is not allowed; use complete tags (`<?php`).

```
<?php

// code
```

Functions
---------

Function names must be written in `camelCaps`:

```
<?php
function userName($a, $b) {
   //do something here!
}
```

### Call static methods

If the static function is:
- in the class itself => `self::theMethod()`
- in parent class => `parent::theMethod()`
- in another class => `ClassName::theMethod()`


Classes
-------

Class names must be written in `CamelCase`:

GLPi do not use [namespaces](http://php.net/manual/en/language.namespaces.php) right now; so be carefull when creating new classes to take a name that does not exists yet.

```
<?php
class MyExampleClass estends AnotherClass {
   // do something
}
```

Note: even if GLPi does not use namespaces, some libs does, you'll have to take care of that. You can also if you wish use namespaces for PHP objects call.

For example, the folloging code:
```
   try {
      ...
      $something = new stdClass();
      ...
   } catch (Exception $e{
      ...
   }
```

Could also be written as (see the `\`):
```
   try {
      ...
      $something = new \stdClass();
      ...
   } catch (\Exception $e{
      ...
   }
```

Variables and Constants
-----------------------

* Variable names must be as descriptive and as short as possible, stay clear and concise.
* In case of multiple words, use the `_` separator,
* Variables must be **lower case**,
* Global variables and constants must be **UPPER case**.

Example:
```
<?php
$user         = 'glpi';
$users        = array('glpi', 'glpi2', 'glpi3'); // put elements in alphabetic order
$users        = array(
   'glpi1'  => 'valeur1',
   'nexglpi => array(
      'down' => '1',
      'up'   => array(
         'firstfield' => 'newvalue
      )
   ),
   'glpi2   => 'valeur2'
);
$users_groups = array('glpi', 'glpi2', 'glpi3');

$CFG_GLPI = array();
```
Comments
--------

To be more visible, don't put inline block comments into `/* */` but comment each line with `//`.

Each function or method must be documented, as well as all its parameters (see variables types below), and its return.


 Variables types
----------------

Variables types for use in DocBlocks for Doxygen:

 Type     | Description
--------- | -------------------------------------------------------
mixed     | A variable with undefined (or multiple) type
integer   | Integer type variable (whole number)
float     | Float type (point number)
boolean   | Logical type (true or false)
string    | String type (any value in "" or ' ')
array     | Array type
object    | Object type
ressource | Resource type (as returned from `mysql_connect` function)

Inserting comment in source code for doxygen.
Result : full doc for variables, functions, classes...


quotes / double quotes
----------------------

* You must use single quotes for indexes, constants declaration, translations, ...
* Use double quote in translated strings
* When you have to use tabulation character (`\t`), carriage return (`\n`) and so on, you should use double quotes.
* For performances reasons since PHP7, you may avoid strings concatenation.

Examples:
```
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
   case 'foo': //use single quote here
      ...
   case 'bar:
      ...
}
```

Files
-----

* Name in lower case.
* Maximum line length: 100 characters

Database queries
----------------

* Queries must be written onto several lines, one statement item by line.
* All SQL words must be **UPPER case**.
* For MySQL, all item based must be slash protected (table name, field name, condition),
* All values from variable, even integer should be single quoted

```
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
```
