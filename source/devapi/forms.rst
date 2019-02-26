Building forms
--------------

.. versionadded: 10.0.0

A GLPI form is an array with some configuration informations, and some elements that would be displayed. Without any extra configuration, fields in the form will match current table existing columns, but defaults are provided.

Workflow
^^^^^^^^

All the work is done in `CommonDBTM` class, there are several methods that are usefull:

* ``getEditForm()``, ``getAddForm()`` (both aliases to ``getForm()``) will give you a form definition for the current object configuration,
* ``getFormFields()`` describes each form elements (and their order in the form). Some :ref:`defaults are provided <defaultfields>`, this is is good idea to cal ``parent::getFormFields()`` when overrided,
* ``cleanFormFields()`` (optional) clean form fields that are not present in the database,
* ``getFormHiddenFields()`` list of fields that would be hidden,
* ``getFormFieldsToDrop()`` list of fields that should not be present at all on the form (but has been retrieved from database),
* ``buildFormElements()`` is used on each element to get its configuration

.. note::

   Almost all of the above methods do provide useful default values. Do not forget to call the parent method if you want to override!

Here a short explanation of the process:

#. fields are loaded from the table columns,
#. load fields configuration,
#. elements to drop are handled,
#. for each database column, a form element is built,
#. if any mapping configuration is set in :ref:`fields mapping <mapped_fields>`, it will be handled.

Based on field names, the form builder will automatically guess some configuration for you:

* any field name containing 'date' will be configured with a date picker,
* any foreign key field (name ends with ``_id`` or contains ``_id_``) will be configured as an ajax dropdown, label will be retrieved from the Object, `add` and `list` buttons will be added. For locations, the `map` button will be added as well,
* fields names containing ``_cache`` will be set as hidden,
* fields names ``content`` and ``comment`` will be configured as textareas,
* fields names that begins with ``is_`` or contains ``_is_`` will be set to ``yesno``.

Form configuration
^^^^^^^^^^^^^^^^^^

When loading a `CommonDBTM form`, you'll work with something like:

.. code-block:: php

   <?php
   $form = [
      'columns'      => 2,
      'submit_label' => 'a label',
      'elements'     => [...]
   ];

.. note::

   In most of the cases, you will just have to set a little configuration for some fields; default form configuration will be set with all you may need (including correct action target, CSRF, and so on).

.. _defaultfields:

Fields configuration
^^^^^^^^^^^^^^^^^^^^

Some fields are common to a large variety of objects ``CommonDBTM::getFormFields()`` provide configuration for. This includes as example ``name``, ``serial``, ``comment``, .... For all other fields, you will have to provide at least a `label`, among others.
Nothing is really required, but per default, you'll obtain a simple HTML input element with column name as label.

Here is an example of form element for a name, a location and a serial (as currently used in `Computer`):

.. code-block:: php

   <?php
   $elements = [
      'name' => [
         'label'           => 'Name',
         'type'            => 'text',
         'name'            => 'name',
         'autofocus'       => false
      ],
      'locations_id' => [
         'label'           => 'Location'
         'type'            => 'location',
         'name'            => 'locations_id',
         'autofocus'       => false,
         'itemtype'        => 'Location',
         'itemtype_name'   => 'Locations',
         'values'          => [] //wil be loaded from ajax
      ],
      'serial' => [
         'label'           => 'Serial',
         'autofill'        => true,
         'type'            => 'text',
         'name'            => 'serial',
         'autofocus'       => false
      ]
   ];

The key is the element unique identifier. It must be unique in each form.
Possible element configurations values are:

* ``type`` will be used to retrieve the relevant template (``templates/elements/{type}.twig``). Types that are currently available:

   * ``text`` (``input@type="text"``),
   * ``number`` (``input@type="number"``),
   * ``textarea``(``textarea``),
   * ``hidden``(``input@type="hidden"``),
   * ``password``(``input@type="password"``),
   * ``date``(``input@type="date"``, date chooser component),
   * ``checkbox``(``input@type="checkbox"``),
   * ``select`` (``select``),
   * ``location`` (``select`` with map component),
   * ``submit`` (``input@type="submit"``),
   * ``button`` (``button``),
   * ``link`` (link to a related ``itemtype``/``items_id``),
   * ``yesno`` (yes or no ``select``),
   * ``colorpicker`` (``input@type="color"``)
   * ``delete`` a delete (`trashbin` button),
   * ``purge`` a purge button with its confirmation checkbox

* ``label`` field label

   * either a simple text value to display as label,
   * or an array with the possible following elments:

      * ``title`` (``label@title``),
      * ``columns`` (``label@class=col-sm-{columns}``, defaults to 4),
      * ``class`` (extra value for ``label@class``),
      * ``label`` (``label`` content, mandatory).

* ``name`` field name,
* ``autofocus`` would field receive focus? Should be automatically set on the first form element,
* ``itemtype`` the item type, used for dropdowns,
* ``itemtype_name`` item type texat name, used for dropdowns,
* ``values`` element values, used for dropdowns,
* ``autofill`` field that can be autofilled on expression basis,
* ``required`` (``input@required="required"``),
* ``columns`` (``input@class=col-sm-{columns}``, defaults to 8),
* ``preicons`` an array of `fa-icons` to be used inside the input,
* ``htmltype`` (``input@type={htmltype}``, defaults to text),
* ``value`` (``input@value={value}``, ``textarea/{value}``, ``button/{value}``),
* ``readonly`` (``input@readonly="readonly"``),
* ``disabled`` (``input@readonly="disabled"``),
* ``title`` (``input@title={title}``, tooltip module),
* ``class`` (``input@class={class}``, default to ``form-control``),
* ``autocomplete`` (``input@autocomplete={autocomplete}``),
* ``size`` (``input@size={size}``),
* ``checked`` (``input@checked="checked"`` for ``checkbox`` type only),
* ``placeholder (``input@placeholder``),
* ``data`` (``input@data-{data-keys}={data-values}``, an array of key/values to be added as data attributes),
* ``message`` (extra message to be shown),
* ``fieldset`` group into fieldsets

All those capabilities are not usefull by default, or may be forced (no hidden field can be marked as `required` nor `disabled`: this is overrided from ``hidden.twig``).

Here are a few extra capabilities available per type:

For dropdowns:

* ``noajax`` will prevent dropdown to be loaded from an ajax call (closed lists),
* ``values`` an array of values used. You can use simple key/value pairs, or add an extra level for an optgroup (whose key will be used a label),
* ``change_func`` javascript callback function used on element change,
* ``empty_value`` label to use for empty value (no empty value if not set),
* ``listcion`` and ``addicon``: set them to false to hide list and add buttons.

For passwords:

* ``clear`` will add a checkbox that can be used to clear passord in database. Default to false.

For numbers:

* ``min_value`` (``input@min="{min_value}"``) minimum allowed value,
* ``max_value`` (``input@max="{max_value}"``) maximum allowed value,
* ``step_value`` (``input@step="{step_value}"``) step.

For purge:

* ``with_check`` set to false to not require user confirmation, checkbox will not be displayed,
* ``with_restore`` set to false to not display restore button.


Fieldsets
^^^^^^^^^

By default, all form elements will take place in a single fieldset. If you want to use several fieldsets inside your form, you will have to use the ``fieldset`` entry from the field configuration to tag your elements. Then you have to use the ``getFieldsets()`` method to declare your fieldsets:

.. code-block:: php

   <?php

   public function getFieldsets() :array {
      return [
        'one' => [
           'title'    => 'Fieldset legend',
           'elements' => [] //will be populated from tagged fields
        ]
      ];
   }

In the above example, we create a fieldset named `one`. Available options for fieldset declaration are:

* ``title`` that will be displayed as ``fieldset/legend``,
* ``subtitle`` (optional) will be shown along with the legend to provide extra informations,
* ``elements`` will be automatically populated in the ``getForm`` method with fields tagged with current fieldset.

If a fieldset is tagged in any element but does not exists, a warning will be displayed in logs.

Fields mapping
^^^^^^^^^^^^^^

By default, any form element represents a database column, and will be handled separately from all others. In some cases, you may want to get several database columns in order to display only one form element.

Let's say when we want to display an itemtype link. We'll need ``itemtype`` and ``items_id`` (following example is based on ``ItemDisk`` configuration and use ``templates/elements/link.twig`` template)

In order to handle that case, we will add a mapping in our object's constructor:

.. code-block:: php

   <?php

   public function __construct()
   {
       $this->mapped_fields = [
         'item' => [
            'itemtype',
            'items_id'
         ]
       ];
   }

In the above block of code, we add a field named ``item`` in our form. Data from ``itemtype`` and ``items_id`` columns wil be available to the template.

.. warning::

   We're adding a field that do not exists in database. Calling ``cleanFormFields()`` methods in local ``getFormFields()`` would remove it.

Then, we'll configure our element, to give it a label, and set the type properly:

.. code-block:: php

   <?php

   protected function getFormFields() {
      $fields = [
         //
         'item' => [
            'label'  => __('Item'),
            'type'   => 'link'
         ],
         //
      ] + parent::getFormFields();
      return $fields;
   }

Here is a full example of specific form configuration for ``ItemDisk``:

.. code-block:: php

   <?php

   protected function getFormFields() {
      $fields = [ 
         'name'     => [
            'label'  => __('Name')
         ],
         'item' => [
            'label'  => __('Item'),
            'type'   => 'link'
         ],
         'device'   => [
            'label'  => __('Partition')
         ],
         'mountpoint'     => [
            'label'  => __('Mount point')
         ],
         'filesystems_id' => [
            'label'  => __('File system')
         ],
         'totalsize'   => [
            'label'     => __('Global size'),
            'htmltype'  => 'number'
         ],
         'freesize'   => [
            'label'     => __('Free size'),
            'htmltype'  => 'number'
         ],
         'encryption_status' => [
             'label'    => __('Encryption status'),
             'type'     => 'select',
             'values'   => $this->getAllEncryptionStatus(),
             'listicon' => false,
             'addicon'  => false
         ],
         'encryption_tool' => [
             'label'  => __('Encryption tool')
         ],
         'encryption_algorithm' => [
            'label' => __('Encryption algorithm')
         ],
         'encryption_type' => [
            'label' => __('Encryption type')
         ]
      ] + parent::getFormFields();
      return $fields;
   }

