Translations
------------

Main GLPI language is british english (en_GB). All string in the source code must be in english, and marked as translatable, using some convenient functions.

Since 0.84; GLPI uses `gettext <https://www.gnu.org/software/gettext/>`_ for localization; and `Transifex <https://www.transifex.com/glpi/GLPI/dashboard/>`_ is used for translations. If you want to help translating GLPI, please register on transifex and join our `translation mailing list <https://mail.gna.org/listinfo/glpi-translation>`_

What the system is capable to do:

* replace variables (on LTR and RTL languages),
* manage plural forms,
* add context informations,
* ...

Here is the workflow used for translations:

#. Developers add string in the source code,
#. String are extracted to POT file,
#. POT file is sent to Transifex,
#. Translators translate,
#. Developers pull new translations from Transifex,
#. MO files used by GLPI are generated.

Functions
^^^^^^^^^

There are several standard functions you will have to use in order to get translations. Remember the tranlsation domain will be `glpi` if not defined; so, for plugins specific translations, do not forget to set it!

.. note::

   All translations functions take a ``$domain`` as argument; it defaults to ``glpi`` and must be changed when you are working on a plugin.

Simple translation
++++++++++++++++++

When you have a "simple" string to translate, you may use several functions, depending on the particular use case:


* ``__($str, $domain='glpi')`` (what you will probably use the most frequently): just translate a string,
* ``_x($ctx, $str, $domain='glpi')``: same as ``__()`` but provide an extra context,
* ``__s($str, $domain='glpi')``: same as ``__()`` but escape HTML entities,
* ``_sx($ctx, $str, $domain='glpi')``: same as ``__()`` but provide an extra context and escape HTML entities,

Handle plural forms
+++++++++++++++++++

When you have a string to translate, but which rely on a count or something. You may as well use several functions, depending on the particular use case:

* ``_n($sing, $plural, $nb, $domain='glpi')`` (what you will probably use the most frequently): give a string for singular form, another for plural form, and set current "count",
* ``_sn($str, $domain='glpi')``: same as ``_n()`` but escape HTML entities,
* ``_nx($ctx, $str, $domain='glpi')``: same as ``_n()`` but provide an extra context,

Handle variables
++++++++++++++++

You may want to replace some parts of translations; for some reason. Let's say you would like to display current page on a total number of pages; you will use the `sprintf <http://php.net/manual/fr/function.sprintf.php>`_ method. This will allow you to make replacements; but without relying on arguments positions. For example:

.. code-block:: php

   <?php
   $pages = 20;  //total number of pages
   $current = 2; //current page
   $string = sprintf(
      __('Page %1$s on %2$s'),
      $pages,
      $total
   );
   echo $string; //will display: "Page 2 on 20"

In the above example, ``%1$s`` will always be replaced by ``2``; even if places has been changed in some translations.

.. warning::

   You may sometimes see the use of ``printf()`` which is an equivalent that directly output (echo) the result. This should be avoided!
