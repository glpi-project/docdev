Re-authentication ("sudo mode")
-------------------------------

.. versionadded:: 12.0

   Re-authentication is only available from GLPI 12.0, which is not released yet.
   Nothing described on this page exists in GLPI 11 or earlier.

Goals
^^^^^

Being authenticated is not enough to reach the most sensitive parts of GLPI (users, profiles
and rights, authentication settings, plugins, configuration, logs…). Before such a page is
displayed or such an action is performed, GLPI asks the user to prove their identity one more
time. This extra step is called **re-authentication**, informally *sudo mode*, by analogy with
the ``sudo`` command.

It mitigates the misuse of an already opened session: unattended workstation, stolen or
replayed session cookie, forged link (CSRF-like), injected script. None of these carry the
user's password, TOTP code or SSO credentials.

Once a verification succeeds, the user gets a **15 minutes** window
(``ReAuthManager::REAUTH_DELAY_SECONDS``) during which sensitive actions no longer trigger the
prompt.

.. important::

   Re-authentication is **not** a right. It never grants anything: it only adds a condition on
   top of the existing :doc:`rights checks <acl>`. An action forbidden by the profile stays
   forbidden.

Key properties to keep in mind while developing:

* It applies to **interactive HTTP requests only**. ``isAPI()`` and ``isCommandLine()``
  contexts are never prompted.
* Logging in does **not** open a window: the first sensitive action of a session always
  prompts.
* The window is not extended by activity, and its duration is not configurable.
* A request that cannot display the prompt (AJAX request, or a client that does not expect
  HTML) is **denied** with an ``AccessDeniedHttpException`` instead of being redirected.

Architecture
^^^^^^^^^^^^

Everything lives in the ``Glpi\Security\ReAuth`` namespace, plus a controller and a few
entry points on ``CommonGLPI`` / ``CommonDBTM``.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Class
     - Role
   * - ``Glpi\Security\ReAuth\ReAuthManager``
     - Singleton service. Holds the session state (is the user re-authenticated, which
       request has to be replayed), resolves the strategy to use, and exposes the entry
       point ``checkReAuthenticationOrRedirect()``.
   * - ``Glpi\Security\ReAuth\ReAuthStrategyInterface``
     - Contract of a verification method: is it available for that user, what does the
       prompt look like, how is the submission verified.
   * - ``Glpi\Security\ReAuth\InPlaceReAuthStrategy``
     - Abstract base class for strategies verified by GLPI itself. Provides the default
       verify URL (``/ReAuth/Verify``) and HTTP method (``POST``).
   * - ``Glpi\Security\ReAuth\ReAuthStrategyEnum``
     - Native strategies (``totp``, ``password``, ``ldap``, ``fallback``) and their
       factory.
   * - ``Glpi\Controller\Security\ReAuthController``
     - Routes ``/ReAuth/Prompt`` (display the form) and ``/ReAuth/Verify`` (verify, then
       replay the initial request).

``ReAuthManager`` uses ``SingletonTrait``, and is registered as an autowirable service in
``dependency_injection/services.php`` (a factory on ``getInstance()``).

* In a controller, **inject it**: ``public function __construct(private readonly ReAuthManager $reAuthManager) {}``
* In legacy code, use ``ReAuthManager::getInstance()``. Never ``new ReAuthManager()``.

Native strategies and priorities
++++++++++++++++++++++++++++++++

The prompt does not let the user choose: among all strategies available for that user, the one
with the **highest priority** wins.

.. list-table::
   :header-rows: 1
   :widths: 30 15 55

   * - Strategy
     - Priority
     - Available when
   * - ``TOTPReAuthStrategy``
     - 100
     - 2FA is enabled on the account.
   * - ``PasswordReAuthStrategy``
     - 50
     - Local GLPI account with a password.
   * - ``LdapReAuthStrategy``
     - 50
     - Account bound to an LDAP directory. Fails closed: a directory outage blocks the
       action.
   * - ``FallbackReAuthStrategy``
     - 0
     - Always. Only displays a confirmation and always succeeds, so a user with no other
       method is never locked out. It is **not** an identity check.

Request flow
++++++++++++

.. code-block:: text

   1. GET /front/user.form.php?id=2
        └─ right check → allowed, but re-authentication is missing
             └─ ReAuthManager::redirectToReauth()
                  ├─ stores the requested URL, HTTP method and POST/GET data in the session
                  ├─ stores the origin URL (referer) for the "Cancel" button
                  └─ throws RedirectException → /ReAuth/Prompt

   2. GET /ReAuth/Prompt
        └─ renders pages/reauth/prompt.html.twig
             (label + strategy template + Verify/Cancel buttons,
              form action = strategy getVerifyUrl() / getVerifyHttpMethod())

   3. POST /ReAuth/Verify
        ├─ ReAuthManager::verify($request) → strategy verify()
        ├─ on failure: the prompt is displayed again with an "Authentication failure" alert
        └─ on success:
             ├─ ReAuthManager::authenticate() → opens the 15 min window
             └─ renders pages/redirect_post.html.twig, which replays the initial request
                (same URL, same method, same POST data)

The replay is what makes the detour transparent: a submitted form is not lost, the user lands
on the page they asked for.

Session keys used
+++++++++++++++++

``glpi_reauth_until`` (expiration timestamp), ``glpi_reauth_requested_url``,
``glpi_reauth_requested_httpmethod``, ``glpi_reauth_requested_post_data``,
``glpi_reauth_origin_url``.

.. warning::

   ``ReAuthManager::authenticate()`` performs **no identity check**: it only opens the window.
   Calling it without having verified the user first is an authentication bypass. Outside of
   ``ReAuthController::verify()`` and of a strategy endpoint that did verify the user, do not
   call it.

.. _reauth_protect_page:

Protecting a page or an action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Protection is declared **per itemtype**, and enforced by the usual right check methods. There
is no per-page flag and no route attribute.

Step 1 — declare the itemtype as sensitive
++++++++++++++++++++++++++++++++++++++++++

Override ``itemTypeRequiresReauthentication()`` (defined on ``CommonGLPI``, returns ``false``
by default):

.. code-block:: php

   <?php

   use Override;

   class MySensitiveItem extends CommonDBTM
   {
       #[Override]
       protected static function itemTypeRequiresReauthentication(): bool
       {
           return true;
       }
   }

Core examples: ``User``, ``Profile``, ``Profile_User``, ``Group``, ``Group_User``, ``Config``,
``AuthLDAP``, ``AuthMail``, ``OAuthClient``, ``Glpi\Event``, ``Glpi\Inventory\Conf``.

The derived state is read through the ``final`` method
``CommonGLPI::isUserReauthenticationNeeded()``, which returns ``true`` only when the itemtype
requires it, the context is an HTTP request (not API, not CLI), and the current session has no
valid window.

Step 2 — use a right check that enforces it
+++++++++++++++++++++++++++++++++++++++++++

Nothing else is needed **if** the page checks its rights with the standard methods, because
they already handle the redirection. The declaration is not right-specific: once an itemtype is
sensitive, ``READ`` is prompted just like ``UPDATE``, so simply displaying such a page requires
a fresh proof of identity.

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Method
     - Behaviour when re-authentication is missing
   * - ``$item->check($id, $right, $input)``
     - Redirects to the prompt (throws ``RedirectException``).
   * - ``$item->checkGlobal($right)``
     - Redirects to the prompt.
   * - ``$itemtype::checkReAuthenticationOrRedirect()``
     - Redirects to the prompt. Use it when there is no item to check (a page displaying a
       list, a tool page…). It checks **no right at all**: keep your own right check.
   * - ``$item->can($id, $right, $input, $reauth_needed)``
     - Returns ``false`` and sets ``$reauth_needed`` to ``true``. **Does not** redirect.
   * - ``$item->canGlobal($right, $reauth_needed)``
     - Same as ``can()``.
   * - ``Session::haveRight()`` / ``Session::checkRight()``
     - **Nothing.** These are module-level right checks; they know nothing about
       re-authentication.

So the most common change when protecting an existing legacy page is to replace a bare right
check by an item check. This is exactly what was done for the plugins and marketplace pages:

.. code-block:: diff

   - Session::checkRight("config", UPDATE);
   + (new Config())->checkGlobal(UPDATE);

.. warning::

   ``Session::checkRight()`` and friends silently bypass re-authentication. If a sensitive page
   keeps using them, it stays unprotected even though its itemtype declares
   ``itemTypeRequiresReauthentication()``.

The ``$reauth_needed`` by-reference parameter of ``can()`` / ``canGlobal()`` exists for the
places that must distinguish *"forbidden"* from *"allowed, but a fresh proof of identity is
needed"* — typically to keep displaying a form whose submission will prompt later. Only trust
it when the method returned ``false``.

Step 3 — pages that are not itemtype-based
++++++++++++++++++++++++++++++++++++++++++

When the protected action does not map to an itemtype at all, call the manager directly:

.. code-block:: php

   <?php

   use Glpi\Security\ReAuth\ReAuthManager;

   // legacy front file (front/updatepassword.php)
   ReAuthManager::getInstance()->checkReAuthenticationOrRedirect();

.. code-block:: php

   <?php

   // controller: inject the service
   final class MySensitiveController extends AbstractController
   {
       public function __construct(private readonly ReAuthManager $reAuthManager) {}

       #[Route('/MySensitiveThing', name: 'my_sensitive_thing', methods: ['GET'])]
       public function __invoke(): Response
       {
           // right check first, re-authentication second
           if (!Session::haveRight('config', UPDATE)) {
               throw new AccessDeniedHttpException();
           }
           $this->reAuthManager->checkReAuthenticationOrRedirect();

           // …
       }
   }

.. note::

   Always keep the right check **before** the re-authentication check. Prompting a user who has
   no right on the action leaks information about what exists, and grants a window for nothing.

   When the action does involve a sensitive itemtype, ``check()`` / ``checkGlobal()`` already do
   both in the right order: calling ``checkReAuthenticationOrRedirect()`` on top of them is
   redundant.

Generic controllers
+++++++++++++++++++

``GenericFormController`` and ``GenericListController`` already call
``$class::checkReAuthenticationOrRedirect()``. An itemtype served by them is protected as soon
as it declares ``itemTypeRequiresReauthentication()``.

AJAX and non-HTML endpoints
+++++++++++++++++++++++++++

An AJAX request cannot display the prompt, so ``redirectToReauth()`` throws an
``AccessDeniedHttpException`` instead of redirecting (the check is
``!$request->isXmlHttpRequest() && $request->getPreferredFormat() === 'html'``).

Consequences when designing a sensitive feature:

* Do not put a sensitive action behind an AJAX-only endpoint, or the user will get a plain
  "access denied" with no way to recover other than reloading the page.
* Keep the *sensitive* part on a full page request, and let AJAX handle the non-sensitive
  parts.
* A sub-form loaded by AJAX may be displayed even though re-authentication is missing (see
  massive actions below), as long as the actual processing goes through a full page request
  that will prompt.

.. _reauth_massiveactions:

Massive actions
^^^^^^^^^^^^^^^

Massive actions are the one place where the check is not attached to a single item, because a
selection may mix itemtypes. See :doc:`massiveactions` for the massive actions themselves.

The processing entry point (``front/massiveaction.php``) prompts once for the whole selection:

.. code-block:: php

   <?php

   $ma         = new MassiveAction($_POST, $_GET, 'process');
   $item_types = get_item_types_from_post();

   $reauth_manager = ReAuthManager::getInstance();
   if ($reauth_manager->atLeastOneItemTypesRequiresReauthentication($item_types)) {
       // First pass (re-authentication needed): throws RedirectException.
       $reauth_manager->checkReAuthenticationOrRedirect();

       // Back from the prompt (or still inside an open window): make sure the user
       // returns to the calling page.
       $back_url = Html::getBackUrl();
       if ($back_url) {
           $ma->setRedirect($back_url);
       }
   }

``ReAuthManager::atLeastOneItemTypesRequiresReauthentication(array $item_types)`` returns
``true`` as soon as one of the given itemtypes requires re-authentication. It validates that
each entry is a ``CommonGLPI`` class and throws an ``InvalidArgumentException`` otherwise.

Because the massive action POST data is stored and replayed, the whole selection survives the
prompt: the user verifies once, then the action runs on every selected item.

What this means for a specific massive action (core or plugin):

* Nothing to declare on the action itself. Declaring the itemtype sensitive is enough.
* ``showMassiveActionsSubForm()`` runs through an AJAX call, so it must **not** refuse the
  display just because re-authentication is missing. Use the ``$reauth_needed`` flag, as
  ``MassiveAction`` does for the generic *Update* action:

  .. code-block:: php

     <?php

     // Display the sub-form if the right is granted, or if only a re-authentication
     // is missing (the action will be possible once re-authenticated).
     // No redirection is possible here: the file is called through AJAX.
     $reauth_needed = null;
     $allowed = $item->canGlobal(UPDATE, $reauth_needed);
     if (!$allowed && !$reauth_needed) {
         throw new AccessDeniedHttpException('Missing authorization');
     }

* ``processMassiveActionsForOneItemtype()`` needs no change: it is only reached after the
  prompt has been passed, so ``$item->can()`` behaves as usual.

.. _reauth_plugin_strategy:

Providing a re-authentication strategy from a plugin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
++++++++++++++++++++++++

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
+++++++++++++++++++++++++++++++++

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
+++++++++++++++++++

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
other plugin template (see :doc:`/plugins/controllers`).

Implementing a remote (out-of-band) strategy
++++++++++++++++++++++++++++++++++++++++++++

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
++++++++++++++++++++++++++++++++++++++++++++

* Plugin code is trusted code: a registered strategy is a security-critical component. A
  strategy always returning ``true`` disables the whole mechanism for the users it applies to.
* ``isAvailable()`` decides *who* gets your prompt, ``getPriority()`` decides *when* it wins
  over the native ones. Returning a high priority for users your strategy cannot actually
  verify would downgrade their protection.
* ``getPromptTemplate()`` and ``getVerifyUrl()`` are rendered into the prompt form. They are
  plugin-controlled values, not user input — never build them from a request parameter.
* Do not log the submitted secret.

Existing implementations
++++++++++++++++++++++++

* A minimal (no-op) demonstration plugin: `glpi-reauth-aware-demo-plugin
  <https://github.com/SebSept/glpi-reauth-aware-demo-plugin>`_. It registers a strategy doing
  nothing else than showing the wiring, and is the shortest way to see the three steps at work.
* A real out-of-band implementation: the **OAuth SSO** plugin, which verifies the identity
  through the identity provider the user logs in with.

Development and testing
^^^^^^^^^^^^^^^^^^^^^^^

Disabling the mechanism
+++++++++++++++++++++++

The ``GLPI_DISABLE_REAUTH`` constant (``false`` by default, defined in
``Glpi\Application\SystemConfigurator``) makes ``isReAuthenticated()`` always return ``true``.
It can be set in the local configuration file, and a warning is then displayed on the central
page.

.. warning::

   This is a temporary escape hatch, planned for removal in a later 12.x release. Do not rely
   on it, and do not use it as the way to make your own tests pass.

Unit and functional tests
+++++++++++++++++++++++++

The re-authentication suite is grouped:

.. code-block:: bash

   vendor/bin/phpunit --group reauth

``tests/src/Glpi/Security/ReAuth/ReAuthTrait.php`` provides the helpers needed to test a
protected page or a strategy:

* ``fakeWebContext()`` simulates an interactive HTTP request (and can simulate an AJAX one, to
  assert that the access is denied instead of redirected);
* ``makeVerifyRequest($user_input)`` builds a prompt submission as ``verify()`` receives it;
* ``resetReAuthManager()`` clears the singleton instance between tests.

End-to-end tests
++++++++++++++++

Since a freshly logged-in user is **not** re-authenticated, e2e tests reaching a sensitive page
must open the window explicitly. Test-only endpoints ``/test/reauth/grant`` and
``/test/reauth/revoke`` are registered in the ``testing`` and ``e2e_testing`` environments
only (``ReAuthManager::revoke()`` throws anywhere else).

* Playwright: the ``reauth`` fixture (``tests/e2e/utils/ReAuthenticator.ts``) exposes
  ``grant()`` and ``revoke()``; the prompt page object is
  ``tests/e2e/pages/ReAuthPromptPage.ts``.
* Cypress: ``cy.login()`` already calls ``cy.grantReauth()``. A test covering the prompt itself
  opts out with ``cy.revokeReauth()``.

Limits
^^^^^^

* No protection against a compromised password or a compromised authenticator: the target is
  the misuse of an opened *session*.
* Against an injected script, it raises the bar but does not close the door: the script cannot
  pass the prompt by itself, but it can act during an already open window.
* No dedicated audit trail of the prompts themselves.
* API, CLI and inventory agents are out of scope.
