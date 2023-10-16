Search
======

As the High-Level API is decoupled from the PHP classes and search options system, a new search engine was developed to handle interacting with the database.
This new search engine exists in the ``\Glpi\Api\HL\Search`` class.
For simplicity, the search engine class also provides static methods to perform item creation, update and deletion in addition to the search/get actions.

These entrypoint methods are:

- getOneBySchema
- searchBySchema
- createBySchema
- updateBySchema
- deleteBySchema

See the PHPDoc for each method for more information.

While the standard search engine constructs a single database query to retreive item(s), the High-Level API takes multiple distinct steps and multiple queries to fetch and assemble the data given the potential complexity of schemas while keeping the schemas themselves relatively simple.

The steps are:

1. Initializing a new search.
   This step consists of making a new instance of the ``\Glpi\Api\HL\Search`` class, generating a flattened array of properties (flattens properties where the keys are the full property name in dot notation to make lookups easier) in the schema and identifying joins.
2. Construct a request to get the 'dehydrated' result.
   In this context, that means a result without all of the desired data. It only contains the identification data (the main item ID(s) and the IDs of joined records) and the scalar join values.
   Each dehydrated result is an array where the keys are the primary ID field and any full join property name. The '.' in the names are replaced with 0x1F characters (Unit separator character) to avoid confusion about what is a table/field identifier.
   In the case that a join property is for an array of items, the IDs are separated by a 0x1D character (Group separator character).
   If there are no results for a specific join, a null byte character will be used.
   The reason a dehydrated result is fetched first is that we don't need to either worry about grouping data or handling the multiple rows returned that relate to a single main item.
3. Hydrate each of the dehydrated results. In separate queries, the search engine will fetch the data for the main item and each join.
   Each time a new record is fetched, it is stored in a separate array that acts like a cache to avoid fetching the same record twice.
4. Assemble the hydrated records into the final result(s). The search engine enumerates each property in the dehydrated result starting with the main item's ID and maps the hydrated data into a result that matches the expected schema.
5. Fixup the assembled records. Some post-processing is done after the record is fully assembled to clean some of the artifacts from the assembly process such as removing the keys for array type properties and replacing empty array values for object type properties with null.
6. Returning the result(s).