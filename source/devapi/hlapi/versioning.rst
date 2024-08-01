Versioning
==========

The High-Level API will actively filter the routes and schema definitions based on the API version requested by the user (or default to the latest API version).
The version being used is stored by the router in a `GLPI-API-Version` header in the request after being normalized based on version pinning rules (See the getting started documentation for the High-Level API).
Controllers that extend `Glpi\Api\HL\Controller\AbstractController` can pass the request to the `getAPIVersion` helper function to get the API version.


Route Versions
^^^^^^^^^^^^^^

All routes must have a `Glpi\Api\HL\RouteVersion` attribute present.
This attribute allows specifying an introduction, deprecated, and removal version.
The introduction version is required.

When the router attempts to match a request to a route, it will take the versions specified on each route into account.
So if a user requests API version 3, routes introduced in v4 will not be considered.
Additionally, routes removed in v3 will also not be considered.
Deprecation versions do not affect the route matching logic.

Schema Versions
^^^^^^^^^^^^^^^

All schemas must have a `x-version-introduced` property present.
They may also have `x-version-deprecated` and `x-version-removed` properties if applicable.
Individual properties within schemas may declare these version properties as well, but will use the versions from the schema itself if not.

When schemas are requested from each controller, they will be filtered based on the API version requested by the user (or default to the latest API version).
If the versions on a schema make it inapplicable to the requested version, it is not returned at all from the controller.
If the schema itself is applicable, each property is evaluated and inapplicable properties are removed.