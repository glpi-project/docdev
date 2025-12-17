Rules Engine
------------

GLPI provide a set of tools to implements a rule engine which take ``criteria`` in input and output ``actions``. ``criteria`` and ``actions`` are defined by the user (and/or predefined at the GLPI installation).

Here is the list of base rules set provided in a staple GLPI:

* **ruleimportentity**: rules for assigning an item to an entity,
* **ruleimportcomputer**: rules for import and link computers,
* **rulemailcollector**: rules for assigning a ticket created through a mails receiver,
* **ruleright**: authorizations assignment rules,
* **rulesoftwarecategory**: rules for assigning a category to software,
* **ruleticket**: business rules for ticket.

Plugin could add their own set of rules.

Classes
^^^^^^^

A rules system is represented by these base classes:

* ``Rule`` class

    Parent class for all Rule* classes.
    This class represents a single rule (matching a line in ``glpi_rules`` table) and include test, process, display for an instance.

* ``RuleCollection`` class

    Parent class for all ``Rule*Collection`` classes.

    This class represents the whole collection of rules for a ``sub_type`` (matching all line in ``glpi_rules`` table for this ``sub_type``) and includes some method to process, duplicate, test and display the full collection.

* ``RuleCriteria`` class

    This class permits to manipulate a single criteria (matching a line in ``glpi_rulecriterias`` table) and include methods to display and match input values.

* ``RuleAction`` class

    This class permits to manipulate a single action (matching a line in ``glpi_ruleactions`` table) and include methods to display and process output values.

And for each ``sub_type`` of rule:

* ``RuleSubtype`` class

    Define the specificity of the ``sub_type`` rule like list of criteria and actions or how to display specific parts.

* ``RuleSubtypeCollection`` class

    Define the specificity of the ``sub_type`` rule collection like the preparation of input and the tests results.

Database Model
^^^^^^^^^^^^^^

Here is the list of important tables / fields for rules:

* ``glpi_rules``:

    All rules for all ``sub_types`` are inserted here.

    - **sub_type**: the type of the rule (ruleticket, ruleright, etc),
    - **ranking**: the order of execution in the collection,
    - **match**: define the link between the rule's criteria. Can be AND or OR,
    - **uuid**: unique id for the rule, useful for import/export in xml,
    - **condition**: addition condition for the ``sub_type`` (only used by ruleticket for defining the trigger of the collection on add and/or update of a ticket).

* ``glpi_rulecriterias``:

    Store all criteria for all rules.

    - **rules_id**: the foreign key for glpi_rules,
    - **criteria**: one of the key defined in the ``RuleSubtype::getCriterias()`` method,
    - **condition**: an integer matching the constant set in ``Rule`` class constants,
    - **pattern**: the direct value or regex to compare to the criteria.

* ``glpi_ruleactions``:

    Store all actions for all rules.

    - **rules_id**: the foreign key for glpi_rules,
    - **action_type**: the type of action to apply on the input. See ``RuleAction::getActions()``,
    - **field**: the field to alter by the current action. See keys definition in ``RuleSubtype::getActions()``,
    - **value**: the value to apply in the field.

Add a new Rule class
^^^^^^^^^^^^^^^^^^^^

Here is the minimal setup to have a working set.
You need to add the following classes for describing you new ``sub_type``.

* ``src/RuleMytype.php``

.. code-block:: php

    <?php

    class RuleMytype extends Rule {

        // optional right to apply to this rule type (default: 'config'), see Rights management.
        static $rightname = 'rule_mytype';

        // define a label to display in interface titles
        function getTitle() {
            return __('My rule type name');
        }

        // return an array of criteria
        // default type can be found under Rule::getCriteriaDisplayPattern
        function getCriterias() {
            $criterias = [
                '_users_id_requester' => [
                    'field'     => 'name',
                    'name'      => __('Requester'),
                    'table'     => 'glpi_users',
                    'type'      => 'dropdown',
                ],

                'GROUPS'              => [
                    'table'     => 'glpi_groups',
                    'field'     => 'completename',
                    'name'      => sprintf(__('%1$s: %2$s'), __('User'),
                                          __('Group'));
                    'linkfield' => '',
                    'type'      => 'dropdown',
                    'virtual'   => true,
                    'id'        => 'groups',
                ],

                ...

            ];

            return $criterias;
        }

        // return an array of actions
        function getActions() {
            $actions = [
                'entities_id' => [
                    'name'  => __('Entity'),
                    'type'  => 'dropdown',
                    'table' => 'glpi_entities',
                ],

                ...

            ];

            return $actions;
        }
    }

* ``src/RuleMytypeCollection.php``

.. code-block:: php

    <?php

    class RuleMytypeCollection extends RuleCollection {
        // a rule collection can process all rules for the input or stop
        //after a single match with its criteria (default false)
        public $stop_on_first_match = true;

        // optional right to apply to this rule type (default: 'config'),
        //see Rights management.
        static $rightname = 'rule_mytype';

        // menu key to use with Html::header in front page.
        public $menu_option = 'myruletype';

        // define a label to display in interface titles
        function getTitle() {
            return return __('My rule type name');
        }

        // if we need to change the input of the object before passing
        //it to the criteria.
        // Example if the input couldn't directly contains a criteria
        //and we need to compute it before (GROUP)
        function prepareInputDataForProcess($input, $params) {
            $input['_users_id_requester'] = $params['_users_id_requester'];
            $fields = $this->getFieldsToLookFor();

            //Add all user's groups
            if (in_array('groups', $fields)) {
                foreach (Group_User::getUserGroups($input['_users_id_requester']) as $group) {
                    $input['GROUPS'][] = $group['id'];
                    }
                }
            }

            ...

            return $input;
        }
    }

You need to also add the following php files for list and form:

* ``front/rulemytype.php``

.. code-block:: php

    <?php
    include ('../inc/includes.php');
    $rulecollection = new RuleMytypeCollection($_SESSION['glpiactive_entity']);
    include (GLPI_ROOT . "/front/rule.common.php");

* ``front/rulemytype.form.php``

.. code-block:: php

    <?php
    include ('../inc/includes.php');
    $rulecollection = new RuleMytypeCollection($_SESSION['glpiactive_entity']);
    include (GLPI_ROOT . "/front/rule.common.form.php");


And add the rulecollection in ``$CFG_GLPI`` (Only for **Core** rules):

* ``inc/define.php``

.. code-block:: php

    <?php

    ...

    $CFG_GLPI["rulecollections_types"] = [
      'RuleImportEntityCollection',
      'RuleImportComputerCollection',
      'RuleMailCollectorCollection',
      'RuleRightCollection',
      'RuleSoftwareCategoryCollection',
      'RuleTicketCollection',
      'RuleMytypeCollection' // <-- My type is added here
   ];


Plugin instead must declare it in :ref:`their init function <plugins_setupphp>`:

* ``plugin/myplugin/setup.php``

.. code-block:: php

    <?php
        function plugin_init_myplugin() {
            ...

            $Plugin->registerClass(
               'PluginMypluginRuleMytypeCollection',
               ['rulecollections_types' => true]
            );

            ...

        }

Apply a rule collection
^^^^^^^^^^^^^^^^^^^^^^^

To call your rules collection and alter the data:

.. code-block:: php

   <?php

   ...

   $rules  = new PluginMypluginRuleMytypeCollection();

   // data send by a form (which will be compared to criteria)
   $input  = [...];
   // usually = $input, but it could differ if you want to avoid comparison of
   //some fields with the criteria.
   $output = [...];
   // array passed to the prepareInputDataForProcess function of the collection
   //class (if you need to add conditions)
   $params = [];

   $output = $rules->processAllRules(
      $input,
      $output,
      $params
   );

Test for rule collection
^^^^^^^^^^^^^^^^^^^^^^^^
.. versionchanged:: 11.0.5 plugin and core RuleCollection can change the test path by overriding the ``RuleCollection::getRulesTestURL`` function.

For plugins, there is currently no GenericController so you must implement it.

Here is the minimal setup:

.. code-block:: php

    <?php

    namespace GlpiPlugin\MyPlugin\Controller;

    use Glpi\Controller\AbstractController;
    use Symfony\Component\HttpFoundation\Request;
    use Symfony\Component\HttpFoundation\Response;
    use Symfony\Component\Routing\Attribute\Route;

    final class RuleTestController extends AbstractController
    {
        #[Route(
            "/rules/test", // /front/rulesengine.test.php for version previous to 11.0.5
            name: "rule_myplugin_test",
            methods: ["GET"],
        )]
        public function __invoke(Request $request): Response
        {
            // No generic RuleTestController controller for now
            include(GLPI_ROOT . "/front/rulesengine.test.php");
            return new Response();
        }
    }


Dictionaries
^^^^^^^^^^^^

They inherits ``Rule*`` classes but have some specificities.

A dictionary aims to modify on the fly data coming from an external source (CSV file, inventory tools, etc.). It applies on an itemtype, as defined in the ``sub_type`` field of the ``glpi_rules`` table.

As the classic rules aim to apply additional and multiple data to input, dictionaries generally used to alter a single field (relative to the their ``sub_type``). Ex, ``RuleDictionnaryComputerModel`` alters ``model`` field of ``glpi_computers``.

Some exceptions exists and provide multiple actions (Ex: ``RuleDictionnarySoftware``).

As they are shown in a separate menu, you should define they in a separate ``$CFG_GLPI`` entry in ``inc/define.php``:

.. code-block:: php

    <?php

    ...

    $CFG_GLPI["dictionnary_types"] = array('ComputerModel', 'ComputerType', 'Manufacturer',
                                           'MonitorModel', 'MonitorType',
                                           'NetworkEquipmentModel', 'NetworkEquipmentType',
                                           'OperatingSystem', 'OperatingSystemServicePack',
                                           'OperatingSystemVersion', 'PeripheralModel',
                                           'PeripheralType', 'PhoneModel', 'PhoneType',
                                           'Printer', 'PrinterModel', 'PrinterType',
                                           'Software', 'OperatingSystemArchitecture',
                                           'RuleMytypeCollection' // <-- My type is added here
                                           );

.. _custom_rule_actions:

Example: Adding Custom Actions with Customized display
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example, we will add a ``_send_message`` action that:

1.  Uses a **textarea** for input (instead of a standard text field).
2.  Forces the action type to **"Send"**.
3.  Limits input to 255 characters.

1. Define the Action
''''''''''''''''''''

In your Rule class (e.g., ``TicketRule``), override the ``getActions()`` method. Define your custom action and use ``force_actions`` to associate it with a specific action operator (like ``send``).

.. code-block:: php

    <?php

    ...

    public function getActions()
    {
        $actions = parent::getActions();

        $actions['_send_message'] = [
            'type'          => 'textarea', // Custom type we will handle manually
            'name'          => __('Send a short text message', 'myplugin'),
            'force_actions' => ['send'],   // Force the 'Send' action operator, name can be found in RuleAction::getActions
        ];

        return $actions;
    }

2. Customize the Display
''''''''''''''''''''''''

Override ``displayAdditionalRuleAction()`` to render your custom input field. This method allows you to output raw HTML (or use GLPI helpers) when your custom type is detected.

.. code-block:: php

    <?php

    ...

    #[Override]
    public function displayAdditionalRuleAction(array $action, $value = '')
    {
        if ($action['type'] === 'textarea') {
            // Render a textarea with a character limit
            echo "<textarea class='form-control' name='value' rows='4' maxlength='255'>" . htmlescape($value) . "</textarea>";
            // use the following if you don't need to limit the field maxlength
            // Html::textarea(['name' => 'value', 'value' => $value, 'display' => true, 'rows' => 4]);
            return true;
        }
        return false;
    }

3. Handle the Execution Logic
'''''''''''''''''''''''''''''

By default, GLPI might not handle your custom field or the "Send" action type for assignment. Override ``executeActions()`` to manually handle the value.

.. code-block:: php

    <?php

    ...

    #[Override]
    public function executeActions($output, $params, array $input = [])
    {
        if (count($this->actions)) {
            foreach ($this->actions as $action) {
                // Intercept our specific field and action type
                if ($action->fields["field"] == '_send_message' && $action->fields["action_type"] == 'send') {
                    // Manually assign the value to the output
                    $output[$action->fields["field"]] = $action->fields["value"];
                }
            }
        }
        return parent::executeActions($output, $params, $input);
    }
