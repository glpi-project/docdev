RESTful Service Query Language (RSQL)
=====================================

Both the REST and GraphQL sides of the High-Level API use a common query language called RSQL (RESTful Service Query Language) to filter results.

The parsing of these filters is done in two parts within the High-Level API.

First, the RSQL filter is lexed by ``\Glpi\Api\HL\RSQL\Lexer`` which converts the string into a series of tokens that can be processed by the parser.
This is where the bulk of the work is done and some validation is also performed here.
If a query is missing an operator or has an invalid operator, the lexer will throw an exception.
If a query has more open group characters than close group characters, the lexer will throw an exception.
At this stage, the schema being filtered is not taken into account.

Next, the tokens are passed to ``\Glpi\Api\HL\RSQL\Parser`` which converts the tokens into lists of SQL conditions and applies any schema-specific validation.
If a query has an operator that expects a value, but no value is provided, the parser will throw an exception as it indicates a potential malformed filter string and it is not safe to proceed.
If a property is a computed field, the parser will add the related condition to a list of HAVING conditions instead of the WHERE conditions.
If a property is not known to the schema, the parser will only add it to a list of invalid filters to be processed later.
If a property is mapped, the parser will only add it to the list of invalid filters.
If a filter contains an unknown operator, the parser will only add it to the list of invalid filters.
A special case exists for boolean properties where the provided value will be coerced to a boolean value so that the user can use a variety of values to represent true or false (1, 0, "true", "false", "yes", "no", etc.).

If the RSQL parser returns a result with some invalid filters and a schema resolver callable is provided to ``Glpi\Api\HL\Search::addRSQLCriteria``, the resolver will be called with the list of invalid filters.
Currently, this is only done from the GraphQL API to handle cases where an RSQL filter is provided for a property in another schema that is being traversed in the query.
