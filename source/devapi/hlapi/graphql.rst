GraphQL API
===========

The GraphQL side of the High-Level API was added to address multiple issues inherent to a REST API.
For example, the REST API often returns many unnecessary fields that are not needed by the client or requires making many requests to get the required information.
These issues can lead to performance issues and increased bandwidth usage.

The GraphQL API allows the client to specify exactly what data is needed and in what format, reducing the amount of data transferred and improving performance.
It also lets the client request multiple resources in a single request, reducing the number of round trips needed to get all the required data.
Finally, the GraphQL API allows the queries to traverse relationships between resources, making it easier to get related data in a single request.

To ease the implementation of the GraphQL API, most schemas require no changes to be available and functional within the GraphQL API.

The GraphQL schema is generated automatically from the existing schema.

GraphQL-specific Schema Extension Properties
--------------------------------------------

A few extension properties are available to control the behavior of a schema when used in the GraphQL API.

- ``x-graphql-resolver``: This property is used to specify a custom resolver function for a field in the schema.
  This must be set to a callable array, which can be serialized, and will be called with the following parameters:
  - ``$source``: The source object for the field being resolved.
  - ``$args``: An array of arguments passed to the field in the query.
  - ``$context``: An array of context information for the query.
  - ``$info``: An instance of ``\GraphQL\Type\Definition\ResolveInfo`` containing information about the query and the field being resolved.
- ``x-graphql-query-args``: This property is used to specify the arguments that can be passed to a field in the schema when used in a GraphQL query.
  The only allowed property currently is ``type``, which must be a valid GraphQL type.
- ``x-graphql-noquery``: This property forces the exclusion of a query for the schema.
  For example, the UserAgentInfo schema is only meant to be accessed through the LoginSession schema, so it has this property set to true to prevent a query from being generated for it.
- ``x-graphql-only``: This property can only be applied to schema properties and it forces the exclusion of the property from the REST API.
  This is useful for joins that would be too expensive to fetch in a REST API query but are needed to allow a GraphQL query to traverse the relationship between two schemas.

GraphQL Context Object
----------------------

The context object is an object that is passed to every resolver function in the GraphQL API containing custom information.

By default, the GraphQL API adds an ``api_version`` property to the context object, which contains the version of the High-Level API being used.

When a list of results is being fetched, the some ``pagination`` data is added to the context object, including the following properties:
- ``start``: The starting index of the results being fetched.
- ``limit``: The maximum number of results being fetched.
- ``total_count``: The total number of results available for the query.

When a GraphQL result is passed back to the ``Glpi\Api\HL\Controller\GraphQLController``, the ``Content-Range`` header is set based on the pagination data if there is only one set of pagination information.
This is mostly for backwards compatibility, and it does not account for the fact that multiple queries may be present in any request.
The more correct way to handle this is also done; the ``Glpi\Api\HL\Controller\GraphQLController`` will add an ``extensions`` property and a ``pagination`` child property to the response containing the pagination data for each query in the request.

Default Resolvers
-----------------

By default, all fields in a schema are resolved using default resolvers based on:
- ListOfType: This type of field is resolved by ``\Glpi\Api\HL\GraphQL\DefaultResolvers::resolveListField``.
- ObjectType: This type of field is resolved by ``\Glpi\Api\HL\GraphQL\DefaultResolvers::resolveObjectField``.
- Any other type: This type of field is resolved by ``\Glpi\Api\HL\GraphQL\DefaultResolvers::resolveScalarField``.

The scalar resolver is the simplest, and for most fields it just returns the value of the field from the source object.
It is capable of handling mapped fields as well.

Both the list and object resolvers use a deferred resolution strategy to avoid fetching the same records multiple times.
In addition to using Deferred, the resolvers also make use of an object cache mechanism.
The object cache allows tracking which fields are already fetched for certain objects.

For example, if a GraphQL request queries Computers with their associated Users and request the User ID, username, first name, and real name, and the request also queries Tickets with their associated Users with the same fields plus some extra, the object cache will allow the second query to only fetch the additional fields for users that were already fetched in the first query.

Internally, the GraphQL default resolvers rely on several functions from the ``\Glpi\Api\HL\Search`` class to build the SQL queries and fetch the data from the database similar to how the REST API works.
