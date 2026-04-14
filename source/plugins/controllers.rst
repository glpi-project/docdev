Controllers
-----------

Plugin controllers follow the same principles as :doc:`core controllers </devapi/controllers>` with a few differences specific to the plugin system.

.. note::

   Controllers require GLPI >= 11.0.

Creating a plugin controller
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Requirements:

* The controller file must be placed in the ``src/Controller/`` folder of the plugin.
* The namespace must follow PSR-4: ``GlpiPlugin\MyPlugin\Controller\``.
* The controller must extend ``Glpi\Controller\AbstractController`` or implement the ``Glpi\\DependencyInjection\\PublicService`` interface.
* The controller must define a route using the ``Route`` attribute.
* The controller must return a ``Symfony\\Component\\HttpFoundation\\Response`` instance.

Controllers placed in ``src/Controller/`` are **automatically discovered**, no manual registration is needed.

Example for a plugin named ``myplugin``:

.. code-block:: php

   # plugins/myplugin/src/Controller/HelloController.php
   <?php

   namespace GlpiPlugin\Myplugin\Controller;

   use Glpi\Controller\AbstractController;
   use Symfony\Component\HttpFoundation\JsonResponse;
   use Symfony\Component\HttpFoundation\Request;
   use Symfony\Component\HttpFoundation\Response;
   use Symfony\Component\Routing\Attribute\Route;

   final class HelloController extends AbstractController
   {
       #[Route("/Hello", name: "myplugin_hello", methods: "GET")]
       public function __invoke(Request $request): Response
       {
           return new JsonResponse(['message' => 'Hello from myplugin!']);
       }
   }

URL routing
^^^^^^^^^^^

Plugin routes are automatically prefixed with the plugin base path. A route defined as ``/Hello`` in the ``myplugin`` plugin will be accessible at:

* ``/plugins/myplugin/Hello`` (standard plugins directory)
* ``/marketplace/myplugin/Hello`` (marketplace plugins directory)

You do not need to include the plugin prefix in the ``Route`` attribute.

Rendering Twig templates
^^^^^^^^^^^^^^^^^^^^^^^^

To render a Twig template from a plugin controller, use the ``@plugin_key`` prefix:

.. code-block:: php

   <?php
   return $this->render('@myplugin/path/to/template.html.twig', [
       'my_variable' => $value,
   ]);

This will resolve to ``plugins/myplugin/templates/path/to/template.html.twig``.

HTTP method constraints compatibility
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning::

   A bug in GLPI prior to **11.0.7** caused plugin routes with method constraints other than ``GET`` to never match.
   The router context was always evaluated as ``GET``, so any route declared with only ``POST``, ``PUT``, ``DELETE``, ``PATCH``, etc. would never be found.

   This bug was fixed in GLPI 11.0.7.
   If your plugin needs to support GLPI < 11.0.7, use the following workaround:
   include ``GET`` alongside the intended methods and check the actual method manually inside the controller.

**Workaround for GLPI < 11.0.7:**

.. code-block:: php

   <?php
   // ❌ Non-GET method only, broken on GLPI < 11.0.7
   #[Route("/MyAction", name: "myplugin_my_action", methods: ['POST'])]

   // ✅ Works on all versions >= 11.0 (check the method manually if needed)
   #[Route("/MyAction", name: "myplugin_my_action", methods: ['GET', 'POST'])]
   public function __invoke(Request $request): Response
   {
       if (!$request->isMethod('POST')) {
           throw new \Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException(['POST']);
       }
       // ...
   }

On GLPI >= 11.0.7, you can safely restrict routes to any HTTP method without the workaround.

Stateless routes
^^^^^^^^^^^^^^^^

By default, GLPI requires an active session to access any route (see :doc:`/devapi/controllers`Firewall section).
If a plugin route must be accessible without a session, register the path pattern in the ``plugin_{key}_init()`` or ``plugin_{key}_boot()`` function in ``setup.php``:

.. code-block:: php

   # plugins/myplugin/setup.php
   <?php

   function plugin_myplugin_init(): void
   {
       \Glpi\Http\SessionManager::registerPluginStatelessPath('myplugin', '#^/MyPublicRoute$#');
   }

The pattern is a regex matched against the path relative to the plugin base URL (i.e. without the ``/plugins/myplugin`` prefix).
