Controllers
-----------

You need a `Controller` any time you want an URL access.

.. note::

   `Controllers` are the modern way that replace all files previousely present in ``front/`` and ``ajax/`` directories.

.. warning::

   Currently, not all existing ``front/`` or ``ajax/`` files have been migrated to `Controllers`, mainly because of specific behaviors or lack of time to work on migrating them.

   Any new feature added to GLPI >=11 **must** use `Controllers`.

Creating a controller
^^^^^^^^^^^^^^^^^^^^^

Minimal requirements to have a working controller:

* The controller file must be placed in the ``src/Glpi/Controller/`` folder.
* The name of the controller must end with ``Controller``.
* The controller must extends the ``Glpi\Controller\AbstractController`` class.
* The controller must define a route using the Route attribute.
* The controller must return some kind of response.

Example:

.. code-block:: php

   # src/Controller/Form/TagsListController.php
   <?php

   namespace Glpi\Controller\Form;

   use Glpi\Controller\AbstractController;
   use Symfony\Component\HttpFoundation\Request;
   use Symfony\Component\HttpFoundation\Response;
   use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
   use Symfony\Component\Routing\Attribute\Route;

   final class TagsListController extends AbstractController
   {
       #[Route(
           "/Form/TagsList",
           name: "glpi_form_tags_list",
           methods: "GET"
       )]
       public function __invoke(Request $request): Response
       {
           if (!Form::canUpdate()) {
               throw new AccessDeniedHttpException();
           }

           $tag_manager = new FormTagsManager();
           $filter = $request->query->getString('filter');

           return new JsonResponse($tag_manager->getTags($filter));
       }
   }

Routing
^^^^^^^

Routing is done with the ``Symfony\Component\Routing\Attribute\Route`` attribute. Read more from `Symfony Routing documentation <https://symfony.com/doc/current/routing.html>`_.

Basic route
+++++++++++

.. code-block:: php

   #[Symfony\Component\Routing\Attribute\Route("/my/route/url", name: "glpi_my_route_name")]

Dynamic route parameter
+++++++++++++++++++++++

.. code-block:: php

   #[Symfony\Component\Routing\Attribute\Route("/Ticket/{id}", name: "glpi_ticket")]

Restricting a route to a specific HTTP method
+++++++++++++++++++++++++++++++++++++++++++++

.. code-block:: php

   #[Symfony\Component\Routing\Attribute\Route("/Tickets", name: "glpi_tickets", methods: "GET")]

Known limitation for ajax routes
++++++++++++++++++++++++++++++++

If an ajax route will be accessed by multiple POST requests without a page reload then you will run into CRSF issues.

This is because GLPI’s solution for this is to check a special CRSF token that is valid for multiples requests, but this special token is only checked if your url start with ``/ajax``.

You will thus need to prefix your route by ``/ajax`` until we find a better way to handle this.

Reading query parameters
^^^^^^^^^^^^^^^^^^^^^^^^

These parameters are found in the ``$request`` object:

* ``$request->query`` for ``$_GET``
* ``$request->request`` for ``$_POST``
* ``$request->files`` for ``$_FILES``

Read more from `Symfony Request documentation <https://symfony.com/doc/current/components/http_foundation.html#request>`_

Reading a string parameter from $_GET
+++++++++++++++++++++++++++++++++++++

.. code-block:: php

   <?php
   public function __invoke(Symfony\Component\HttpFoundation\Request $request): Response
   {
       $filter = $request->query->getString('filter');
   }

Reading an integer parameter from $_POST
++++++++++++++++++++++++++++++++++++++++

.. code-block:: php

   <?php
   public function __invoke(Symfony\Component\HttpFoundation\Request $request): Response
   {
       $my_int = $request->request->getInt('my_int');
   }

Reading an array of values from $_POST
++++++++++++++++++++++++++++++++++++++

.. code-block:: php

   <?php
   public function __invoke(Symfony\Component\HttpFoundation\Request $request): Response
   {
       $ids = $request->request->get("ids", []);
   }

Reading a file
++++++++++++++

.. code-block:: php

   <?php
   public function __invoke(Symfony\Component\HttpFoundation\Request $request): Response
   {
       // @var \Symfony\Component\HttpFoundation\File\UploadedFile $file
       $file = $request->files->get('my_file_input_name');
       $content = $file->getContent();
   }

Single vs multi action controllers
++++++++++++++++++++++++++++++++++

The examples in this documentation use the magic ``__invoke`` method to force the controller to have only one action (see https://symfony.com/doc/current/controller/service.html#invokable-controllers).

In general, this is a recommended way to proceed but we do not force it and you are allowed to use multi actions controllers if you need them, by adding another public method and configuring it with the ``#[Route(...)]`` attribute.

Handling errors (missing rights, bad request, …)
++++++++++++++++++++++++++++++++++++++++++++++++

A controller may throw some exceptions if it receive an invalid request. Exceptions will automatically converted to error pages.

If you need exceptions with specific HTTP codes (like 4xx or 5xx codes), you can use any exception that extends ``Symfony\Component\HttpKernel\Exception\HttpException``.

GLPI also provide some custom Http exceptions in the ``Glpi\Exception\Http\`` namespace.

Missing rights
++++++++++++++

.. code-block:: php

   <?php
   public function __invoke(Symfony\Component\HttpFoundation\Request $request): Response
   {
       if (!Form::canUpdate()) {
           throw new \Glpi\Exception\Http\AccessDeniedHttpException();
       }
   }

Invalid header
++++++++++++++

.. code-block:: php

   <?php
   public function __invoke(Symfony\Component\HttpFoundation\Request $request): Response
   {
       if ($request->headers->get('Content-Type') !== 'application/json') {
           throw new \Symfony\Component\HttpKernel\Exception\UnsupportedMediaTypeHttpException();
       }
   }

Invalid input
+++++++++++++

.. code-block:: php

   <?php
   public function __invoke(Symfony\Component\HttpFoundation\Request $request): Response
   {
       $id = $request->request->getInt('id');
       if ($id == 0) {
           throw new \Glpi\Exception\Http\BadRequestHttpException();
       }
   }

Firewall
^^^^^^^^

By default, the GLPI firewall will not allow unauthenticated user to access your routes. You can change the firewall strategy with the ``Glpi\Security\Attribute\SecurityStrategy`` attribute.

.. code-block:: php

   <?php
   #[Glpi\Security\Attribute\SecurityStrategy(Glpi\Http\Firewall::STRATEGY_NO_CHECK)]
   public function __invoke(Symfony\Component\HttpFoundation\Request $request): Response

Possible responses
^^^^^^^^^^^^^^^^^^

You may use different responses classes depending on what your controller is doing (sending json content, outputting a file, …).

There is also a render helper method that helps you return a rendered Twig template as a Response object.

Sending JSON
++++++++++++

.. code-block:: php

   <?php
   return new Symfony\Component\HttpFoundation\JsonResponse(['name' => 'John', 'age' => 67]);

Sending a file from memory
++++++++++++++++++++++++++

.. code-block:: php

   <?php
   $filename = "my_file.txt";
   $file_content = "my file content";

   $disposition = Symfony\Component\HttpFoundation\HeaderUtils::makeDisposition(
       HeaderUtils::DISPOSITION_ATTACHMENT,
       $filename,
   );

   $response = new Symfony\Component\HttpFoundation\Response($file_content);
   $response->headers->set('Content-Disposition', $disposition);
   $response->headers->set('Content-Type', 'text/plain');
   return $response

Sending a file from disk
++++++++++++++++++++++++

.. code-block:: php

   <?php
   $file_path = 'path/to/file.txt';
   return new Symfony\Component\HttpFoundation\BinaryFileResponse($file_path);

Displaying a twig template
++++++++++++++++++++++++++

.. code-block:: php

   <?php
   return $this->render('path/to/my/template.html.twig', [
       'parameter_1' => 'value_1',
       'parameter_2' => 'value_2',
   ]);

Redirection
+++++++++++

.. code-block:: php

   <?php
   return new Symfony\Component\HttpFoundation\RedirectResponse($url);

General best practices
^^^^^^^^^^^^^^^^^^^^^^

Use thin controllers
++++++++++++++++++++

Controller should be *thin*, which mean they should contain the minimal code needed to *glue* together the pieces of GLPI needed to handle the request.

A good controller does only the following actions:

* Check the rights
* Validate the request
* Extract what it needs from the request
* Call some methods from a dedicated service class that can process the data (using DI in the future, not possible at this time)
* Return a ``Response`` object

Most of the time, this will take between 5 and 15 instructions, resulting in a small method.

Make your controller final
++++++++++++++++++++++++++

Unless you are making a generic controller that is explicitly made to be extended, set your controller as ``final``.

.. code-block:: php

   <?php
   ❌public class ApiController
   ✅final public class ApiController

Always restrict the HTTP method
+++++++++++++++++++++++++++++++

If your controller is only meant to be used with a specific HTTP method (e.g. `POST`), it is best to define it in the ``Route`` attribute.

It helps others developers understand how this route must be used and help debugging when misusing the route.

.. code-block:: php

   <?php
   ❌#[Route("/my_route”, name: “glpi_my_route”)] 
   ✅#[Route("/my_route”, name: “glpi_my_route”, methods: “GET”)]

Use uppercase first route names
+++++++++++++++++++++++++++++++

Since our routes will refer to GLPI itemtypes which contains upper cases letters, it is probably clearer to use *uppercase first* names for all our routes.

.. code-block:: php

   <?php
   ❌/ticket/timeline
   ✅/Ticket/Timeline

URL generation
++++++++++++++

Ideally, URLs should not be hard-coded but should instead be generated using their route names.

In your Controllers, you can inject the Symfony router in the constructor in order to generate URLs based on route names:

.. code-block:: php

    <?php
    namespace Glpi\Controller\Custom;

    use Glpi\Controller\AbstractController;
    use Symfony\Component\HttpFoundation\Request;
    use Symfony\Component\HttpFoundation\Response;
    use Symfony\Component\Routing\Attribute\Route;
    use Symfony\Component\Routing\Generator\UrlGeneratorInterface;

    class MyController extends AbstractController
    {
        public function __construct(
            private readonly UrlGeneratorInterface $router
        ) {
        }

        public function __invoke(Request $request): Response
        {
            $route_name = $this->router->generate('my_route');

            // ...
        }
    }

You can also do it in Twig templates, using the ``url()`` or ``path()`` functions:

.. code-block:: twig

    {{ path('my_route') }} {# Shows the url like "/my_route" #}
    {{ url('my_route') }} {# Shows the url like "http://localhost/my_route" #}

Check out the Symfony documentation for more details about these functions:

* ``url()`` https://symfony.com/doc/current/reference/twig_reference.html#url
* ``path()`` https://symfony.com/doc/current/reference/twig_reference.html#path
