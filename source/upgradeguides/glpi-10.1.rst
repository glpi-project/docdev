Upgrade to GLPI 10.1
--------------------

Removal of input variable auto-sanitize
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Prior to GLPI 10.1, PHP superglobals ``$_GET``, ``$_POST`` and ``$_REQUEST`` were auto-sanitized:
 - all SQL special chars were escaped (prefixed by a ``\``),
 - HTML special chars ``<``, ``>`` and ``&`` were encoded into HTML entities.
This caused issues because it was difficult, for some pieces of code, to know if the received variables were "secure" or not.

In GLPI 10.1, we removed this auto-sanitization, and any data, whether it comes from a form, the database, or the API, will always be in its raw state.

Protection against SQL injection
++++++++++++++++++++++++++++++++

Protection against SQL injection is now automatically done when DB query is crafted. As soon as you use ``DBmysql::request()``,
 ``DBmysql::insert()``, ``DBmysql::update()`` or, ``DBmysql::delete()``, you do not have to escape passed values.

TODO: give an example of addslashes removal

Protection against XSS
++++++++++++++++++++++

HTML special chars are no longer encoded. Even existing data will be automatically decoded when it will be fetched from database.
You have to ensure that all dynamic variables are correctly escaped in your plugin views.

TODO: give an example of |verbatim_value removal in Twig
TODO: give an example of htmlspecialchars with echo
TODO: give an example of json_encode with javascript
