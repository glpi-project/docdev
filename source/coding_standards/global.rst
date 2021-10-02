Global Coding standards
=======================

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

true, false and null
--------------------

``true``, ``false`` and ``null`` constants mut be lowercase.

Variables and Constants
-----------------------

* Variable names must be as descriptive and as short as possible, stay clear and concise.
* In case of multiple words, use the ``_`` separator,
* Variables must be **lower case**,
* Global PHP variables and constants must be **UPPER case**.

.. code-block:: php

   <?php
   $user         = 'glpi';
   // put elements in alphabetic order
   $users        = ['glpi', 'glpi2', 'glpi3'];
   $users        = ['glpi1'   => 'valeur1',
                         'nexglpi' => ['down' => '1',
                                            'up'   => ['firstfield' => 'newvalue']],
                         'glpi2'   => 'valeur2'];
   $users_groups = ['glpi', 'glpi2', 'glpi3'];
   
   $CFG_GLPI = [];
