REST API
========

The REST API is the simplest method to interact with the High-Level API.
Unlike GraphQL which currently only supports read-only operations, the REST API supports all CRUD operations (Create, Read, Update, Delete).

Endpoints
---------

Endpoints are defined by creating functions within a registered controller and adding some specific PHP attributes to them to describe them.

The standard is to use GET for get/search, POST for create, PATCH for update, and DELETE for delete.

Some APIs use PUT for update operations even when the update is not a full replacement of the item, but the High-Level API (and the underlying core GLPI logic) works with state changes and PATCH is the correct method to use for this type of operation.

The following attributes are required on all endpoint functions:
- ``Glpi\Api\HL\Route``: Defines the functional information about the endpoint such as the HTTP methods, path, path attribute requirements, priority, required security level, required scopes, and additional middleware to register for the responses coming from the endpoint.
  With path parameters, you can define them to match against a regular expression.
  Additionally, you can define path parameters to match against the result of a static method on the controller class (defined in any callable format) that returns an array of valid values for the path parameter.
  In addition to applying to the endpoint functions, this attribute may also be applied to the controller class itself.
  In this case, the path will be prepended to all endpoint paths and the other information will be applied to all endpoints within the controller.
- ``Glpi\Api\HL\RouteVersion``: Defines the versioning information for the endpoint.
  This includes the High-Level API version numbers corresponding to when the endpoint was introduced, deprecated, and removed.
- ``Glpi\Api\HL\Doc\Route``: Defines the information that is only used for the documentation generation such as the description, parameter schemas, and response schemas.
  This attribute may be defined multiple times on a single endpoint if there needs to be different documentation depending on the HTTP method of the request.
  For convenience, ``Glpi\Api\HL\Doc\CreateRoute``, ``Glpi\Api\HL\Doc\DeleteRoute``, ``Glpi\Api\HL\Doc\GetRoute``, ``Glpi\Api\HL\Doc\SearchRoute``, and ``Glpi\Api\HL\Doc\UpdateRoute`` attributes are provided to simplify and standardize the documentation for the common CRUD operations.
  In addition to applying to the endpoint functions, this attribute may also be applied to the controller class itself.
  In this case, you can specify common parameter and response schemas that will be applied to all endpoints within the controller (if they use them).

For the actual logic of the endpoint, there exists a ``Glpi\Api\HL\ResourceAccessor`` class that provides several static methods to handle the common CRUD operations for items and their properties.

Therefore, most endpoints can be programmed with just a few lines of code.

An example of an endpoint is shown below:

.. code-block:: php
    #[Route(path: '/Assets', priority: 1, tags: ['Assets'])]
    final class AssetController extends AbstractController
    {
        #[Route(path: '/{itemtype}', methods: ['GET'], requirements: [
            'itemtype' => [self::class, 'getAssetTypes'],
        ], middlewares: [ResultFormatterMiddleware::class])]
        #[RouteVersion(introduced: '2.0')]
        #[Doc\SearchRoute(
            schema_name: '{itemtype}',
            description: 'List or search assets of a specific type'
        )]
        public function search(Request $request): Response
        {
            $itemtype = $request->getAttribute('itemtype');
            return ResourceAccessor::searchBySchema($this->getKnownSchema($itemtype, $this->getAPIVersion($request)), $request->getParameters());
        }
    }

Here you can tell:
- The endpoint is for GET /Asset/{itemtype}
- The ``itemtype`` path parameter is validated against the result of the static method ``getAssetTypes`` on the controller class
- The endpoint is documented as a search endpoint for the schema corresponding to the ``itemtype``
- The endpoint was introduced in version 2.0 of the High-Level API
- As standard with the Get/Search endpoints, the ``ResultFormatterMiddleware`` is applied to the response to allow the response to be sent as CSV or XML if the request specifies it in the ``Accept`` header

The only logic in the endpoint is to call the ``ResourceAccessor::searchBySchema`` method with the schema and request parameters.

A slightly more complex example is shown below:

.. code-block:: php
    #[Route(path: '/Assets', priority: 1, tags: ['Assets'])]
    #[Doc\Route(
        parameters: [
            new Doc\Parameter(
                name: 'asset_id',
                schema: new Doc\Schema(Doc\Schema::TYPE_INTEGER),
                location: Doc\Parameter::LOCATION_PATH,
            ),
        ]
    )]
    final class AssetController extends AbstractController
    {
        #[Route(path: '/{asset_itemtype}/{asset_id}/PeripheralConnection', methods: ['POST'], requirements: [
            'asset_itemtype' => [self::class, 'getAssetTypes'],
            'asset_id' => '\d+',
        ])]
        #[RouteVersion(introduced: '2.3')]
        #[Doc\CreateRoute(
            schema_name: 'PeripheralConnection',
            description: 'Connect a peripheral to an asset'
        )]
        public function createItemPeripheralConnection(Request $request): Response
        {
            $request->setParameter('itemtype_asset', $request->getAttribute('asset_itemtype'));
            $request->setParameter('items_id_asset', $request->getAttribute('asset_id'));
            return ResourceAccessor::createBySchema(
                schema: $this->getKnownSchema('PeripheralConnection', $this->getAPIVersion($request)),
                request_params: $request->getParameters(),
                get_route: [self::class, 'getItemPeripheralConnection'],
                extra_get_route_params: [
                    'mapped' => [
                        'asset_itemtype' => $request->getAttribute('asset_itemtype'),
                        'asset_id' => $request->getAttribute('asset_id'),
                    ],
                ]
            );
        }
    }

In this case, we are creating a peripheral connection between an asset and a peripheral.

The endpoint takes the asset itemtype and ID from the path parameters and sets them as request parameters to be used
in the creation of the peripheral connection so that the user does not have to provide them again in the request body, and to ensure consistency where the user cannot specify a different asset in the request body than the one in the path parameters.

The endpoint then calls the ``ResourceAccessor::createBySchema`` method with the schema, request parameters, and the route to get the newly created peripheral connection in a callable syntax.

Additionally, the extra parameters to pass to the get route are specified so that the get route can be called with the correct asset itemtype and ID.

Resource Accessor
-----------------

getOneBySchema
^^^^^^^^^^^^^^

Gets a single item by a schema name. Internally, the function will call the ``searchBySchema`` function with an appropriate filter.

This function also takes:
- request parameters to filter the search for the item
- request attributes to be used in addition to the field name option to add an RSQL filter that will be applied to the search. For example "id==5" or "username==glpi".
- a field name to use as the primary key for the search (defaults to id). An example of this being used is for ``/Administration/Users/{username}`` where we are trying to look for a user by their username instead of their ID.

The basic logic for this function is:
1. Apply read restrictions to the schema itself to filter any properties that should be unknown.
2. Resolves the itemtype from the schema and checks that the user has the global read permission to view the itemtype.
   Item-level permissions are expected to be handled within the SQL query based on the ``x-rights-conditions`` property in the schema.
3. Adds a filter to the request parameters to limit the search to the single record specified by the field name and value.
   Note that it was specified that the filter is **added**.
   In practice this means a user could specify their own filters to have the server check if the record they are looking for matches a certain state.
   This could be slightly faster than just fetching the record and then checking the state on the client side.
4. Ensures that the search starts on the first record and limits the search to a single record.
5. Calls the ``searchBySchema`` function with the schema and request parameters.
6. Checks, if any were sent in the HTTP headers, some HTTP preconditions.
7. Returns the single record if found, or a 404 error if not found.

searchBySchema
^^^^^^^^^^^^^^

Gets a list of items by a schema name. This function also takes:
- request parameters to filter the search for the items

The basic logic for this function is:
1. Apply read restrictions to the schema itself to filter any properties that should be unknown.
2. Resolves the itemtype from the schema and checks that the user has the global read permission to view the itemtype.
   Item-level permissions are expected to be handled within the SQL query based on the ``x-rights-conditions`` property in the schema.
3. Calls ``Glpi\Api\HL\Search::getSearchResultsBySchema`` with the schema and request parameters to get the list of records.
4. Returns the list of records found along with a ``Content-Range`` header, or a 404 error if no records were found.

createBySchema
^^^^^^^^^^^^^^

Creates a new item by a schema name. This function also takes:
- request parameters to create the item
- the GET route to use to get the newly created item
- any extra parameters to pass to the GET route

The basic logic for this function is:
1. Apply read restrictions to the schema itself to filter any properties that should be unknown.
2. Forces the ``entity`` parameter to be set to the current entity if it was not specified in the request parameters.
3. Validates the parameters provided against the requirements of the properties in the schema.
4. Maps the request parameters to the internal field names used by the itemtype.
5. Checks the the user has permission to create an item with the given fields.
6. Call the ``CommonDBTM::add`` method to create the item and get the new item's ID.
7. Returns a 201 Created response with the ``Location`` header set to the GET route for the newly created item, as well as a JSON body specifying the new item's ID and the GET route to retrieve it.

updateBySchema
^^^^^^^^^^^^^^

Updates an existing item by a schema name. This function also takes:
- request parameters to update the item
- request attributes to be used in addition to the field name option to add an RSQL filter that will be applied to the search. For example "id==5" or "username==glpi".
- a field name to use as the primary key for the search (defaults to id). An example of this being used is for ``/Administration/Users/{username}`` where we are trying to update a user by their username instead of their ID.

The basic logic for this function is:
1. Apply read restrictions to the schema itself to filter any properties that should be unknown.
2. Forces the ``entity`` parameter to be undefined to prevent the changing of the entity outside of the normal entity transfer process.
3. Validates the parameters provided against the requirements of the properties in the schema.
4. Maps the request parameters to the internal field names used by the itemtype.
5. Checks that the user has permission to update an item with the given fields.
6. Calls the ``CommonDBTM::update`` function to update the item.
7. Returns the response from the ``getOneBySchema`` function to get the updated item.

deleteBySchema
^^^^^^^^^^^^^^

Deletes an existing item by a schema name. This function also takes:
- request parameters to filter the search for the item
- request attributes to be used in addition to the field name option to add an RSQL filter that will be applied to the search. For example "id==5" or "username==glpi".
- a field name to use as the primary key for the search (defaults to id). An example of this being used is for ``/Administration/Users/{username}`` where we are trying to delete a user by their username instead of their ID.

The basic logic for this function is:
1. Checks if the "force" parameter is set and true to indicate the item should be purged instead of just soft-deleted (if the itemtype supports it).
2. Checks that the user has permission to delete or purge an item with the given fields.
3. Calls the ``CommonDBTM::delete`` function to delete or purge the item.
4. Returns a 204 No Content response or an error response if the item could not be deleted or purged.

Property Read Restrictions
^^^^^^^^^^^^^^^^^^^^^^^^^^

At this point, that means any property marked ``x-graphql-only``.
In the future, this may also include properties that get filtered out by a kind of property-level permission system.

Property Validation
^^^^^^^^^^^^^^^^^^^

Several constraints are applied to the request parameters based on the schema property definitions.
Some of the ``prepareInputForAdd`` and ``prepareInputForUpdate`` methods on the itemtype classes also apply validation, but the behavior is inconsistent and messages not machine readable.

By checking the constraints within the High-Level API, we can provide a consistent and machine-readable error message for any validation errors.

Currently, the following constraints are checked:
- Required properties must be provided in the request parameters. Required properties are only checked for create operations, not update operations.
- Properties with a maxLength constraint must not exceed the maximum length.
- Properties with a minimum constraint must not be less than the minimum value.
- Properties with a maximum constraint must not be greater than the maximum value.
- Properties with both a minimum and maximum constraint must be within the range of the two values. This is a separate check to give the user both the minimum and maximum constraints when they provide a value completely out of range.
- Properties with a pattern constraint must match the specified regular expression.

Precondition Checks
^^^^^^^^^^^^^^^^^^^

Currently, the following precondition checks are supported:
- If-Modified-Since: Checks if the item has been modified since the specified date/time.
  If it has not been modified, a 304 Not Modified response is returned for GET requests or a 412 Precondition Failed response is returned for other requests.
- If-Unmodified-Since: Checks if the item has been modified since the specified date/time.
  If it has been modified, a 412 Precondition Failed response is returned.

For preconditions on the modification date, they are only applied if the item has a ``date_mod`` field and it is not null. If it does not, the precondition is ignored.
