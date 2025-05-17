Hooks
-----

GLPI provides over 130 "hooks". Their goal is for plugins to be able to expand functionality of GLPI and react to specific events; like when an item has been added, updated, deleted, etc.
The hooks are primarily interacted with through the "$PLUGIN_HOOKS" global array from the plugin's ``init`` function.
Some hooks though are automatically called if a specific function exists in the plugin's ``hook.php`` file.

This page describes the different currently existing hooks. For more information about plugin development, please refer to the plugins development documentation.

Hooks
#####
ADD_CSS
*******

Add CSS file in the head of all non-anonymous pages.



ADD_JAVASCRIPT
**************

Add classic JavaScript file in the head of all non-anonymous pages.



ADD_JAVASCRIPT_MODULE
*********************

Add ESM JavaScript module in the head of all non-anonymous pages.


ADD_HEADER_TAG
**************

Add a header tag in the head of all non-anonymous pages.


JAVASCRIPT
**********

Register one or more on-demand JavaScript files.
On-demand JS files are loaded based on the `$CFG_GLPI['javascript']` array.
Example: `$PLUGIN_HOOKS[Hooks::JAVASCRIPT]['your_js_name'] = ['path/to/your/file.js'];`


ADD_CSS_ANONYMOUS_PAGE
**********************

Add CSS file in the head of all anonymous pages.


ADD_JAVASCRIPT_ANONYMOUS_PAGE
*****************************

Add classic JavaScript file in the head of all anonymous pages.


ADD_JAVASCRIPT_MODULE_ANONYMOUS_PAGE
************************************

Add ESM JavaScript module in the head of all anonymous pages.


ADD_HEADER_TAG_ANONYMOUS_PAGE
*****************************

Add a header tag in the head of all anonymous pages.


CHANGE_ENTITY
*************

Register a function to be called when the entity is changed.


CHANGE_PROFILE
**************

Register a function to be called when the profile is changed.


DISPLAY_LOGIN
*************

Register a function to output some content on the login page.


DISPLAY_CENTRAL
***************

Register a function to output some content on the standard (central) or simplified interface (helpdesk) home page.
This hook is called inside a table element.


DISPLAY_NETPORT_LIST_BEFORE
***************************

Register a function to output some content before the network port list.


INIT_SESSION
************

Register a function to be called when the session is initialized.


POST_INIT
*********

Register a function to be called after all plugins are initialized.


CONFIG_PAGE
***********

Register a URL relative to the plugin's root URL for the plugin's config page.


USE_MASSIVE_ACTION
******************

Set to true if the plugin wants to use the Hooks::AUTO_MASSIVE_ACTIONS hook.
Example: $PLUGIN_HOOKS[Hooks::USE_MASSIVE_ACTION]['myplugin'] = true;


ASSIGN_TO_TICKET
****************

Set to true if the plugin wants to use the Hooks::AUTO_ASSIGN_TO_TICKET hook.
Example: $PLUGIN_HOOKS[Hooks::ASSIGN_TO_TICKET]['myplugin'] = true;


IMPORT_ITEM
***********

Set to true if the plugin can import items. Adds the plugin as a source criteria for 'Rules for assigning an item to an entity'


RULE_MATCHED
************

Register a function to be called when the rules engine matches a rule.
The function is called with an array containing several properties including:
* 'sub_type' => The subtype of the rule (Example: RuleTicket)
* 'ruleid' => The ID of the rule
* 'input' => The input data sent to the rule engine
* 'output' => The current output data
The function is not expected to return anything and the data provided to it cannot be modified.


VCARD_DATA
**********

Register a function to be called when a vCard is generated.
The function is called with an array containing several properties including:
* 'item' => The item for which the vCard is generated
* 'data' => The vCard data
The function is expected to modify the given array as needed and return it.


POST_PLUGIN_DISABLE
*******************

Register a function to be called when the plugin is disabled.
The function is called with the plugin name as a parameter.


POST_PLUGIN_CLEAN
*****************

Register a function to be called when the plugin is cleaned from the database.
The function is called with the plugin name as a parameter.


POST_PLUGIN_INSTALL
*******************

Register a function to be called when the plugin is installed.
The function is called with the plugin name as a parameter.


POST_PLUGIN_UNINSTALL
*********************

Register a function to be called when the plugin is uninstalled.
The function is called with the plugin name as a parameter.


POST_PLUGIN_ENABLE
******************

Register a function to be called when the plugin is enabled.
The function is called with the plugin name as a parameter.


DISPLAY_LOCKED_FIELDS
*********************

Register a function to be called to show locked fields managed by the plugin.
The function is called with an array containing several properties including:
* 'item' => The item for which the locked fields are shown
* 'header' => Always false. //TODO WHY!?


PRE_KANBAN_CONTENT
******************

Register a function to define content to show before the main content of a Kanban card.
This function is called with an array containing several properties including:
* 'itemtype' => The type of the item represented by the Kanban card
* 'items_id' => The ID of the item represented by the Kanban card
The function is expected to return HTML content.


POST_KANBAN_CONTENT
*******************

Register a function to define content to show after the main content of a Kanban card.
This function is called with an array containing several properties including:
* 'itemtype' => The type of the item represented by the Kanban card
* 'items_id' => The ID of the item represented by the Kanban card
The function is expected to return HTML content.


KANBAN_ITEM_METADATA
********************

Register a function to redefine metadata for a Kanban card.
This function is called with an array containing several properties including:
* 'itemtype' => The type of the item represented by the Kanban card
* 'items_id' => The ID of the item represented by the Kanban card
* 'metadata' => The current metadata for the Kanban card
The function is expected to modify the given array as needed and return it.


KANBAN_FILTERS
**************

Define extra Kanban filters by itemtype.
Example:
```
$PLUGIN_HOOKS[Hooks::KANBAN_FILTERS]['myplugin'] = [
    'Ticket' => [
        'new_metadata_property' => [
            'description' => 'My new property'
            'supported_prefixes' => ['!']
        ]
    ]
]
```


PRE_KANBAN_PANEL_CONTENT
************************

Register a function to display content at the beginning of the item details panel in the Kanban.
The function is called with an array containing several properties including:
* 'itemtype' => The type of the item represented by the Kanban card
* 'items_id' => The ID of the item represented by the Kanban card
The function is expected to return HTML content.



POST_KANBAN_PANEL_CONTENT
*************************

Register a function to display content at the end of the item details panel in the Kanban.
The function is called with an array containing several properties including:
* 'itemtype' => The type of the item represented by the Kanban card
* 'items_id' => The ID of the item represented by the Kanban card
The function is expected to return HTML content.



PRE_KANBAN_PANEL_MAIN_CONTENT
*****************************

Register a function to display content at the beginning of the item details panel in the Kanban after the content from Hooks::PRE_KANBAN_PANEL_CONTENT but before the default main content.
The function is called with an array containing several properties including:
* 'itemtype' => The type of the item represented by the Kanban card
* 'items_id' => The ID of the item represented by the Kanban card
The function is expected to return HTML content.



POST_KANBAN_PANEL_MAIN_CONTENT
******************************

Register a function to display content at the end of the item details panel in the Kanban after the default main content but before the content from Hooks::POST_KANBAN_PANEL_CONTENT.
The function is called with an array containing several properties including:
* 'itemtype' => The type of the item represented by the Kanban card
* 'items_id' => The ID of the item represented by the Kanban card
The function is expected to return HTML content.



REDEFINE_MENUS
**************

Register a function to redefine the GLPI menu.
The function is called with the current menu as a parameter.
The function is expected to modify the given array as needed and return it.



RETRIEVE_MORE_DATA_FROM_LDAP
****************************

Register a function to get more user field data from LDAP.
The function is called with an array containing the current fields for the user along with:
* '_ldap_result' => The LDAP query result
* '_ldap_conn' => The LDAP connection resource
The function is expected to modify the given array as needed and return it.


RETRIEVE_MORE_FIELD_FROM_LDAP
*****************************

Register a function to get more LDAP -> Field mappings.
The function is called with an array containing the current mappings.
The function is expected to modify the given array as needed and return it.



RESTRICT_LDAP_AUTH
******************

Register a function to add additional checks to the LDAP authentication.
The function is called with an array containing several properties including:
* 'dn' => The DN of the user
* login field => Login field value where 'login field' is the name of the login field (usually samaccountname or uid) set in the LDAP config in GLPI.
* sync field => Sync field value where 'sync field' is the name of the sync field (usually objectguid or entryuuid) set in the LDAP config in GLPI


UNLOCK_FIELDS
*************

Register a function to handle unlocking additional fields.
The function is called with the $_POST array containing several properties including:
* 'itemtype' => The type of the item for which the fields are unlocked
* 'id' => The ID of the item for which the fields are unlocked
* itemtype => Array of fields to unlock where 'itemtype' is the name of the item type (usually the same as the itemtype value).
The function is expected to return nothing.


UNDISCLOSED_CONFIG_VALUE
************************

Register a function to optionally hide a config value in certain locations such as the API.
The function is called with an array containing several properties including:
* 'context' => The context of the config option ('core' for core GLPI configs)
* 'name' => The name of the config option
* 'value' => The value of the config option
The function is expected to modify the given array as needed (typically unsetting the value if it should be hidden) and return it.


FILTER_ACTORS
*************

Register a function to modify the actor results in the right panel of ITIL objects.
The function is called with an array containing several properties including:
* 'actors' => The current actor results
* 'params' => The parameters used to retrieve the actors
The function is expected to modify the given array as needed and return it.


DEFAULT_DISPLAY_PREFS
*********************

Register a function to declare what the default display preferences are for an itemtype.
This is not used when no display preferences are set for the itemtype, but rather when hte preferences are being reset.
Therefore, defaults should be set during the plugin installation and the result of the function should be the same as the default values set in the plugin installation.
Core GLPI itemtypes with display preferences set in `install/empty_data.php` will never use this hook.
The function is called with an array containing several properties including:
* 'itemtype' => The type of the item for which the display preferences are set
* 'prefs' => The current defaults (usually empty unless also modified by another plugin)
The function is expected to modify the given array as needed and return it.


USE_RULES
*********

Must be set to true for some other hooks to function including:
* Hooks::AUTO_GET_RULE_CRITERIA
* Hooks::AUTO_GET_RULE_ACTIONS
* Hooks::AUTO_RULE_COLLECTION_PREPARE_INPUT_DATA_FOR_PROCESS
* Hooks::AUTO_PRE_PROCESS_RULE_COLLECTION_PREVIEW_RESULTS
* Hooks::AUTO_RULEIMPORTASSET_GET_SQL_RESTRICTION
* Hooks::AUTO_RULEIMPORTASSET_ADD_GLOBAL_CRITERIA


ADD_RECIPIENT_TO_TARGET
***********************

Register a function to be called when a notification recipient is to be added.
The function is called with the NotificationTarget object as a parameter.
The function is expected to return nothing.
The added notification target information can be found in the `recipient_data` property of the object. Modifying this information will have no effect.
The current list of all added notification targets can be found in the `target` property of the object.
If you wish to remove/modify targets, you must do so in the `target` property.


AUTOINVENTORY_INFORMATION
*************************

Register a function to be called to display some automatic inventory information.
The function is called with the item as a parameter.
The function is expected to return nothing, but the information may be output directly.
The function is only called for items that have the `is_dynamic` field, and it is set to 1.


INFOCOM
*******

Register a function to be called to display extra Infocom form fields/information.
The function is called with the item as a parameter.
The function is expected to return nothing, but the information may be output directly.


ITEM_ACTION_TARGETS
*******************

Register a function to handle adding a plugin-specific notification target.
The function is called with the NotificationTarget object as a parameter.
The function is expected to return nothing.
The notification target data can be found in the `data` property of the object.



ITEM_ADD_TARGETS
****************

Register a function to handle adding new possible recipients for notification targets.
The function is called with the NotificationTarget object as a parameter.
The function is expected to return nothing.



ITEM_EMPTY
**********

Register a function to handle the 'item_empty' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
The hook is called at the very end of the process of initializing an empty item.



PRE_ITEM_ADD
************

Register a function to handle the 'pre_item_add' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very beginning of the add process, before the input has been modified.
The input can be found in the `input` property of the item. Setting the `input` property to false will cancel the add process.



POST_PREPAREADD
***************

Register a function to handle the 'post_prepareadd' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called after the input has been modified, but before the item is added to the database.
The input can be found in the `input` property of the item. Setting the `input` property to false will cancel the add process.



ITEM_ADD
********

Register a function to handle the 'item_add' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very end of the add process, after the item has been added to the database.


PRE_ITEM_UPDATE
***************

Register a function to handle the 'pre_item_update' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very beginning of the update process, before the input has been modified.
The input can be found in the `input` property of the item. Setting the `input` property to false will cancel the update process.



ITEM_UPDATE
***********

Register a function to handle the 'item_update' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very end of the update process, after the item has been updated in the database.
The input can be found in the `input` property of the item while the updated field names can be found in the `updates` property.
The old values of changed field can be found in the `oldvalues` property.


PRE_ITEM_DELETE
***************

Register a function to handle the 'pre_item_delete' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very beginning of the soft-deletion process.
The input can be found in the `input` property of the item. Setting the `input` property to false will cancel the deletion process.


ITEM_DELETE
***********

Register a function to handle the 'item_delete' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very end of the soft-deletion process, after the item has been soft-deleted from the database (`is_deleted` set to 1).


PRE_ITEM_PURGE
**************

Register a function to handle the 'pre_item_purge' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very beginning of the purge process.
The input can be found in the `input` property of the item. Setting the `input` property to false will cancel the purge process.


ITEM_PURGE
**********

Register a function to handle the 'item_purge' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very end of the purge process, after the item has been purged from the database.


PRE_ITEM_RESTORE
****************

Register a function to handle the 'pre_item_restore' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very beginning of the restore process.
The input can be found in the `input` property of the item. Setting the `input` property to false will cancel the restore process.


ITEM_RESTORE
************

Register a function to handle the 'item_restore' lifecycle event for an item.
The function is called with the item as a parameter.
The function is expected to return nothing.
This hook is called at the very end of the restore process, after the item has been restored in the database (`is_deleted` set to 0).


ITEM_GET_DATA
*************

Register a function to handle adding data for a notification target.
The function is called with the NotificationTarget object as a parameter.
The function is expected to return nothing.
The notification target data can be found in the `data` property of the object.



ITEM_GET_EVENTS
***************

Register a function to handle adding events for a notification target.
The function is called with the NotificationTarget object as a parameter.
The function is expected to return nothing.
The notification target events can be found in the `events` property of the object.



SHOW_ITEM_STATS
***************

Register a function to show additional statistics in the Statistics tab of Tickets, Changes and Problems.
The function is called with the item as a parameter.
The function is expected to return nothing, but the information may be output directly.


ITEM_CAN
********

Register a function to add additional permission restrictions for the item.
The function is called with the item as a parameter.
The function is expected to return nothing.
The permission being checked can be found in the `right` property of the item.
The input used to create, update or delete the item can be found in the `input` property of the item.
If you change the `right` property to any other value, it will be treated as a failed check. Take care when reading this property as it may have been changed by another plugin. If it isn't an integer greater than 0, you should assume the check already failed.


PRE_ITIL_INFO_SECTION
*********************

Register a function to show additional fields at the top of a Ticket, Change or Problem fields panel.
The function is called with the following parameters:
* 'item' => The item for which the fields are shown
* 'options' => An array of form parameters



POST_ITIL_INFO_SECTION
**********************

Register a function to show additional fields at the bottom of a Ticket, Change or Problem fields panel.
 The function is called with the following parameters:
 * 'item' => The item for which the fields are shown
 * 'options' => An array of form parameters



ITEM_TRANSFER
*************

Register a function to be called after an item is transferred to another entity.
The function is called with an array containing several properties including:
* 'type' => The type of the item being transferred.
* 'id' => The original ID of the item being transferred.
* 'newID' => The new ID of the item being transferred. If the item was cloned into the new entity, this ID will differ from the original ID.
* 'entities_id' => The ID of the destination entity.
The function is expected to return nothing.


PRE_SHOW_ITEM
*************

Register a function to be called before showing an item in the timeline of a Ticket, Change or Problem.
The function is called with the following parameters:
* 'item' => The item being shown in the timeline
* 'options' => An array containing the following properties:
  * 'parent' => The Ticket, Change or Problem
  * 'rand' => A random number that may be used for unique element IDs within the timeline item HTML
The function is expected to return nothing, but the information may be output directly.



POST_SHOW_ITEM
**************

Register a function to be called after showing an item in the timeline of a Ticket, Change or Problem.
The function is called with the following parameters:
* 'item' => The item being shown in the timeline
* 'options' => An array containing the following properties:
  * 'parent' => The Ticket, Change or Problem
  * 'rand' => A random number that may be used for unique element IDs within the timeline item HTML
The function is expected to return nothing, but the information may be output directly.



PRE_ITEM_FORM
*************

Register a function to show additional fields at the top of an item form.
The function is called with the following parameters:
* 'item' => The item for which the fields are shown
* 'options' => An array of form parameters
The function is expected to return nothing, but the information may be output directly.


POST_ITEM_FORM
**************

Register a function to show additional fields at the bottom of an item form.
The function is called with the following parameters:
* 'item' => The item for which the fields are shown
* 'options' => An array of form parameters
The function is expected to return nothing, but the information may be output directly.


PRE_SHOW_TAB
************

Register a function to show additional content before the main content in a tab.
This function is not called for the main tab of a form.
The function is called with the following parameters:
* 'item' => The item for which the tab is shown
* 'options' => An array containing the following properties:
  * 'itemtype' => The type of the item being shown in the tab
  * 'tabnum' => The number of the tab being shown for the itemtype
The function is expected to return HTML content or an empty string.


POST_SHOW_TAB
*************

Register a function to show additional content after the main content in a tab.
This function is not called for the main tab of a form.
The function is called with the following parameters:
* 'item' => The item for which the tab is shown
* 'options' => An array containing the following properties:
  * 'itemtype' => The type of the item being shown in the tab
  * 'tabnum' => The number of the tab being shown for the itemtype
The function is expected to return HTML content or an empty string.


PRE_ITEM_LIST
*************

Register a function to show additional content before the search result list for an itemtype.
The function is called with the following parameters:
* 'itemtype' => The type of the item being shown in the list
* 'options' => Unused. Always an empty array.
The function is expected to return nothing, but the information may be output directly.



POST_ITEM_LIST
**************

Register a function to show additional content after the search result list for an itemtype.
The function is called with the following parameters:
* 'itemtype' => The type of the item being shown in the list
* 'options' => Unused. Always an empty array.
The function is expected to return nothing, but the information may be output directly.



TIMELINE_ACTIONS
****************

Register a function to show action buttons in the footer of a Ticket, Change or Problem timeline.
This is how timeline actions were displayed before version 10.0, but now using the Hooks::TIMELINE_ANSWER_ACTIONS is the preferred way.
The function is called with the following parameters:
* 'item' => The item for which the actions are shown
* 'rand' => A random number that may be used for unique element IDs within the HTML
The function is expected to return nothing, but the information may be output directly.


TIMELINE_ANSWER_ACTIONS
***********************

Register a function to add new itemtypes to the answer/action split dropdown, and be made available to show in a Ticket, Change or Problem timeline.
The function is called with the following parameters:
* 'item' => The item for which the actions are shown
The function is expected to return an array of options to be added to the dropdown.
Each option should have a unique key and be an array with the following properties:
* 'type' => The type of the item to be used for the action. In some cases, this is a parent/abstract class such as ITILTask. This is used as a CSS class on the main timeline item element.
* 'class' => The actual type of the item to be used for the action such as TicketTask.
* 'icon' => The icon to be used for the action.
* 'label' => The label to be used for the action.
* 'short_label' => The short label to be used for the action.
* 'template' => The Twig template to use when showing related items in the timeline.
* 'item' => An instance of the related itemtype.
* 'hide_in_menu' => If true, the option is not available in the dropdown menu but the related items may still be shown in the timeline.


SHOW_IN_TIMELINE
****************

.. warning::\nDeprecated: 11.0.0 Use `TIMELINE_ITEMS` instead. The usage of both hooks is the same.\n


TIMELINE_ITEMS
**************

Register a function to add new items to the timeline of a Ticket, Change or Problem.
The function is called with the following parameters:
* 'item' => The item for which the actions are shown.
* 'timeline' => The array of items currently shown in the timeline. This is passed by reference.
The function is expected to modify the timeline array as needed.
The timeline item array contains arrays where the keys are typically "${itemtype}_${items_id}" and the values are arrays with the following properties:
* 'type' => The type of the item being shown in the timeline. This should match the 'class' property used in Hooks::TIMELINE_ANSWER_ACTIONS.
* 'item' => Array of information to pass to the 'template' used in Hooks::TIMELINE_ANSWER_ACTIONS, and notifications.


SET_ITEM_IMPACT_ICON
********************

Register a function to set the icon used by an item in the impact graph.
The function is called with the following parameters:
* 'itemtype' => The type of the item being shown in the graph
* 'items_id' => The ID of the item being shown in the graph
The function is expected to return a URL starting with a '/' relative to the GLPI root directory, or an empty string.


SECURED_FIELDS
**************

An array of database columns (example: glpi_mytable.myfield) that are stored using GLPI encrypting methods.
This allows plugin fields to be handled by the `glpi:security:changekey` command.
Added in version 9.4.6

SECURED_CONFIGS
***************

An array of configuration keys that are stored using GLPI encrypting methods.
This allows plugin configuration values to be handled by the `glpi:security:changekey` command.
Added in version 9.4.6

PROLOG_RESPONSE
***************



NETWORK_DISCOVERY
*****************



NETWORK_INVENTORY
*****************



INVENTORY_GET_PARAMS
********************



PRE_INVENTORY
*************


             You may modify the inventory data which is passed as a parameter (stdClass) and return the modified data.
             Returning null will cancel the inventory submission with no specific reason.
             Throwing an Exception will cancel the inventory submission with the exception message as the reason.
             To avoid unrelated exception messages from being sent to the agent, you must handle all exceptions (except the one you would throw to cancel the inventory) within the hook function.


POST_INVENTORY
**************


             You may view the inventory data which is passed as a parameter (stdClass).
             Nothing is expected to be returned.
             This hook is only called if the inventory submission was successful.


HANDLE_INVENTORY_TASK
*********************



HANDLE_NETDISCOVERY_TASK
************************



HANDLE_NETINVENTORY_TASK
************************



HANDLE_ESX_TASK
***************



HANDLE_COLLECT_TASK
*******************



HANDLE_DEPLOY_TASK
******************



HANDLE_WAKEONLAN_TASK
*********************



HANDLE_REMOTEINV_TASK
*********************



STALE_AGENT_CONFIG
******************

Add new agent cleanup actions.
The hook is expected to be an array where each value is an array with the following properties:
* 'label' => The label to be used for the action.
* 'render_callback' => Callable used to display the configuration field. The callable will be called with the inventory configuration values array.
* 'action_callback' => Callable used to perform the action. The callable will be called with the following parameters:
  * 'agent' => The agent to be cleaned
  * 'config' => The inventory configuration values array
  * 'item' => The asset that the agent is for


MENU_TOADD
**********

Add menu items.
The hook is expected to be an array where the keys are identiifers for the top-level menu items, and the values are arrays with the following properties:
* 'types' => Array of item types to be added
* 'icon' => The icon for the top-level menu item which is expected to be a Tabler icon CSS class


HELPDESK_MENU_ENTRY
*******************

Add a menu item in the simplified interface.
The hook is expected to be a URL relative to the plugin's directory.


HELPDESK_MENU_ENTRY_ICON
************************

Add an icon for the menu item added with the Hooks::HELPDESK_MENU_ENTRY hook.
The hook is expected to be a Tabler icon CSS class.


DASHBOARD_CARDS
***************

Register a function to add new dashboard cards.
The function is called with no parameters.
The function is expected to return an array of dashboard cards.
Each key in the returned array should be a unique identifier for the card.
The value should be an array with the following properties (but not limited to):
* 'widgettype' => Array of widget types this card can use (pie, bar, line, etc)
* 'label' => The label to be used for the card
* 'group' => Group string to be used to organize the card in dropdowns
* 'filters' => An optional array of filters that can apply to this card


DASHBOARD_FILTERS
*****************

Add new dashboard filters.
The hook is expected to be an array of classes which extend Glpi\Dashboard\Filters\AbstractFilter.


DASHBOARD_PALETTES
******************

Add new dashboard color palettes.
The hook is expected to be an array where the keys are unique identifiers and the values are arrays of #rrggbb color strings.


DASHBOARD_TYPES
***************

Register a function to add new dashboard widget types.
The function is called with no parameters.
The function is expected to return an array where the keys are unique identifiers and the values are arrays with the following properties:
* 'label' => The label to be used for the widget type
* 'function' => A callable to be used to display the widget
* 'image' => The image to be used for the widget
* 'limit' => Indicate if the amount of data shown by the widget can be limited
* 'width' => The default width of cards using this widget
* 'height' => The default height of cards using this widget


REDEFINE_API_SCHEMAS
********************

The hook function to call to redefine schemas.
Each time a controller's schemas are retrieved, the hook is called with a $data parameter.
The $data parameter will contain the Controller class name in the 'controller' key and an array of schemas in the 'schemas' key.
The function should return the modified $data array.
The controller value should not be changed as it would result in undefined behavior.


API_CONTROLLERS
***************

This hook should provide an array of the plugin's API controller class names.


API_MIDDLEWARE
**************

This hook should provide an array of arrays containing a 'middlware' value that is the class name.
The middleware classes should extend HL_API\Middleware\AbstractMiddleware and
implement either {@link HL_API\Middleware\RequestMiddlewareInterface{ or HL_API\Middleware\ResponseMiddlewareInterface.
The arrays may also contain values for 'priority' and 'condition' where priority is an integer (higher is more important) and condition is a callable.
If a condition is provided, that callable will be called with the current controller as a parameter, and it must return true for the middleware to be used, or false to not be.


STATS
*****

Add new statistics reports.
The hook is expected to be an array where the keys are URLs relative to the plugin's directory and the values are the report names.


MAIL_SERVER_PROTOCOLS
*********************

Register a function to add new email server protocols.
The function is called with no parameters.
The function is expected to return an array where the keys are the protocol name and the values are arrays with the following properties:
* 'label' => The label to be used for the protocol.
* 'protocol' => The name of the class to be used for the protocol. The class should use the `Laminas\Mail\Protocol\ProtocolTrait` trait.
* 'storage' => The name of the class to be used for the protocol storage. The class should extend the `Laminas\Mail\Storage\AbstractStorage` class.


AUTO_MASSIVE_ACTIONS
********************

Automatic hook function to add new massive actions.
The function is called with the itemtype as a parameter.
The function is expected to return an array of massive action.
Only called if the plugin also uses the Hooks::USE_MASSIVE_ACTION hook set to true.


AUTO_MASSIVE_ACTIONS_FIELDS_DISPLAY
***********************************

Automatic hook function to display the form for the "update" massive action for itemtypes or search options related to the plugin.
The function is called with the following parameters:
* 'itemtype' => The type of the item for which the fields are shown
* 'options' => The search option array
The function is expected to return true if the display is handled, or false if the default behavior should be used.


AUTO_DYNAMIC_REPORT
*******************

Automatic hook function called to handle the export display of an itemtype added by the plugin.
The function is called with the $_GET array containing several properties including:
* 'item_type' => The type of the item for which the fields are shown
* 'display_type' => The numeric type of the display. See the constants in the `Search` class.
* 'export_all' => If all pages are being exported or just the current one.
The function is expected to return true if the display is handled, or false if the default behavior should be used.


AUTO_ASSIGN_TO_TICKET
*********************

Automatic hook function to add new itemtypes which can be linked to Tickets, Changes or Problems.
The function is called with the current array of plugin itemtypes allowed to be linked.
The function is expected to modify the given array as needed and return it.


AUTO_GET_DROPDOWN
*****************

Automatic hook function called to get additional dropdown classes which would be displayed in Setup > Dropdowns.
The function is called with no parameters.
The function is expected to return an array where the class names are in the keys or null. For the array values, anything can be used, but typically it is just `null`.


AUTO_GET_RULE_CRITERIA
**********************

Automatic hook function called with an array with the key 'rule_itemtype' set to the itemtype and 'values' set to the input sent to the rule engine.
The function is expected to return an array of criteria to add.
Only called if the plugin also uses the Hooks::USE_RULES hook set to true.



AUTO_GET_RULE_ACTIONS
*********************

Automatic hook function called with an array with the key 'rule_itemtype' set to the itemtype and 'values' set to the input sent to the rule engine.
The function is expected to return an array of actions to add.
Only called if the plugin also uses the Hooks::USE_RULES hook set to true.



AUTO_RULE_COLLECTION_PREPARE_INPUT_DATA_FOR_PROCESS
***************************************************

Only called if the plugin also uses the Hooks::USE_RULES hook set to true.


AUTO_PRE_PROCESS_RULE_COLLECTION_PREVIEW_RESULTS
************************************************

Only called if the plugin also uses the Hooks::USE_RULES hook set to true.


AUTO_RULEIMPORTASSET_GET_SQL_RESTRICTION
****************************************

Automatic hook function called with an array containing several criteria including:
* 'where_entity' => the entity to restrict
* 'input' => the rule input
* 'criteria' => the rule criteria
* 'sql_where' => the SQL WHERE clause as a string
* 'sql_from' => the SQL FROM clause as a string
The function is expected to modify the given array as needed and return it.
Only called if the plugin also uses the Hooks::USE_RULES hook set to true.


AUTO_RULEIMPORTASSET_ADD_GLOBAL_CRITERIA
****************************************

Automatic hook function called with an array of the current global criteria.
The function is expected to modify the given array as needed and return it.


AUTO_SEARCH_OPTION_VALUES
*************************

Automatic hook function to display the value field for a search option criteria.
The function is called with an array with the following properties:
* 'name' => The HTML input name expected.
* searchtype' => The search type of the criteria (contains, equals, etc).
* 'searchoption' => The search option array related to the criteria.
* 'value' => The current value of the criteria.
The function is expected to output HTML content if it customizes the value field and then return true. If the default behavior is desired, the function should not output anything and return false.


AUTO_ADD_PARAM_FOR_DYNAMIC_REPORT
*********************************

Automatic hook function to add URL parameters needed for a dynamic report/export.
The function is called with the itemtype as a parameter.
The function is expected to return a key/value array of parameters to add.


AUTO_ADD_DEFAULT_JOIN
*********************

Automatic hook function to add a JOIN clause to the SQL query for a search of itemtypes added by the plugin.
This can be a LEFT JOIN , INNER JOIN or RIGHT JOIN.
The function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
* 'reference_table' => The name of the reference table. This should be the table for the itemtype.
* 'already_link_table' => An array of tables that are already joined.
The function is expected to return a SQL JOIN clause as a string or an empty string if the default behavior should be used.


AUTO_ADD_DEFAULT_SELECT
***********************

Automatic hook function to add a SELECT clause to the SQL query for a searchof itemtypes added by the plugin.
The function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
The function is expected to return a SQL SELECT clause as a string or an empty string if the default behavior should be used.


AUTO_ADD_DEFAULT_WHERE
**********************

Automatic hook function to add a WHERE clause to the SQL query for a searchof itemtypes added by the plugin.
The function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
The function is expected to return a SQL WHERE clause as a string or an empty string if the default behavior should be used.


ADD_DEFAULT_JOIN
****************

Automatic hook function to add a JOIN clause to the SQL query for a search.
The function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
* 'join' => The current JOIN clause in the iterator format.
The function is expected to return the modified join array or an empty array if no join should be added.
 This function is called after the Hooks::AUTO_ADD_DEFAULT_JOIN hook and after the default joins are added.


ADD_DEFAULT_WHERE
*****************

Automatic hook function to add a WHERE clause to the SQL query for a search.
The function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
* 'criteria' => The current WHERE clause in the iterator format.
The function is expected to return the modified criteria array or an empty array if no criteria should be added.
This function is called after the Hooks::AUTO_ADD_DEFAULT_WHERE hook and after the default WHERE clauses are added.


AUTO_ADD_HAVING
***************

Automatic hook function to add a HAVING clause to the SQL query for a specific search criteria.
The function is called with the following parameters:
* 'link' => The linking operator (AND/OR) for the criteria.
* 'not' => Indicates if the criteria is negated.
* 'itemtype' => The type of the items being searched.
* 'search_option_id' => The ID of the search option of the criteria.
* 'search_value' => The value to search for.
* 'num' => A string in the form of "${itemtype}_{$search_option_id}". The alias of the related field in the SELECT clause will be "ITEM_{$num}".
The function is expected to return a SQL HAVING clause as a string or an empty string if the default behavior should be used.


AUTO_ADD_LEFT_JOIN
******************

Automatic hook function to add a JOIN clause to the SQL query for a specific search criteria.
Despite the name, this can be a LEFT JOIN , INNER JOIN or RIGHT JOIN.
The function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
* 'reference_table' => The name of the reference table. This is typically the table for the itemtype.
* 'new_table' => The name of the table to be joined. Typically, this is the table related to the search option.
* 'link_field' => The name of the field in the reference table that links to the new table.
* 'already_link_table' => An array of tables that are already joined.
The function is expected to return a SQL JOIN clause as a string or an empty string if the default behavior should be used.


AUTO_ADD_ORDER_BY
*****************

Automatic hook function to add an ORDER clause to the SQL query for a specific search criteria.
The function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
* 'search_option_id' => The ID of the search option of the criteria.
* 'order' => The order requested (ASC/DESC).
* 'num' => A string in the form of "${itemtype}_{$search_option_id}". The alias of the related field in the SELECT clause will be "ITEM_{$num}".
The function is expected to return a SQL ORDER clause as a string or an empty string if the default behavior should be used.


AUTO_ADD_SELECT
***************

Automatic hook function to add a SELECT clause to the SQL query for a specific search criteria.
The function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
* 'search_option_id' => The ID of the search option of the criteria.
* 'num' => A string in the form of "${itemtype}_{$search_option_id}". The alias of the related field in the clause returned should be "ITEM_{$num}".
The function is expected to return a SQL SELECT clause as a string or an empty string if the default behavior should be used.


AUTO_ADD_WHERE
**************

Automatic hook function to add a WHERE clause to the SQL query for a specific search criteria.
The function is called with the following parameters:
* 'link' => No longer used but used to indicate the linking operator (AND/OR) for the criteria.
* 'not' => Indicates if the criteria is negated.
* 'itemtype' => The type of the items being searched.
* 'search_option_id' => The ID of the search option of the criteria.
* 'search_value' => The value to search for.
* 'search_type' => The type of the search (notcontains, contains, equals, etc.).
The function is expected to return a SQL WHERE clause as a string or an empty string if the default behavior should be used.


AUTO_GIVE_ITEM
**************

Automatic hook function to show an HTML search result column value for an item of one of the itemtypes added by the plugin.
The function is called with the following parameters:
* 'itemtype' => The type of the result items.
* 'search_option_id' => The ID of the search option.
* 'data' => The data retrieved from the database.
* 'id' => The ID of the result item.
The function is expected to return the HTML content to display or an empty string if the default display should be used.


AUTO_DISPLAY_CONFIG_ITEM
************************

Automatic hook function to show an export (CSV,  PDF, etc) search result column value for an item of one of the itemtypes added by the plugin.
This function is called with the following parameters:
* 'itemtype' => The type of the items being searched.
* 'search_option_id' => The ID of the search option.
* 'data' => The data retrieved from the database.
* 'num' => A string in the form of "${itemtype}_{$search_option_id}". The alias of the related field in the SELECT clause will be "ITEM_{$num}".
The function is expected to return content to display or an empty string if the default display should be used.



AUTO_STATUS
***********

Automatic hook function to report status information through the GLPI status feature.
The function receives a parameter with the following keys:
* 'ok' => Always true
* '_public_only' => True if only non-sensitive/public information should be returned
The function is expected to return an array containing at least a 'status' key with a `StatusChecker::STATUS_*` value.
`https://glpi-user-documentation.readthedocs.io/fr/latest/advanced/status.html <https://glpi-user-documentation.readthedocs.io/fr/latest/advanced/status.html>`_
