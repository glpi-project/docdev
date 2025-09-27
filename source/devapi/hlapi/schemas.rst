Schemas
=======

Schemas are the definitions of the various item types in GLPI, or facades, for how they are exposed to the API.
In the legacy API, all classes that extend ``CommonDBTM`` were exposed along with all of their search options.
This is not the case with the High-Level API.

Schema Format
^^^^^^^^^^^^^

The schemas loosely follow the `OpenAPI 3 specification <https://swagger.io/specification/v3/>`_ to make it easier to implement the Swagger UI documentation tool.
GLPI utilizes multiple custom extension fields (fields starting with 'x-') in schemas to enable advanced behavior.
Schemas are defined in an array with their name as the key and definition as the value.

There exists the ``\Glpi\API\HL\Doc\Schema`` class which is used to represent a schema definition in some cases, but also provides constants and static methods for working with schema arrays.
This includes constants for the supported property types and formats.

Let's look at a partial version of the schema definition for a User since it shows most of the possibilities:

.. code-block:: php

    'User' => [
        'x-version-introduced' => '2.0.0',
        'x-itemtype' => User::class,
        'type' => Doc\Schema::TYPE_OBJECT,
        'x-rights-conditions' => [ // Object-level extra permissions
            'read' => static function () {
                if (!\Session::canViewAllEntities()) {
                    return [
                        'LEFT JOIN' => [
                            'glpi_profiles_users' => [
                                'ON' => [
                                    'glpi_profiles_users' => 'users_id',
                                    'glpi_users' => 'id'
                                ]
                            ]
                        ],
                        'WHERE' => [
                            'glpi_profiles_users.entities_id' => $_SESSION['glpiactiveentities']
                        ]
                    ];
                }
                return true;
            }
        ],
        'properties' => [
            'id' => [
                'type' => Doc\Schema::TYPE_INTEGER,
                'format' => Doc\Schema::FORMAT_INTEGER_INT64,
                'description' => 'ID',
                'readOnly' => true,
            ],
            'username' => [
                'x-field' => 'name',
                'type' => Doc\Schema::TYPE_STRING,
                'description' => 'Username',
            ],
            'realname' => [
                'type' => Doc\Schema::TYPE_STRING,
                'description' => 'Real name',
            ],
            'emails' => [
                'type' => Doc\Schema::TYPE_ARRAY,
                'description' => 'Email addresses',
                'items' => [
                    'type' => Doc\Schema::TYPE_OBJECT,
                    'x-full-schema' => 'EmailAddress',
                    'x-join' => [
                        'table' => 'glpi_useremails',
                        'fkey' => 'id',
                        'field' => 'users_id',
                        'x-primary-property' => 'id' // Help the search engine understand the 'id' property is this object's primary key since the fkey and field params are reversed for this join.
                    ],
                    'properties' => [
                        'id' => [
                            'type' => Doc\Schema::TYPE_INTEGER,
                            'format' => Doc\Schema::FORMAT_INTEGER_INT64,
                            'description' => 'ID',
                        ],
                        'email' => [
                            'type' => Doc\Schema::TYPE_STRING,
                            'description' => 'Email address',
                        ],
                        'is_default' => [
                            'type' => Doc\Schema::TYPE_BOOLEAN,
                            'description' => 'Is default',
                        ],
                        'is_dynamic' => [
                            'type' => Doc\Schema::TYPE_BOOLEAN,
                            'description' => 'Is dynamic',
                        ],
                    ]
                ]
            ],
            'password' => [
                'type' => Doc\Schema::TYPE_STRING,
                'format' => Doc\Schema::FORMAT_STRING_PASSWORD,
                'description' => 'Password',
                'writeOnly' => true,
            ],
            'password2' => [
                'type' => Doc\Schema::TYPE_STRING,
                'format' => Doc\Schema::FORMAT_STRING_PASSWORD,
                'description' => 'Password confirmation',
                'writeOnly' => true,
            ],
            'picture' => [
                'type' => Doc\Schema::TYPE_STRING,
                'x-mapped-from' => 'picture',
                'x-mapper' => static function ($v) {
                    global $CFG_GLPI;
                    $path = \Toolbox::getPictureUrl($v, false);
                    if (!empty($path)) {
                        return $path;
                    }
                    return $CFG_GLPI["root_doc"] . '/pics/picture.png';
                }
            ]
        ]
    ]

The first property in the definition, 'x-itemtype' is used to link the schema with an actual GLPI class.
This is used to determine which table to use to access direct properties and access more data like entity restrictions and extra visiblity restrictions (when implementing the ``ExtraVisibilityCriteria`` class).
This property is required.

Next, is a 'type' property which is part of the standard OpenAPI specification. In this case, it defines a User as an object. In general, all schemas would be objects.

Third, is an 'x-rights-conditions' property which defines special visiblity restrictions. This property may be excluded if there are no special restrictions.
Currently, only 'read' restrictions can be defined here.
Each type of restriction must be a callable that returns an array of criteria, or just an array of criteria, in the format used by ``DBmysqlIterator``.
If the criteria is reliant on data from a session or is expensive, it should use a callable so that the criteria is resolved only at the time it is needed.

Finally, the 'properties' are defined.
Each property has its unique name as the key and the definition as the value in the array.
Property names do not have to match the name of the column in the database. You can specify a different column name using an 'x-field' field;
Each property must have an OpenAPI 'type' defined. They may optionally define a specific 'format'. If no 'format' is specified, the generic format for that type will be used.
For example, a type of ``Doc\Schema::TYPE_STRING`` will default to the ``Doc\Schema::FORMAT_STRING_STRING`` format.
Properties may also optionally define a description for that property.

In this example, the 'emails' property actually refers to multiple email addresses associated with the user.
The 'type' in this case is ``Doc\Schema::TYPE_ARRAY``. The schema for the individual items in defined inside the 'items' property.
Of course, email addresses are not stored in the same database table as users and are their own item type ``EmailAddress``.
Therefore, 'emails' is considered a joined object property.
In joined objects, we specify which properties will be included in the data but that can be a subset of the properties of the full schema (see :ref:`Partial vs Full Schema <partial_full_schema>`).
The full schema can be specified using the 'x-full-schema' field.
The criteria for the join is specified in the 'x-join' field (more on that in the :ref:`Joins section <joins>`).

Users have two password fields which we would never want to show via the API, but we do want them to exist in the schema to allow setting/resetting a password.
In this case, both 'password' and 'password2' have a 'writeOnly' field present and set to true.

The last property shown, 'picture', is an example of a mapped property.
In some cases, the data we want the user to see will differ from the raw value in the database.
In this example, pictures are stored as the path relative to the pictures folder such as '16/2_649182f5c5216.jpg'.
To a user of the API, this is useless. However, we can use that data to convert it to the front-end URL needed to access that picture such as '/front/document.send.php?file=_pictures/16/2_649182f5c5216.jpg'.
To accomplish this, mapped properties have the 'x-mapped-from' and 'x-mapper' fields.
'x-mapped-from' indicates the property we are mapping from. In this case, it maps from itself.
'x-mapper' is a callable that transforms the raw value to the display value.
The mapper used here takes the relative path and converts it to the front-end URL. It then handles returning the default user picture if it cannot get the user's specific picture.

.. _partial_full_schema:

Partial vs Full Schema
^^^^^^^^^^^^^^^^^^^^^^

A full schema is the defacto representation of an item in the API.
In some cases, we do not want every property for an item to be visible such as dropdown types related to a main item.
In ``Computer`` item we may show the ID and name of the computer's location, but the Location type itself has additional data like geolocation coordinates.
The partial schema contains only the properties needed for the user to know where to look for the full details and some basic information about it.

.. _joins:

Joins
^^^^^

Schemas may include data from tables other than the table for the main item.
Most of the item, joins are used in 'object' type properties such as when bringing in an ID and name for a dropdown type.
In some cases though, joins may be defined on scalar properties (not array or object).

The information required to join data from outside of the main item's table is defined inside of an 'x-join' array.
The supported properties of the 'x-join' definition are:

* table: The database table to pull the data from
* fkey: The SQL field in the main table to use to identify which records in the other table are related
* field: The SQL field in the other table to match against the fkey.
* primary-property: Optional property which indicates the primary property of the foreign data. Typically, this is the 'id' field.
  By default, the API will assume the field specified in 'field' is the primary property. If it isn't, it is required to specify it here.
  In the User schema example, email addresses have a many-to-one relation with users. So, we use the user's ID field and match it against the 'users_id' field of the email addresses.
  In that case, the 'field' is 'users_id' but the primary property is 'id', so we need to hint to the API that 'id' is still the primary property.
* ref-join: In some cases, there is no direct connection between the main item's table and the table with the data desired (typically seen with many-to-many relations).
  In that case, a reference or in-between join can be specified. The 'ref_join' property follows the same format as 'x-join' except that you cannot have another 'ref_join'.

Extension Properties
^^^^^^^^^^^^^^^^^^^^

Below is a complete list of supported extension fields/properties used in OpenAPI schemas.

.. list-table:: Extension Properties
    :widths: 25 50 25 25
    :header-rows: 1

    * - Property
      - Description
      - Applicable Locations
      - Visible in Swagger UI
    * - x-controller
      - Set and used internally by the OpenAPI documentation generator to track which controller defined the schema.
      - Main schema
      - Debug mode only
    * - x-field
      - Specifies the column that contains the data for the property if it differs from the property name.
      - Schema properties
      - Debug mode only
    * - x-full-schema
      - Indicates which schema is the full representation of the joined property.
        This enables the accessing of properties not in the partial schema in certain conditions such as a GraphQL query.
      - Schema join properties
      - Yes
    * - x-version-introduced
      - Indicates which API version the schema or property first becomes available in. This is required for all schemas. Any individual properties without this will use the introduction version from the schema.
      - Main schema and schema properties
      - Yes
    * - x-version-deprecated
      - Indicates which API version the schema or property becomes deprecated in. Any individual properties without this will use the deprecated version from the schema if specified.
      - Main schema and schema properties
      - Yes
    * - x-version-removed
      - Indicates which API version the schema or property becomes removed in. Any individual properties without this will use the removed version from the schema if specified.
      - Main schema and schema properties
      - Yes
    * - x-itemtype
      - Specifies the PHP class related to the schema.
      - Main schema
      - Debug mode only
    * - x-join
      - Join definition. See Joins section for more information.
      - Schema join properties
      - Debug mode only
    * - x-mapped-from
      - Indicates the property to use with an 'x-mapper' to modify a value before returning it in an API response.
      - Schema properties
      - Debug mode only
    * - x-mapper
      - A callable that transforms the raw value specified by 'x-mapped-from' to the display value.
      - Schema properties
      - Debug mode only
    * - x-rights-conditions
      - Array of arrays or callables that returns an array of SQL criteria for special visibility restrictions. Only 'read' restrictions are currently supported.
        The type of restriction should be specified as the array key, and the callable or array as the value.
      - Schema properties
      - Debug mode only
    * - x-subtypes
      - Indicates array of arrays containing 'schema_name' and 'itemtype' properties.
        This is used for unique cases where you want to allow searching across multiple schemas at once such as "All assets".
        Typically you would find all shared properties between the different schemas and use that as the properties for this shared schema.
      - Main schema
      - Debug mode only
