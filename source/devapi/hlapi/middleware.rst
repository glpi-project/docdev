Middleware
==========

The High-Level API provides a middleware system that allows for custom logic to be run at different stages of the request.

Authentication Middleware
-------------------------

Registered authentication middleware is run very early in the request process.
The middleware's ``process`` function is called with a ``Glpi\Api\HL\Middleware\MiddlewareInput`` object containing the original request object, the matched route path, and a default unauthorized response.
The function is also passed a ``next`` callable that can be used to continue processing the request.
If the middleware authenticates the request, it should set the ``response`` property of the middleware input to null.
In either case, a ``$next($input);`` call should be made to continue processing the request.

By default, only the ``Glpi\Api\HL\Middleware\CookieAuthMiddleware`` is registered, but it is registered with a condition callable that always returns false so it is only used when explicitly requested by the route.

The OAuth authentication is currently not implemented via middleware.

A second authentication middleware, ``Glpi\Api\HL\Middleware\InternalAuthMiddleware``, is included but not registered by default which allows regular web sessions to be used for High-Level API requests.
This is used currently by the webhook system and some unit tests.

Request Middleware
------------------

Request middleware is run after authentication middleware but before the request is processed by the route handler.
This middleware is intended to be used to modify the request or provide an early response before the request is processed by the route handler.

For example, the ``Glpi\Api\HL\Middleware\IPRestrictionMiddleware`` is used to check if the IP address of the client is allowed for the current client and returns an access denied response if not.

Response Middleware
-------------------

Response middleware is run after the request is processed by the route handler but before the response is sent to the client.
This middleware is intended to be used to modify the response before it is sent to the client.

For example, the ``Glpi\Api\HL\Middleware\ResultFormatterMiddleware`` is used to transform the response content, which is JSON by default, to CSV or XML if requested by the client via the ``Accept`` header.
The result formatter middleware is registered by default but with an always false condition, so it only run when explicitly requested by the route.
