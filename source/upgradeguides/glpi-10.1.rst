Upgrade to GLPI 10.1
--------------------

Removal of input variables auto-sanitize
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Prior to GLPI 10.1, PHP superglobals ``$_GET``, ``$_POST`` and ``$_REQUEST`` were automatically sanitized.
It means that SQL special characters were escaped (prefixed by a ``\``), and HTML special characters ``<``, ``>`` and ``&`` were encoded into HTML entities.
This caused issues because it was difficult, for some pieces of code, to know if the received variables were "secure" or not.

In GLPI 10.1, we removed this auto-sanitization, and any data, whether it comes from a form, the database, or the API, will always be in its raw state.

Protection against SQL injection
++++++++++++++++++++++++++++++++

Protection against SQL injection is now automatically done when DB query is crafted.

All the ``addslashes()`` usages that were used for this purpose have to be removed from your code.

.. code-block:: diff

   - $item->add(Toolbox::addslashes_deep($properties));
   + $item->add($properties);

Protection against XSS
++++++++++++++++++++++

HTML special characters are no longer encoded automatically. Even existing data will be seamlessly decoded when it will be fetched from database.
Code must be updated to ensure that all dynamic variables are correctly escaped in HTML views.

Views built with ``Twig`` templates no longer require usage of the ``|verbatim_value`` filter to correctly display HTML special characters.
Also, Twig automatically escapes special characters, which protects against XSS.

.. code-block:: diff

   - <p>{{ content|verbatim_value }}</p>
   + <p>{{ content }}</p>

Code that outputs HTML code directly must be adapted to use the ``htmlspecialchars()`` function.

.. code-block:: diff

   - echo '<p>' . $content . '</p>';
   + echo '<p>' . htmlspecialchars($content) . '</p>';

Also, code that ouputs javascript must be adapted to prevent XSS with both HTML special characters and quotes.

.. code-block:: diff

   echo '
       <script>
   -        $(body).append('<p>' . $content . '</p>');
   +        $(body).append(json_encode('<p>' . htmlspecialchars($content) . '</p>'));
       </script>
   ';

Query builder usage
+++++++++++++++++++

Since it has been implemented, internal query builder (named `DBMysqlIterator`) do accept several syntaxes; that make things complex:

1. conditions (including table name as `FROM` array key) as first (and only) parameter.
2. table name as first parameter and condition as second parameter,
3. raw SQL queries,

The most used and easiest to maintain was the first. The second has been deprecated and the thrird has been prohibited or security reasons.

I you were using the second syntax, you will need to replace as follows:

.. code-block:: diff

   - $iterator = $DB->request('mytable', ['field' => 'condition']);
   + $iterator = $DB->request(['FROM' => 'mytable', 'WHERE' => ['field' => 'condition']]);

Using raw SQL queries must be replaced with query builder call, among other to prevent syntax issues, and SQL injections; please refer to :doc:devapi/database/dbiterator.
