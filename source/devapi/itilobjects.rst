ITIL objects
------------

Tickets, changes and problems are the `ITIL <https://en.wikipedia.org/wiki/ITIL>`_ objects of GLPI. The ``Ticket``, ``Change`` and ``Problem`` classes all inherit from ``CommonITILObject`` (see :doc:`mainobjects`), which handles what they share: actors, status, tasks, followups, solutions, validations, costs...

.. _itil_actors:

Actors
^^^^^^

Actor types
+++++++++++

An ITIL object has three types of actors:

.. list-table::
   :class: wrap
   :header-rows: 1

   * - Type
     - Constant
     - Name in input keys
     - Actors
   * - requester
     - ``CommonITILActor::REQUESTER`` (1)
     - ``requester``
     - user, email, group
   * - observer
     - ``CommonITILActor::OBSERVER`` (3)
     - ``observer``
     - user, email, group
   * - assignee
     - ``CommonITILActor::ASSIGN`` (2)
     - ``assign``
     - user, group, supplier

In the ITIL form, the actor selector (``Dropdown::getDropdownActors()``) only offers suppliers for assignees, and only groups flagged for the actor type (``is_requester``, ``is_watcher`` or ``is_assign``), visible in the entity of the object.

An **email actor** is an email address without any GLPI account: a user actor with ``items_id = 0`` and the address in ``alternative_email``. Typing a valid address in the actor selector creates one.

Each actor is a row of a link table, handled by a ``CommonITILActor`` subclass:

.. list-table::
   :class: wrap
   :header-rows: 1
   :stub-columns: 1

   * -
     - User
     - Group
     - Supplier
   * - Ticket
     - ``glpi_tickets_users``

       ``Ticket_User``
     - ``glpi_groups_tickets``

       ``Group_Ticket``
     - ``glpi_suppliers_tickets``

       ``Supplier_Ticket``
   * - Change
     - ``glpi_changes_users``

       ``Change_User``
     - ``glpi_changes_groups``

       ``Change_Group``
     - ``glpi_changes_suppliers``

       ``Change_Supplier``
   * - Problem
     - ``glpi_problems_users``

       ``Problem_User``
     - ``glpi_groups_problems``

       ``Group_Problem``
     - ``glpi_problems_suppliers``

       ``Problem_Supplier``

A row holds one actor with one type: ``glpi_tickets_users`` has the ``id``, ``tickets_id``, ``users_id``, ``type``, ``use_notification`` and ``alternative_email`` columns. A user both requester and observer of a ticket has two rows. ``CommonITILObject::getActorObjectForItem()`` returns the link class to use for an actor itemtype.

Actors input
++++++++++++

Actors are not fields of the ITIL object: they are passed as special keys in the input of ``add()`` and ``update()``, then written in the link tables:

#. ``prepareInputForAdd()`` / ``prepareInputForUpdate()`` call ``transformActorsInput()``, which converts the ``_actors`` key into the historical ``_<fk>_<type>`` keys and, on update, computes the ``_<fk>_<type>_deleted`` keys;
#. business rules run, and may add their own actor keys;
#. ``post_addItem()`` / ``post_updateItem()`` call ``updateActors()``, which reads all the actor keys, compares them with the existing actors, and adds, updates or deletes the link rows.

Input families
""""""""""""""

Actor keys come in four families, which do not have the same meaning. In key names, ``<fk>`` is ``users_id``, ``groups_id`` or ``suppliers_id``, and ``<type>`` is ``requester``, ``observer`` or ``assign``.

.. list-table::
   :class: wrap
   :header-rows: 1

   * - Family
     - Keys
     - Effect
   * - ``_actors``
     - ``_actors['requester']``, ``_actors['observer']``, ``_actors['assign']``
     - **Complete list** of the actors: on update, an existing actor missing from it is deleted. Converted into ``_<fk>_<type>`` keys by ``transformActorsInput()``.
   * - ``_<fk>_<type>`` (historical keys)
     - ``_users_id_requester``, ``_groups_id_assign``... with their ``_<fk>_<type>_notif`` (notification settings) and ``_<fk>_<type>_deleted`` (actors to delete) companions
     - **Adds** actors; the ``_deleted`` companion deletes actors.
   * - ``_additional_*``
     - ``_additional_requesters``, ``_additional_groups_observers``, ``_additional_suppliers_assigns``...
     - **Adds** actors.
   * - ``_itil_<type>``
     - ``_itil_requester``, ``_itil_observer``, ``_itil_assign``
     - **Adds one** actor, on update only.

``_additional_*`` keys are named ``_additional_<type>s`` for users, and ``_additional_<itemtype>s_<type>s`` for groups and suppliers.

.. versionadded:: 10.0

   The ``_actors`` key, sent by the ITIL form actor selector.

.. warning::

   When ``_actors`` is sent, a type missing from it is handled as an empty list: on update, all the actors of this type are deleted. Always send the three types.

Key formats
"""""""""""

``_<fk>_<type>`` is either a single id, or an array of ids. Notification settings of user and supplier actors go in a separate ``_<fk>_<type>_notif`` key, with the same format:

.. code-block:: php

   <?php

   // one actor
   $input['_users_id_requester'] = 12;
   $input['_users_id_requester_notif'] = [
       'use_notification'  => 1,
       'alternative_email' => '',
   ];

   // several actors: settings are matched by key
   $input['_users_id_observer'] = [0 => 5, 1 => 0];
   $input['_users_id_observer_notif'] = [
       'use_notification'  => [0 => 1, 1 => 1],
       'alternative_email' => [0 => '', 1 => 'x@example.com'],
   ];

The keys of a ``_<fk>_<type>`` array are **references** to another input: ``updateActors()`` uses the key of each actor to read its settings in the ``use_notification`` and ``alternative_email`` arrays of ``_<fk>_<type>_notif``. In the second example, user ``5`` gets the settings of key ``0``, and the email actor ``x@example.com`` those of key ``1``. Keys of the array are not always ``0..n``: once ``_actors`` is converted, they look like ``_actors_12`` (or ``_actors_x@example.com`` for an email actor), and both formats can be mixed. Code that changes these arrays must therefore:

* remove an actor with ``unset($input[$key][$k])``, without reindexing the array, otherwise actors get the settings of another one;
* change ``_<fk>_<type>`` and ``_<fk>_<type>_notif`` together: an array of ids with scalar settings raises an ``Unexpected format found in "..._notif"`` warning, and the settings are ignored.

Each element of ``_actors['<type>']`` is an array with the ``itemtype`` and ``items_id`` keys, and optionally ``use_notification`` and ``alternative_email``. An email actor must have a ``use_notification`` value: without it, the address is not transferred and the actor is ignored.

In ``_additional_*`` keys, each element is either an id, or an array that contains the id under the ``<fk>`` key. Only the id is read: keys and notification settings are ignored.

In ``_<fk>_<type>_deleted`` keys, each element is an existing actor, as returned by ``getActorsForType()``: ``items_id`` is the actor, ``id`` is the **link row** to delete.

``_itil_<type>`` holds one actor, with a ``_type`` key (``user``, ``group`` or ``supplier``) and the matching ``<fk>`` key. It is handled directly by ``CommonITILObject::prepareInputForUpdate()``, not by ``updateActors()``. On creation, it is only used by business rules, and no actor is added.

Sources
"""""""

The tables below list the keys accepted for each actor type, without the ``_notif`` keys, and the contexts that send them:

* **ITIL form**: create and update forms of tickets, changes and problems, which send ``_actors`` (as JSON, decoded in ``front/*.form.php``);
* **Associate myself**: the ``addme_*`` buttons of the ITIL form;
* **Massive action**: the *Add an actor* massive action;
* **Forms**: destinations of the forms (``Glpi\Form``);
* **Mail collector**: the sender is the requester; copy recipients, and direct recipients, become observers depending on the ``add_cc_to_observer`` and ``add_to_to_observer`` options;
* **Business rules**: the *Assign* action writes ``_<fk>_<type>`` (and removes the matching ``_notif`` and ``_additional_*`` keys), the *Add* action writes ``_additional_*``. The group actions *from the item*, *default from user* and the regex actions write ``_groups_id_<type>`` or ``_additional_groups_*``;
* **SLA/OLA escalation levels**: same actions as business rules, *Add* only;
* **Automatic assignment**: tickets only, technician and group of the category or of the item, when the input has no assigned user (respectively group);
* **ITIL template**: predefined actor fields fill the ITIL form, so they are usually sent through ``_actors``. They are sent as ``_<fk>_<type>`` on creation when the field is predefined and read-only (``enforceReadonlyFields()``, called by ``front/*.form.php`` only), and by recurrent items (``CommonITILRecurrent``), which start from ``getDefaultValues()`` and add all the predefined fields.

The legacy API (v1) and plugins can send any of these keys. The high-level API (v2) does not use them: its team endpoints call ``CommonITILObject::addTeamMember()``, which creates the link row directly.

For each actor type, an example of each key is given first (the ids are arbitrary), then the contexts that send it.

Requester
"""""""""

.. code-block:: php

   <?php

   $input = [
       '_actors' => [
           'requester' => [
               ['itemtype' => 'User', 'items_id' => 12],
               ['itemtype' => 'Group', 'items_id' => 3],
               [
                   'itemtype'          => 'User',
                   'items_id'          => 0,
                   'use_notification'  => 1,
                   'alternative_email' => 'x@example.com',
               ],
           ],
       ],
       '_users_id_requester' => [12, 34], // or 12
       '_users_id_requester_deleted' => [
           ['itemtype' => 'User', 'items_id' => 12, 'id' => 57, /* ... */],
       ],
       '_groups_id_requester' => [3, 8], // or 3
       '_groups_id_requester_deleted' => [
           ['itemtype' => 'Group', 'items_id' => 3, 'id' => 21, /* ... */],
       ],
       '_additional_requesters' => [
           ['users_id' => 12, 'use_notification' => 1],
           34,
       ],
       '_additional_groups_requesters' => [3, 8],
       '_itil_requester' => ['_type' => 'user', 'users_id' => 12],
       // or ['_type' => 'group', 'groups_id' => 3]
   ];

.. list-table::
   :class: wrap
   :header-rows: 1

   * - Key
     - Value
     - Contexts
   * - ``_actors['requester']``
     - array of actors
     - ITIL form
   * - ``_users_id_requester``
     - int or array
     - Forms, mail collector, business rules (*Assign*), ITIL template
   * - ``_users_id_requester_deleted``
     - array of existing actors
     - ITIL form (computed on update)
   * - ``_groups_id_requester``
     - int or array
     - Forms, business rules (*Assign*, *from the item*, *default from user*), ITIL template
   * - ``_groups_id_requester_deleted``
     - array of existing actors
     - ITIL form (computed on update)
   * - ``_additional_requesters``
     - array
     - Business rules (*Add*), SLA/OLA escalation levels
   * - ``_additional_groups_requesters``
     - array
     - Business rules (*Add*, regex), SLA/OLA escalation levels
   * - ``_itil_requester``
     - one actor
     - Massive action

Observer
""""""""

.. code-block:: php

   <?php

   $input = [
       '_actors' => [
           'observer' => [
               ['itemtype' => 'User', 'items_id' => 12],
               ['itemtype' => 'Group', 'items_id' => 3],
           ],
       ],
       '_users_id_observer' => [12, 34], // or 12
       '_users_id_observer_deleted' => [
           ['itemtype' => 'User', 'items_id' => 12, 'id' => 58, /* ... */],
       ],
       '_groups_id_observer' => [3, 8], // or 3
       '_groups_id_observer_deleted' => [
           ['itemtype' => 'Group', 'items_id' => 3, 'id' => 22, /* ... */],
       ],
       '_additional_observers' => [
           ['users_id' => 12, 'use_notification' => 1],
           34,
       ],
       '_additional_groups_observers' => [3, 8],
       '_itil_observer' => ['_type' => 'user', 'users_id' => 12],
   ];

.. list-table::
   :class: wrap
   :header-rows: 1

   * - Key
     - Value
     - Contexts
   * - ``_actors['observer']``
     - array of actors
     - ITIL form
   * - ``_users_id_observer``
     - int or array
     - Forms, mail collector, business rules (*Assign*), ITIL template
   * - ``_users_id_observer_deleted``
     - array of existing actors
     - ITIL form (computed on update)
   * - ``_groups_id_observer``
     - int or array
     - Forms, business rules (*Assign*, *from the item*, *default from user*), ITIL template
   * - ``_groups_id_observer_deleted``
     - array of existing actors
     - ITIL form (computed on update)
   * - ``_additional_observers``
     - array
     - Business rules (*Add*), SLA/OLA escalation levels
   * - ``_additional_groups_observers``
     - array
     - Business rules (*Add*, regex), SLA/OLA escalation levels
   * - ``_itil_observer``
     - one actor
     - Massive action, *Associate myself*

Assignee
""""""""

.. code-block:: php

   <?php

   $input = [
       '_actors' => [
           'assign' => [
               ['itemtype' => 'User', 'items_id' => 5],
               ['itemtype' => 'Supplier', 'items_id' => 2],
           ],
       ],
       '_users_id_assign' => [5, 7], // or 5
       '_users_id_assign_deleted' => [
           ['itemtype' => 'User', 'items_id' => 5, 'id' => 60, /* ... */],
       ],
       '_groups_id_assign' => [3, 8], // or 3
       '_groups_id_assign_deleted' => [
           ['itemtype' => 'Group', 'items_id' => 3, 'id' => 23, /* ... */],
       ],
       '_suppliers_id_assign' => [2, 4], // or 2
       '_suppliers_id_assign_deleted' => [
           ['itemtype' => 'Supplier', 'items_id' => 2, 'id' => 9, /* ... */],
       ],
       '_additional_assigns' => [
           ['users_id' => 5, 'use_notification' => 1],
           7,
       ],
       '_additional_groups_assigns' => [3, 8],
       '_additional_suppliers_assigns' => [
           ['suppliers_id' => 2, 'use_notification' => 1],
       ],
       '_itil_assign' => ['_type' => 'supplier', 'suppliers_id' => 2],
   ];

.. list-table::
   :class: wrap
   :header-rows: 1

   * - Key
     - Value
     - Contexts
   * - ``_actors['assign']``
     - array of actors
     - ITIL form
   * - ``_users_id_assign``
     - int or array
     - Forms, business rules (*Assign*), automatic assignment, ITIL template
   * - ``_users_id_assign_deleted``
     - array of existing actors
     - ITIL form (computed on update)
   * - ``_groups_id_assign``
     - int or array
     - Forms, business rules (*Assign*, *from the item*, *default from user*), automatic assignment, ITIL template
   * - ``_groups_id_assign_deleted``
     - array of existing actors
     - ITIL form (computed on update)
   * - ``_suppliers_id_assign``
     - int or array
     - Forms, business rules (*Assign*), ITIL template
   * - ``_suppliers_id_assign_deleted``
     - array of existing actors
     - ITIL form (computed on update)
   * - ``_additional_assigns``
     - array
     - Business rules (*Add*), SLA/OLA escalation levels
   * - ``_additional_groups_assigns``
     - array
     - Business rules (*Add*, regex), SLA/OLA escalation levels
   * - ``_additional_suppliers_assigns``
     - array
     - Business rules (*Add*), SLA/OLA escalation levels
   * - ``_itil_assign``
     - one actor
     - Massive action, *Associate myself*
