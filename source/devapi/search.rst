.. |br| raw:: html

   <br />

Search Engine
-------------

Goal
^^^^

The `Search class <https://forge.glpi-project.org/apidoc/class-Search.html>`_ aims to provide a multi-criteria Search engine for GLPI Itemtypes.

The itemtype classes can define a set of `search options`_ to configure which columns could be queried, how they can be accessed and displayed, etc..

It include some short-cuts functions:

- **show**:              displays the complete search page.
- **showGenericSearch**: displays only the multi-criteria form.
- **showList**:          displays only the resulting list.
- **getDatas**:          return an array of raw data.
- **manageParams**:      complete the $_GET values with the $_SESSION values.

The show function parse the $_GET values (by calling manageParams) passed by the page to retrieve the criteria and construct the SQL query. |br|
For showList function, theses `parameters <#get-parameters>`_ can be passed in the second argument.

Examples
++++++++

To display the search engine with its default options (criteria form, pager, list):

.. code-block:: php

   <?php
   $itemtype = 'Computer';
   Search::show($itemtype);

If you want to display only the multi-criteria form (with some additional options):

.. code-block:: php

   <?php
   $itemtype = 'Computer';
   $p = [
      'addhidden'   => [ // some hidden inputs added to the criteria form
         'hidden_input' => "OK"
      ],
      'actionname'  => 'preview', //change the submit button name
      'actionvalue' => __('Preview'), //change the submit button label
   ];
   Search::showGenericSearch($itemtype, $p);

If you want to display only a list without the criteria form:

.. code-block:: php

   <?php

   // display a list of users with entity = 'Root entity'
   $itemtype = 'User';
   $p = [
      'start'      => 0,
      'is_deleted' => 0,
      'sort'       => 1, // sort by name
      'order'      => 'DESC'
      'reset'      => 'reset',
      'criteria'   => [
         [
            'field'      => 80,
            'searchtype' => 'equals',
            'value'      => 0,
         ],
      ],
   ];
   Search::showList($itemtype, $p);

TODO
^^^^

- datafields option
- difference between searchunit and delay_unit
- dropdown translations
- giveItem
- export
- fulltext search


GET Parameters
^^^^^^^^^^^^^^

.. image:: /_static/images/search_criteria.png
   :alt: Search criteria
   :align: center

Here is the list of possible keys which could be passed to control the search engine. |br|
All are optionals.

- **criteria**: array of criterion arrays to filter the search. Each criterion array must provide:

   - *link*: logical operator in [AND, OR, AND NOT, AND NOT], optional for first element.
   - *field*: id of the `searchoption <#search-options>`_.
   - *searchtype*: type of search with one of theses values:

      - 'contains'
      - 'equals'
      - 'notequals'
      - 'lessthan'
      - 'morethan'
      - 'under'
      - 'notunder'

   - *value*: the value to search

- **metacriteria**: is very similar to *criteria* parameter but permits to search in the `search options`_ of an itemtype linked to the current (Ex: the softwares of a computer).

  Not all itemtype can be linked, see this `part of code <https://github.com/glpi-project/glpi/blob/9.1.2/inc/search.class.php#L1740>`_ to know which ones could be.

  The parameter need the same keys as criteria plus one additional:

   - *itemtype*: second itemtype to link.

- **sort**: id of the searchoption to sort by.
- **order**: **ASC** ending sorting / **DESC** ending sorting.
- **start**: integer for indicating the start point of pagination.
- **is_deleted**: boolean for display trash-bin.
- **reset=reset**: optional key to fully reset the saved parameters.

For this last option, GLPI save in $_SESSION['glpisearch'][$itemtype] the last set of parameters for the current itemtype for each search query and automatically restore them on a new search (for the same itemtype) without *reset* and *[meta]criteria* options.


Search options
^^^^^^^^^^^^^^

Each itemtype can define a set of options to represent the columns which can be queried/displayed by the search engine. |br|
Each option is identified by an unique integer (we must avoid conflict).

Prior to GLPI 9.2 version, we needed a *getSearchOptions* method which return the array of options:

.. code-block:: php

   <?php
   function getSearchOptions() {
      $tab                       = array();
      $tab['common']             = __('Characteristics');

      $tab[1]['table']           = self::getTable();
      $tab[1]['field']           = 'name';
      $tab[1]['name']            = __('Name');
      $tab[1]['datatype']        = 'itemlink';
      $tab[1]['massiveaction']   = false;

      ...

      return $tab;
   }

Since GLPI 9.2, a new method exist to avoid conflict of id.
An `unit test <https://github.com/glpi-project/glpi/blob/71174f45/tests/SearchTest.php#L216>`_ is present on the repository to check potential conflicts.
Here is the new format (the others keys/values are identical):

.. code-block:: php

   <?php
   function getSearchOptionsNew() {
      $tab = [];

      $tab[] = [
         'id'                 => 'common',
         'name'               => __('Characteristics')
      ];

      $tab[] = [
         'id'                 => '1',
         'table'              => self::getTable(),
         'field'              => 'name',
         'name'               => __('Name'),
         'datatype'           => 'itemlink',
         'massiveaction'      => false
      ];

      ...

      return $tab;
   }

Each option must define the following keys:

- **table**: the SQL table where the *field* key can be found.
- **field**: the SQL column to query.
- **name**: a label used to display the *searchoption* in the search pages (like header for example).

And optionally the following keys:

- **linkfield**: foreign key used to join to the current itemtype table. |br|
   if not empty, standard massive action (update feature) for this *searchoption* will be impossible

- **searchtype**: string or array containing forced search type:

   - equals (may force use of field instead of id when adding searchequalsonfield option)
   - contains

- **forcegroupby**: boolean to force group by on this *searchoption*

- **splititems**: instead of using simple '<br>' to split grouped items : used '<hr>'

- **usehaving**: use HAVING instead of WHERE in SQL query.

- **massiveaction**: set to false to disable the massive actions for this *searchoption*.

- **nosort**: set to true to disable sorting with this *searchoption*.

- **nosearch**: set to true to disable searching in this *searchoption*.

- **nodisplay**: set to true to disable displaying this *searchoption*.

- **joinparams**: define how the SQL join must be done. Array may contain:

   - *beforejoin*: define which tables must be joined to access the field. |br|
      The array contains **table** key and may contain an additional **joinparams**. |br|
      In case of nested *beforejoin*, we start the SQL join from the last dimension. |br|
      Example : ['beforejoin' => ['table' => 'mytable', 'joinparams' => ['beforejoin' => [...

   - *jointype*: string define the join type:

      - 'empty' for a standard join
         (REFTABLE.`#linkfield#` = NEWTABLE.`id`)
      - 'child' for a child table
         (REFTABLE.`id` = NEWTABLE.`#linkfield#`)
      - 'itemtype_item' for links using itemtype and items_id fields
         (REFTABLE.`id` = NEWTABLE.`items_id` AND NEWTABLE.`itemtype` = '#new_table_itemtype#')
      - 'mainitemtype_mainitem', same as itemtype_item but using mainitemtype and mainitems_id fields
         (REFTABLE.`id` = NEWTABLE.`mainitems_id` AND NEWTABLE.`mainitemtype` = 'new table itemtype')
      - 'itemtypeonly', same as itemtype_item jointype but without linking id
         (NEWTABLE.`itemtype` = '#new_table_itemtype#')
      - 'item_item' for table used to link 2 similar items : glpi_tickets_tickets for example : link fields are standardfk_1 and standardfk_2
         (REFTABLE.`id` = NEWTABLE.`#fk_for_new_table#_1` OR REFTABLE.`id` = NEWTABLE.`#fk_for_new_table#_2`)
      - 'item_item_revert', same as item_item and child jointypes
         (NEWTABLE.`id` = REFTABLE.`#fk_for_new_table#_1` OR NEWTABLE.`id` = REFTABLE.`#fk_for_new_table#_2`)

   - *condition*: additional condition to add to the standard link. |br|
      Use NEWTABLE or REFTABLE tag to use the table names.

   - *nolink*: set to true to indicate the current join doesn't link to the previous join/from (nested joinsparams)

- **additionalfields**: an array for additional fields to add in the SELECT part of the query. Ex: 'additionalfields' => ['id', 'content', 'status']

- **datatype**: define how the *searchoption* will be displayed and if a control need to be used for modification (ex: datepicker for date) and affect the *searchtype* dropdown. |br|
   *optional parameters* are added to the base array of the *searchoption* to control more exactly the datatype.

   - 'date'.

      *optional parameters*:

      - **searchunit**: MYSQL DATE_ADD unit, default MONTH (see https://dev.mysql.com/doc/refman/5.5/en/date-and-time-functions.html#function_date-add)
      - **maybefuture**: display datepicker with future date selection, default false
      - **emptylabel**: string to display in case of null value

   - 'datetime'.

      *optional parameters*:

      - **searchunit**: MYSQL DATE_ADD unit, default MONTH (see https://dev.mysql.com/doc/refman/5.5/en/date-and-time-functions.html#function_date-add)
      - **maybefuture**: display datepicker with future date selection, default false
      - **emptylabel**: string to display in case of null value

   - 'date_delay': date with a delay in month (end_warranty, end_date).

      *optional parameters*:

      - **datafields**: [1]=DATE_FIELD, ['datafields'][2]=DELAY_ADD_FIELD, ['datafields'][3]=DELAY_MINUS_FIELD
      - **searchunit**: MYSQL DATE_ADD unit, default MONTH (see https://dev.mysql.com/doc/refman/5.5/en/date-and-time-functions.html#function_date-add)
      - **delay_unit**: MYSQL DATE_ADD unit, default MONTH (see https://dev.mysql.com/doc/refman/5.5/en/date-and-time-functions.html#function_date-add)
      - **maybefuture**: display datepicker with future date selection, default false
      - **emptylabel**: string to display in case of null value

   - 'timestamp': use Dropdown::showTimeStamp() for modification

      *optional parameters*:

      - **withseconds**: boolean (false by default)

   - 'weblink'

   - 'email'

   - 'color': use Html::showColorField() for modification

   - 'text'

   - 'string': use a rich text editor for modification

   - 'ip'

   - 'mac'.

      *optional parameters*:

      - **htmltext**: boolean, escape the value (false by default)

   - 'number'. use a Dropdown::showNumber() for modification (in case of 'equals' searchtype). |br|
      For 'contains' searchtype, you can use < and > prefix in 'value'.

      *optional parameters*:

      - **width**: html attribute passed to Dropdown::showNumber()
      - **min**: minimum value (default 0)
      - **max**: maximum value (default 100)
      - **step**: step for select (default 1)
      - **toadd**: array of values to add a the beginning of the dropdown

   - 'integer': alias for number.

   - 'count': same as number but count the number of item in the table

   - 'decimal': idem that number but formatted with decimal

   - 'bool': use Dropdown::showYesNo() for modification

   - 'itemlink': create a link to the item

   - 'itemtypename': use Dropdown::showItemTypes() for modification

      *optional parameters*, to define available itemtypes:

      - **itemtype_list**: list in $CFG_GLPI (see https://github.com/glpi-project/glpi/blob/9.1.2/config/define.php#L166)
      - **types**: array containing available types

   - 'language'. use Dropdown::showLanguages() for modification

      *optional parameters*:

      - **display_emptychoice**: display an empty choice (-------)

   - 'right': use Profile::dropdownRights() for modification

      *optional parameters*:

      - **nonone**: hide none choice ? (default false)
      - **noread**: hide read choice ? (default false)
      - **nowrite**: hide write choice ? (default false)

   - 'dropdown': use Itemtype::dropdown() for modification. |br|
      Dropdown may have several additional parameters depending of dropdown type : **right** for user one for example

   - 'specific': if not any of the previous options matches the way you want to display your field, you can use this datatype. |br|
      See `Specific search options`_ paragraph below for implementation.


Specific search options
+++++++++++++++++++++++

You may want to control how to select and display your field in a searchoption. |br|
You need to set 'datatype' => 'specific' in your search option and declare theses methods in your class:

   - **getSpecificValueToDisplay**: define how to display the field in the list.
      Parameters:

         - *$field*: column name, it matches the 'field' key of your searchoptions
         - *$values*: all the values of the current row (for select)
         - *$options*: will contains theses keys:
            - 'html'
            - 'searchopt': the current full searchoption

   - **getSpecificValueToSelect**: define how to display the field input in the criteria form and massive action.
      Parameters:

         - *$field*: column name, it matches the 'field' key of your searchoptions
         - *$values*: the current criteria value passed in $_GET parameters
         - *$name*: the html attribute name for the input to display
         - *$options*: this array may vary strongly in function of the searchoption or from the massiveaction or criteria display. Check the corresponding files:
            - `searchoptionvalue.php <https://github.com/glpi-project/glpi/blob/ee667a059eb9c9a57c6b3ae8309e51ca99a5eeaf/ajax/searchoptionvalue.php#L128>`_
            - `massiveaction.class.php <https://github.com/glpi-project/glpi/blob/ee667a059eb9c9a57c6b3ae8309e51ca99a5eeaf/inc/massiveaction.class.php#L881>`_


Simplified example extracted from `CommonItilObject Class <https://github.com/glpi-project/glpi/blob/ee667a059eb9c9a57c6b3ae8309e51ca99a5eeaf/inc/commonitilobject.class.php#L2366>`_ for glpi_tickets.status field:

.. code-block:: php

   <?php

   function getSearchOptionsMain() {
      $tab = [];

      ...

      $tab[] = [
         'id'          => '12',
         'table'       => $this->getTable(),
         'field'       => 'status',
         'name'        => __('Status'),
         'searchtype'  => 'equals',
         'datatype'    => 'specific'
      ];

      ...

      return $tab;
   }

   static function getSpecificValueToDisplay($field, $values, array $options=array()) {

      if (!is_array($values)) {
         $values = array($field => $values);
      }
      switch ($field) {
         case 'status':
            return self::getStatus($values[$field]);

         ...

      }
      return parent::getSpecificValueToDisplay($field, $values, $options);
   }

   static function getSpecificValueToSelect($field, $name='', $values='', array $options=array()) {

      if (!is_array($values)) {
         $values = array($field => $values);
      }
      $options['display'] = false;

      switch ($field) {
         case 'status' :
            $options['name']  = $name;
            $options['value'] = $values[$field];
            return self::dropdownStatus($options);

         ...
      }
      return parent::getSpecificValueToSelect($field, $name, $values, $options);
   }


Field number in search constant
+++++++++++++++++++++++++++++++

See `the document </_static/documents/GLPI-SearchEngine.ods>`_.

S => STATE_TYPE, R => RESERVATION_TYPE



Default Select/Where/Join
^^^^^^^^^^^^^^^^^^^^^^^^^

The search class implements 3 methods which add some stuff to SQL queries before the searchoptions computation. |br|
For some itemtype, we need to filter the query or additional fields to it. |br|
For example, filtering the tickets you cannot view if you don't have the proper rights.

You can add the needed case(s) for your feature in theses methods. |br|
We have hooks for the plugins to define their own set of default conditions in their hook.php file.

addDefaultSelect
++++++++++++++++

See `core definition <https://github.com/glpi-project/glpi/blob/ee667a059eb9c9a57c6b3ae8309e51ca99a5eeaf/inc/search.class.php#L2202>`_

Plugin hook:

.. code-block:: php

   <?php

   function plugin_mypluginname_addDefaultSelect($itemtype) {
      switch ($type) {
         case "MyItemtype" :
            return "`mytable`.`myfield` = 'myvalue' AS MYNAME, ";
      }
      return "";
   }


addDefaultWhere
+++++++++++++++

See `core definition <https://github.com/glpi-project/glpi/blob/ee667a059eb9c9a57c6b3ae8309e51ca99a5eeaf/inc/search.class.php#L2580>`_

Plugin hook:

.. code-block:: php

   <?php

   function plugin_mypluginname_addDefaultJoin($itemtype, $ref_table, &$already_link_tables) {
      switch ($itemtype) {
         case "MyItemtype" :
            return Search::addLeftJoin($itemtype, $ref_table, $already_link_tables,
                                       "newtable", "linkfield");
      }
      return "";
   }

addDefaultJoin
++++++++++++++

See `core definition <https://github.com/glpi-project/glpi/blob/ee667a059eb9c9a57c6b3ae8309e51ca99a5eeaf/inc/search.class.php#L3381>`_

.. code-block:: php

   <?php

   function plugin_mypluginname_addDefaultWhere($itemtype) {
      switch ($itemtype) {
         case "MyItemtype" :
            return " `mytable`.`myfield` = 'myvalue' ";
      }
      return "";
   }


Bookmarks
^^^^^^^^^

The *glpi_boomarks* table stores a list of search queries for the users and permit to retrieve them. |br|
The 'query' field contains an url query construct from `parameters`_ with `http_build_query <http://php.net/manual/en/function.http-build-query.php>`_ php function.



Display Preferences
^^^^^^^^^^^^^^^^^^^

The *glpi_displaypreferences* table stores the list of default columns which need to be displayed to a user for an itemtype. |br|
A set of preferences can be personal or global (*users_id* = 0). |br|
If a user doesn't have any personal preferences for an itemtype, the search engine will use the global preferences

