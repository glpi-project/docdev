Main framework objects
----------------------

GLPI contains numerous classes; but there are a few common objects you'd have to know about. All GLPI classes are in the ``inc`` directory.

.. note::

   See the full API documentation for related object for a complete list of methods provided.

CommonGLPI
^^^^^^^^^^

This is **the** main GLPI object, most of GLPI or Plugins class inherit from this one, directly or not. The class is in the ``inc/commonglpi.class.php`` file.

This object will help you to:

* manage item type name,
* manage item tabs,
* manage item menu,
* do some display,
* get URLs (form, search, ...),
* ...


CommonDBTM
^^^^^^^^^^

This is an object to manage any database stuff; it of course inherits from `CommonGLPI`_. The class is in the ``inc/commondbtm.class.php`` file.

It aims to manage database persistence and tables for all objects; and will help you to:

* add, update or delete database rows,
* load a row from the database,
* get table informations (name, indexes, relations, ...)
* ...

The CommonDBTM object provides several of the :doc:`available hooks <../plugins/hooks>`.

CommonDropdown
^^^^^^^^^^^^^^

This class aims to manage dropdown (lists) database stuff. It inherits from `CommonDBTM`_. The class is in the ``inc/commondropdown.class.php`` file.

It will help you to:

* manage the list,
* import data,
* ...

CommonTreeDropdown
^^^^^^^^^^^^^^^^^^

This class aims to manage tree lists database stuff. It inherits from `CommonDropdown`_. The class is in the ``inc/commontreedropdown.class.php`` file.

It will mainly help you to manage the tree apsect of a dropdown (parents, children, and so on).

CommonImplicitTreeDropdown
^^^^^^^^^^^^^^^^^^^^^^^^^^

This class manages tree lists that cannot be managed by the user. It inherits from `CommonTreeDropdown`_. The class is in the ``inc/commonimplicittreedropdown.class.php`` file.

CommonDBVisible
^^^^^^^^^^^^^^^

This class helps with visibility management. It inherits from `CommonDBTM`_. The class is in the ``inc/commondbvisible.class.php`` file.

It provides methods to:

* know if the user can view item,
* get dropdown parameters,
* ...

CommonDBConnexity
^^^^^^^^^^^^^^^^^

This class factorizes database relation and inheritance stuff. It inherits from `CommonDBTM`_. The class is in the ``inc/commondbconnexity.class.php`` file.

It is not designed to be used directly, see `CommonDBChild`_ and `CommonDBRelation`_.

CommonDBChild
^^^^^^^^^^^^^

This class manages simple relations. It inherits from `CommonDBConnexity`_. The class is in the ``inc/commondbchild.class.php`` file.

This object will help you to define and manage parent/child relations.

CommonDBRelation
^^^^^^^^^^^^^^^^

This class manages relations. It inherits from `CommonDBConnexity`_. The class is in the ``inc/commondbrelation.class.php`` file.

Unlike `CommonDBChild`_; it is designed to declare more :ref:`complex relations; as defined in the database model <complex-relations>`. This is therefore more complex thant just using a simple relation; but it also offers many more possibilities.

In order to setup a complex relation, you'll have to define several properties, such as:

* ``$itemtype_1`` and ``$itemtype_2``; to set both itm types used;
* ``$items_id_1`` and ``$items_id_2``; to set field id name.

Other properties let you configure how to deal with entites inheritance, ACLs; what to log on each part on several actions, and so on.

The object will also help you to:

* get search options and query,
* find rights in ACLs list,
* handle massive actions,
* ...

CommonDevice
^^^^^^^^^^^^

This class factorizes common requirements on devices. It inherits from `CommonDropdown`_. The class is in the ``inc/commondevice.class.php`` file.

It will help you to:

* import devices,
* handle menus,
* do some display,
* ...

Common ITIL objects
^^^^^^^^^^^^^^^^^^^
All common ITIL objects will help you with `ITIL <https://en.wikipedia.org/wiki/ITIL>`_ objects management (Tickets, Changes, Problems).

CommonITILObject
++++++++++++++++

Handle ITIL objects. It inherits from `CommonDBTM`_. The class is in the ``inc/commonitilobject.class.php`` file.

It will help you to:

* get users, suppliers, groups, ...
* count them,
* get objects for users, technicians, suppliers, ...
* get status,
* ...

CommonITILActor
+++++++++++++++

Handle ITIL actors. It inherits from `CommonDBRelation`_. The class is in the ``inc/commonitilactor.class.php`` file.

It will help you to:

* get actors,
* show notifications,
* get ACLs,
* ...

CommonITILCost
++++++++++++++

Handle ITIL costs. It inherits from `CommonDBChild`_. The class is in the ``inc/commonitilcost.class.php`` file.

It will help you to:

* get item cost,
* do some display,
* ...

CommonITILTask
++++++++++++++

Handle ITIL tasks. It inherits from `CommonDBTM`_. The class is in the ``inc/commonitiltask.class.php`` file.

It will help you to:

* manage tasks ACLs,
* do some display,
* get search options,
* ...

CommonITILValidation
++++++++++++++++++++

Handle ITIL validation process. It inherits from `CommonDBChild`_. The class is in the ``inc/commonitilvalidation.class.php`` file.

It will help you to:

* mange ACLs,
* get and set status,
* get counts,
* do some display,
* ...
