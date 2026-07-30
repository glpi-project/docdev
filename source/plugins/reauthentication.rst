.. _reauth_plugin_strategy:

Re-authentication ("sudo mode")
-------------------------------

.. versionadded:: 12.0

   Re-authentication is only available from GLPI 12.0, which is not released yet.

GLPI asks the user for a fresh proof of identity before a sensitive action (users, rights,
authentication settings, plugins, configuration…). The mechanism, its architecture and how a
page is protected are described in the core documentation:
:doc:`re-authentication </devapi/reauthentication>`.

A plugin interacts with it in two ways:

* it can declare its **own itemtypes as sensitive**, so that they require a re-authentication:
  see :ref:`protecting a page or an action <reauth_protect_page>`. Nothing plugin-specific
  there, the core methods apply as-is;
* it can provide its **own verification method** — a *strategy* — which is what the rest of this
  page describes.

Providing a re-authentication strategy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A plugin can contribute its own verification method — typically an OAuth/SSO plugin verifying
the identity through the identity provider. Registered strategies are merged with the native
ones and take part in the same priority-based selection.

A plugin supplies only the *how* of verifying the identity. It cannot change the window
duration, nor which itemtypes are sensitive.

Two flavours exist:

* **in place**: the prompt form is submitted to core (``/ReAuth/Verify``), which calls your
  ``verify()``;
* **remote / out-of-band**: the prompt form is submitted to **your own route**, which
  performs the verification and opens the window itself. ``verify()`` is then never called by
  core.

Registering the strategy
^^^^^^^^^^^^^^^^^^^^^^^^

In your ``plugin_init_myplugin()`` function:

.. code-block:: php

   <?php

   use Glpi\Security\ReAuth\ReAuthManager;
   use GlpiPlugin\MyPlugin\ReAuthStrategy;

   function plugin_init_myplugin(): void
   {
       ReAuthManager::getInstance()->registerStrategy(new ReAuthStrategy());
   }

Strategies are indexed by class name, so registering twice is harmless.

.. note::

   ``registerStrategy()`` is available from GLPI 12.0 only. If your plugin also supports
   GLPI 11, guard the call, for instance with
   ``if (method_exists(ReAuthManager::class, 'registerStrategy'))`` or a version check.

Implementing an in-place strategy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Extend ``InPlaceReAuthStrategy`` and implement the five remaining methods:

.. code-block:: php

   <?php

   namespace GlpiPlugin\MyPlugin;

   use Glpi\Security\ReAuth\InPlaceReAuthStrategy;
   use Override;
   use Plugin;
   use Symfony\Component\HttpFoundation\Request;

   final class ReAuthStrategy extends InPlaceReAuthStrategy
   {
       /** Human-readable label displayed above the form. Use your translation domain. */
       #[Override]
       public function getLabel(): string
       {
           return __('My plugin verification', 'myplugin');
       }

       /** Can this strategy be used for that user? */
       #[Override]
       public function isAvailable(int $users_id, int $entities_id = 0): bool
       {
           return Plugin::isPluginActive('myplugin') /* && … */;
       }

       /**
        * Verify the prompt form submission. Return true only on success.
        *
        * The whole request is passed, so a strategy may read as many fields (or headers)
        * as it needs. A single secret named `user_input` is only the simplest case.
        */
       #[Override]
       public function verify(int $users_id, Request $request): bool
       {
           $secret = (string) $request->request->get('user_input', '');

           if ($secret === '') {
               return false;
           }

           return /* your own check */ false;
       }

       /** Twig template rendering the form fields. */
       #[Override]
       public function getPromptTemplate(): string
       {
           return '@myplugin/reauth/reauth_form.html.twig';
       }

       /** Selection weight, highest available wins. Native: TOTP = 100, password = 50. */
       #[Override]
       public function getPriority(): int
       {
           return 120;
       }
   }

Rules to respect in ``verify()``:

* **Fail closed.** Return ``false`` on any unexpected condition (unreachable server, missing
  configuration, empty input). Never ``true`` "by default".
* Guard against empty secrets and null bytes when talking to an external service, as
  ``LdapReAuthStrategy`` does — some backends accept an anonymous bind on an empty password,
  which would turn the check into a bypass.
* Verify the identity of ``$users_id``, which is the **current session user**. Never take the
  user identifier from the request.
* Do not call ``ReAuthManager::authenticate()`` from ``verify()``: the controller does it once
  your method returned ``true``.

The prompt template
^^^^^^^^^^^^^^^^^^^

The template returned by ``getPromptTemplate()`` is included inside
``pages/reauth/prompt.html.twig``, which already provides the ``<form>`` element and the
*Verify* / *Cancel* buttons. It must therefore only render the fields:

.. code-block:: twig

   {# plugins/myplugin/templates/reauth/reauth_form.html.twig #}
   <p class="text-muted mb-2">{{ __('Enter the code sent to your device', 'myplugin') }}</p>
   <input type="text"
          name="user_input"
          class="form-control"
          autocomplete="off"
          required
          autofocus />

The ``@myplugin`` prefix resolves to the ``templates`` directory of your plugin, as for any
other plugin template (see :doc:`controllers`).

Implementing a remote (out-of-band) strategy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the identity is verified by an external service (OAuth/SSO, an external MFA provider…),
override ``getVerifyUrl()`` — and possibly ``getVerifyHttpMethod()`` — to point at one of your
own routes:

.. code-block:: php

   <?php

   #[Override]
   public function getVerifyUrl(): string
   {
       global $CFG_GLPI;

       return $CFG_GLPI['root_doc'] . '/MyPlugin/ReAuth/Verify';
   }

   #[Override]
   public function getVerifyHttpMethod(): string
   {
       return 'POST'; // or 'GET' to bounce to the identity provider
   }

.. danger::

   Overriding ``getVerifyUrl()`` **bypasses** core's ``verify()``: your endpoint fully owns the
   identity check, and opens the re-authentication window itself. Only do this when the
   verification genuinely happens out of band.

Your endpoint is then responsible for the last three steps of the flow. It must reproduce what
``ReAuthController::verify()`` does:

.. code-block:: php

   <?php

   namespace GlpiPlugin\MyPlugin\Controller;

   use Glpi\Controller\AbstractController;
   use Glpi\Http\Firewall;
   use Glpi\Security\Attribute\SecurityStrategy;
   use Glpi\Security\ReAuth\ReAuthManager;
   use Symfony\Component\HttpFoundation\Request;
   use Symfony\Component\HttpFoundation\Response;
   use Symfony\Component\Routing\Attribute\Route;

   final class ReAuthVerifyController extends AbstractController
   {
       public function __construct(private readonly ReAuthManager $reAuthManager) {}

       #[Route('/MyPlugin/ReAuth/Verify', name: 'myplugin_reauth_verify', methods: ['POST'])]
       #[SecurityStrategy(Firewall::STRATEGY_AUTHENTICATED)]
       public function __invoke(Request $request): Response
       {
           // 1. verify the identity of the *current session user* out of band.
           //    On failure: do not open any window, display the prompt again
           //    (or redirect to /ReAuth/Prompt).
           if (!$this->verifyThroughIdentityProvider($request)) {
               return $this->redirect($this->generateUrl('reauth_prompt'));
           }

           // 2. open the re-authentication window.
           $this->reAuthManager->authenticate();

           // 3. replay the request the user initially asked for.
           return $this->render('pages/redirect_post.html.twig', [
               'http_method' => $this->reAuthManager->getRequestedMethod(),
               'url'         => $this->reAuthManager->getRequestedURL(),
               'post_data'   => $this->reAuthManager->getRequestedPostData(),
           ]);
       }
   }

Points of attention for such an endpoint:

* Keep the route ``STRATEGY_AUTHENTICATED``: an anonymous request must never be able to reach
  ``authenticate()``.
* The verification **must** be about ``$_SESSION['glpiID']``. Binding the external identity to
  a user coming from the request is an account takeover.
* When the provider answers asynchronously (redirect back from the provider, callback), make
  sure the state you check cannot be forged or replayed, and only then call ``authenticate()``.
* Do not skip step 3, otherwise the user loses the action they had triggered.

Security considerations for strategy authors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Plugin code is trusted code: a registered strategy is a security-critical component. A
  strategy always returning ``true`` disables the whole mechanism for the users it applies to.
* ``isAvailable()`` decides *who* gets your prompt, ``getPriority()`` decides *when* it wins
  over the native ones. Returning a high priority for users your strategy cannot actually
  verify would downgrade their protection.
* ``getPromptTemplate()`` and ``getVerifyUrl()`` are rendered into the prompt form. They are
  plugin-controlled values, not user input — never build them from a request parameter.
* Do not log the submitted secret.

Existing implementations
^^^^^^^^^^^^^^^^^^^^^^^^

* A minimal (no-op) demonstration plugin: `glpi-reauth-aware-demo-plugin
  <https://github.com/SebSept/glpi-reauth-aware-demo-plugin>`_. It registers a strategy doing
  nothing else than showing the wiring, and is the shortest way to see the three steps at work.
* A real out-of-band implementation: the **OAuth SSO** plugin, which verifies the identity
  through the identity provider the user logs in with.

Testing your strategy
^^^^^^^^^^^^^^^^^^^^^

Since a freshly logged-in user is **not** re-authenticated, any test reaching a sensitive page
goes through the prompt. The helpers available to open or drop the window (PHPUnit trait,
Playwright fixture, Cypress commands) are listed in
:ref:`development and testing <reauth_dev_testing>`.
