Right Management
----------------

Goals
^^^^^

Provide a way for administrator to segment usages into profiles of users.


Profiles
^^^^^^^^

The `Profile class <https://forge.glpi-project.org/apidoc/class-Profile.html>`_ (corresponding to ``glpi_profiles`` table) stores each set of rights.

A profile have a set of base fields independent of sub rights and, so, could:
- be defined as default for new users (``is_default`` field).
- force the ticket creation form at the login (``create_ticket_on_login`` field).
- define the interface used (``interface`` field):
   - helpdesk (self-service users)
   - central (technician view)


Rights definition
^^^^^^^^^^^^^^^^^

They are defined by the `ProfileRight class <https://forge.glpi-project.org/apidoc/class-ProfileRight.html>`_ (corresponding to ``glpi_profilerights`` table)

Each consists of:
- a profile foreign key (``profiles_id`` field)
- a key (``name`` field)
- a value (``right`` field)

The keys match the static property ``$rightname`` in the GLPI itemtypes.
Ex: In Computer class, we have a ``static $rightname = 'computer';``

Value is a numeric sum of integer constants.
Bases right values can be in inc/define.php:

.. code-block:: php

   <?php

   ...

   define("READ", 1);
   define("UPDATE", 2);
   define("CREATE", 4);
   define("DELETE", 8);
   define("PURGE", 16);
   define("ALLSTANDARDRIGHT", 31);
   define("READNOTE", 32);
   define("UPDATENOTE", 64);
   define("UNLOCK", 128);

So, for example, to have the right to READ and UPDATE an itemtype, we'll have a ``right`` value of 3.
As defined in this above block, we have a computation of all standards right = 31:

READ (1)
\+ UPDATE (2)
\+ CREATE (4)
\+ DELETE (8)
\+ PURGE (16)
= 31

If you need to extends the possible values of rights, you need to declare theses part into your itemtype, simplified example for Ticket class:

.. code-block:: php

   <?php

   class Ticket extends CommonITILObject {

      ...

      const READALL          =   1024;
      const READGROUP        =   2048;

      ...

      function getRights($interface = 'central') {
         $values = parent::getRights();

         $values[self::READGROUP]  = array('short' => __('See group ticket'),
                                           'long'  => __('See tickets created by my groups'));

         $values[self::READASSIGN] = array('short' => __('See assigned'),
                                           'long'  => __('See assigned tickets'));

         return $values;
      }

      ...

The new rights need to be checked by your own functions, see checkrights__


Check rights
^^^^^^^^^^^^

Each itemtype class which inherits from CommonDBTM will benefit from standard right checks.
See the following methods:

- `canView <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canView>`_
- `canUpdate <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canUpdate>`_
- `canCreate <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canCreate>`_
- `canDelete <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canDelete>`_
- `canPurge <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canPurge>`_

If you need to test a specific ``rightname`` against a possible right, here is how to do:

.. code-block:: php

   <?php

   if (Session::haveRight(self::$rightname, CREATE)) {
      // OK
   }

   // we can also test a set multiple rights with AND operator
   if (Session::haveRightsAnd(self::$rightname, [CREATE, READ])) {
      // OK
   }

   // also with OR operator
   if (Session::haveRightsOr(self::$rightname, [CREATE, READ])) {
      // OK
   }

   // check a specific right (not your class one)
   if (Session::haveRight('ticket', CREATE)) {
      // OK
   }

See methods definition:

* `haveRight <https://forge.glpi-project.org/apidoc/class-Session.html#_haveRight>`_
* `haveRightsAnd <https://forge.glpi-project.org/apidoc/class-Session.html#_haveRightsAnd>`_
* `haveRightsOr <https://forge.glpi-project.org/apidoc/class-Session.html#_haveRightsOr>`_

All above functions return a boolean. If we want a graceful die of the page we have equivalent function but with a ``check`` prefix instead ``have``:

* `checkRight <https://forge.glpi-project.org/apidoc/class-Session.html#_checkRight>`_
* `checkRightsAnd <https://forge.glpi-project.org/apidoc/class-Session.html#_checkRightsAnd>`_
* `checkRightsOr <https://forge.glpi-project.org/apidoc/class-Session.html#_checkRightsOr>`_

If you need to check a right directly in a SQL query, use a logical ``&`` and ``|`` operators, ex for users:

.. code-block:: php

   <?php

   $query = "SELECT `glpi_profiles_users`.`users_id`
      FROM `glpi_profiles_users`
      INNER JOIN `glpi_profiles`
         ON (`glpi_profiles_users`.`profiles_id` = `glpi_profiles`.`id`)
      INNER JOIN `glpi_profilerights`
         ON (`glpi_profilerights`.`profiles_id` = `glpi_profiles`.`id`)
      WHERE `glpi_profilerights`.`name` = 'ticket'
         AND `glpi_profilerights`.`rights` & ". (READ | CREATE);
   $result = $DB->query($query);

In this snippet, the ``READ | CREATE`` do a binary operation to get the sum of these rights and the ``&`` SQL operator do a logical comparison with the current value in the DB.


CommonDBRelation and CommonDBChild specificities
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These classes permits to manage the relation between items and so have properties to propagate rights from their parents.

.. code-block:: php

   <?php

   abstract class CommonDBChild extends CommonDBConnexity {
      static public $checkParentRights = self::HAVE_SAME_RIGHT_ON_ITEM;

      ...
   }

   abstract class CommonDBRelation extends CommonDBConnexity {
      static public $checkItem_1_Rights = self::HAVE_SAME_RIGHT_ON_ITEM;
      static public $checkItem_2_Rights = self::HAVE_SAME_RIGHT_ON_ITEM;

      ...
   }

possible values for theses properties are:

* ``DONT_CHECK_ITEM_RIGHTS``:  Don't check the parent, we always have all rights regardless of parent's rights.
* ``HAVE_VIEW_RIGHT_ON_ITEM``: we have all rights (CREATE, UPDATE), if we can view the parent.
* ``HAVE_SAME_RIGHT_ON_ITEM``: We have the same rights as the parent class.