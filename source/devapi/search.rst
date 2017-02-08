Search Engine
-------------

The `Search class <https://forge.glpi-project.org/apidoc/class-Search.html>`_ aims to provide a multi-criteria Search engine for GLPI Itemtypes.

The itemtype classes can define a set of `search options`_ to configure which columns could be queried, how they can be accessed and displayed, etc..

It include some short-cuts functions:

* show:              displays the complete search page.
* showGenericSearch: displays only the multi-criteria form.
* showList:          displays only the resulting list.
* getDatas:          return an array of raw data.
* manageParams:      complete the $_GET values with the $_SESSION values.

The show function parse the $_GET values (by calling manageParams) passed by the page to retrieve the criteria and construct the SQL query.
For showList function, theses `parameters <#get-parameters>`_ can be passed in the second argument.


GET Parameters
^^^^^^^^^^^^^^

Here is the list of possible keys which could be passed to control the search engine.
All are optionals.

- **criteria**: array of criterion arrays to filter the search.
                Each criterion array must provide:
   - *link*: logical operator in [AND, OR, AND NOT, AND NOT], optional for 1st element.
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
                    Not all itemtype can be linked, see this `part of code <https://github.com/glpi-project/glpi/blob/9.1.2/inc/search.class.php#L1740>`_ to know wich ones could be.
                    The parameter need the same keys as criteria plus one additional:
   - *itemtype*: second itemtype to link.
- **sort**: id of the searchoption to sort by.
- **order**: **ASC** ending sorting / **DESC** ending sorting.
- **start**: integer for indicating the start point of pagination.
- **reset=reset**: optional option to fully reset the saved parameters.

For this last option, GLPI save in $_SESSION['glpisearch'][$itemtype] the last set of parameters for the current itemtype for each search query and automatically restore them on a new search (for the same itemtype) without *reset* and *[meta]criteria* options.


Search options
^^^^^^^^^^^^^^

Each itemtype can define a set of options to represent the columns which can be queried/displayed by the search engine.
Each option is identified by an unique integer (we must avoid conflict).

Prior to GLPI 9.2 version, we needed a *getSearchOptions* function which return the array of options:

.. code-block:: php

   function getSearchOptions() {
      $tab                       = array();
      $tab['common']             = __('Characteristics');

      $tab[1]['table']           = $this->getTable();
      $tab[1]['field']           = 'name';
      $tab[1]['name']            = __('Name');
      $tab[1]['datatype']        = 'itemlink';
      $tab[1]['massiveaction']   = false;

      ...

      return $tab;
   }

Since GLPI 9.2, a new function exist to avoid conflict of id.
An `unit test <https://github.com/glpi-project/glpi/blob/71174f45/tests/SearchTest.php#L216>`_ is present on the repository to check potential conflicts.
Here is the new format (the options are identical):

.. code-block:: php

   function getSearchOptionsNew() {
      $tab = [];

      $tab[] = [
         'id'                 => 'common',
         'name'               => __('Characteristics')
      ];

      $tab[] = [
         'id'                 => '1',
         'table'              => $this->getTable(),
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
- **name**: a label used to display the option in the search pages (like header for example).

And optionally the following keys:

- **linkfield**: foreign key used to join to the current itemtype table.
                 if not empty, standard massive action (update option) for this option will be impossible

- **searchtype**: string or array containing forced search type:
   - equals (may force use of field instead of id adding searchequalsonfield option)
   - contains

- **forcegroupby**: boolean to force group by on this *option*

- **splititems**: instead of using simple <br> to split grouped items : used <hr>

- **usehaving**: use having instead of WHERE in SQL query.

- **massiveaction**: set to false to disable the massive actions for this option.

- **nosort**: set to true to disable sorting this option.

- **nosearch**: set to true to disable search ([meta]criteria) on this option.

- **nodisplay**: set to true to disable displaying this option.

- **joinparams**: define how the join must be done (if complex)
                  array may contain :
   - *beforejoin* : array define which tables must be join before. array contains table key (may contain additional joinparams).
                    Do an array of array if several beforejoin, both are valid.
                    Example : array("beforejoin"=>array('table'=>mytable,'joinparams'=>array('jointype'=>'child'...

   - *jointype*: string define the join type :
      - 'empty' for a standard join
      - 'child' for a child table (standard foreign key usage)
      - 'itemtype_item' for links using itemtype and items_id fields
      - 'item_item' for table used to link 2 similar items : glpi_tickets_tickets for example : link fields are standardfk_1 and standardfk_2

   - *condition*: additional condition to add to the standard link.
                   use NEWTABLE or REFTABLE tag to use the table names.

   - *nolink*: set to true to define an additional join not used to join the initial table


- **additionalfields**: is array of additionalfields need to display or define value

- **datatype**:
   - 'date'
      *optional parameters*:
         - **searchunit**: SEARCH_UNIT (DAY or MONTH default)
         - **maybefuture**: set to true if date may be in future
         - **emptylabel**: string to display if null is selected

   - 'datetime'
      *optional parameters*:
         - **searchunit**: SEARCH_UNIT (DAY or MONTH default)
         - **maybefuture**: set to true if date may be in future
         - **emptylabel**: string to display if null is selected

   - 'date_delay': date with a delay in month (end_warranty, end_date)
      *optional parameters*:
         - **datafields**: [1]=DATE_FIELD, ['datafields'][2]=DELAY_ADD_FIELD, ['datafields'][3]=DELAY_MINUS_FIELD
         - **searchunit**: SEARCH_UNIT (DAY or MONTH default)
         - **delay_unit**: DELAY_UNIT (DAY or MONTH default)
         - **maybefuture**: set to true if date may be in future
         - **emptylabel**: string to display if null is selected

   - 'timestamp': time in seconds
      *optional parameters*:
         - **withseconds**: true/false (false by default)

   - 'weblink'

   - 'email'

   - 'text'

   - 'string'

   - 'ip'

   - 'mac'
      *optional parameters*:
         - **htmltext**: true/false (false by default)

   - 'number':
      *optional parameters*:
         - **width**: for width search
         - **min**: minimum value (default 0)
         - **max**: maximum value (default 100)
         - **step**: step for select (default 1)
         - **toadd**: array of values to add (default empty)

   - 'count': same as number but count the number of item in the table

   - 'decimal': idem that number but formatted with decimal

   - 'bool'

   - 'itemlink': link to the item

   - 'itemtypename'
      *optional parameters*:
         defined itemtypes available : 'itemtype_list' : list in $CFG_GLPI or 'types' array containing available types

   - 'language':
      *optional parameters*:
         - **display_emptychoice**: 'emptylabel'

   - 'right': for No Access / Read / Right
      *optional parameters*:
         - **nonone**: 
         - **noread**: 
         - **nowrite**: 

   - 'dropdown': dropdown may have several additional parameters depending of dropdown type : **right** for user one for example

Bookmarks
^^^^^^^^^


Display Preferences
^^^^^^^^^^^^^^^^^^^


Examples
^^^^^^^^

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



