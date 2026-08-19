Re-authentication ("sudo mode")
-------------------------------

.. versionadded:: 12.0

   Re-authentication is only available from GLPI 12.0.

Goals
^^^^^

Being authenticated is not enough to reach the most sensitive parts of GLPI (users, profiles
and rights, authentication settings, plugins, configuration, logs…). Before such a page is
displayed or such an action is performed, GLPI asks the user to prove their identity one more
time. This extra step is called **re-authentication**, informally *sudo mode*, by analogy with
the ``sudo`` command.

It targets the misuse of an **already opened session**: the attacker holds the session, but
neither the password, nor the TOTP code, nor the SSO credentials.

* **Unattended workstation, stolen or replayed session cookie**: the attacker acts with the
  session alone, and is stopped.
* **Forged link (CSRF-like)**: re-authentication is a second layer here, CSRF protection being
  the first one. It still matters when that first one fails: a cross-origin request can neither
  display the prompt nor supply the secret.
* **Injected script**: only partially. Such a script runs in the user's own browser, so it can
  ride an open window. It cannot open one, though, and a request that cannot display the prompt
  is denied rather than redirected.

Once a verification succeeds, the user gets a **15 minute** window
(``ReAuthManager::REAUTH_DELAY_SECONDS``) during which sensitive actions no longer trigger the
prompt.

.. important::

   Re-authentication is **not** a right. It never grants anything: it only adds a condition on
   top of the existing :doc:`rights checks <acl>`. An action forbidden by the profile stays
   forbidden.

.. warning::

   Re-authentication is only as strong as the strategy available to the user. When no other one
   applies, ``FallbackReAuthStrategy`` merely asks for a confirmation and always succeeds: no
   identity is checked.

Key properties to keep in mind while developing:

* It applies to **interactive HTTP requests only**. ``isAPI()`` and ``isCommandLine()``
  contexts are never prompted.
* Logging in does **not** open a window: the first sensitive action of a session always
  prompts.
* The window is not extended by activity, and its duration is not configurable.
* A request that cannot display the prompt (AJAX request, or a client that does not expect
  HTML) is **denied** with an ``AccessDeniedHttpException`` instead of being redirected.
  This may be improved later when core needed changes are made.

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
   * - ``Glpi\Kernel\Listener\RequestListener\ReAuthReplayListener``
     - Request listener restoring the origin page as the referer of the replayed request, so
       that what reads it — ``Html::back()`` most notably — sends the user back where they
       came from instead of into the re-authentication flow.

``ReAuthManager`` uses ``SingletonTrait``, and is registered as an autowirable service in
``dependency_injection/services.php`` (a factory on ``getInstance()``).

* In a controller, **inject it**: ``public function __construct(private readonly ReAuthManager $reAuthManager) {}``
* In legacy code, use ``ReAuthManager::getInstance()``.

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
                (same URL, same method, same data — ReAuthManager::getReplayData())

   4. the replayed request
        └─ ReAuthReplayListener restores the origin page as the referer

The replay is what makes the detour transparent: a submitted form is not lost, the user lands
on the page they asked for.

Coming back to the origin page
++++++++++++++++++++++++++++++

The replay is an auto-submitted form served by the verification page, so the browser reports
that page as the ``Referer`` of the replayed request. Anything reading it — ``Html::back()``
most notably — would then send the user back into the re-authentication flow instead of the
page the action was triggered from.

``ReAuthManager::getReplayData()`` therefore adds one parameter to the replayed request,
``_glpi_reauth_restore_referer`` (``ReAuthManager::RESTORE_REFERER_PARAM``). It lands in the
query string of a GET replay and in the body of a POST one, and ``ReAuthReplayListener`` acts
upon it before any controller runs — legacy scripts included: it reads the origin URL from the
session and writes it both on the Symfony request headers and on ``$_SERVER['HTTP_REFERER']``,
so both worlds see the same referer.

The parameter carries no value of its own: the URL is read from the session, never from the
request. A forged parameter can therefore only send the user back to their own origin page.

.. note::

   A replayed request carries that extra parameter. Code reading the whole query string or the
   whole POST payload must tolerate it.

Session keys used
+++++++++++++++++

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Session key
     - Holds
   * - ``glpi_reauth_until``
     - Expiration timestamp of the current window.
   * - ``glpi_reauth_requested_url``
     - The URL to replay once verified.
   * - ``glpi_reauth_requested_httpmethod``
     - The HTTP method of the replayed request.
   * - ``glpi_reauth_requested_post_data``
     - The data of the replayed request: the POST payload, or the query parameters of a GET.
   * - ``glpi_reauth_origin_url``
     - The page the action was triggered from. Used by the "Cancel" button of the prompt, and
       restored as the referer of the replayed request.

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
they already handle the redirection. The declaration is not right-specific; once an itemtype is
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

So, the most common change when protecting an existing legacy page is to replace a plain right
check by an item check. This is what was done for the plugin and marketplace pages:

.. code-block:: diff

   - Session::checkRight("config", UPDATE);
   + (new Config())->checkGlobal(UPDATE);

.. warning::

   ``Session::checkRight()`` and similar functions silently bypass re-authentication. If a sensitive page
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

* ``processMassiveActionsForOneItemtype()`` needs no change; it is only reached after the
  prompt has been passed, so ``$item->can()`` behaves as usual.

Providing a re-authentication strategy from a plugin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A plugin can contribute its own verification method (typically an OAuth/SSO plugin verifying
the identity through the identity provider) via ``ReAuthManager::registerStrategy()``. It
supplies only the *how* of verifying the identity: it cannot change the window duration, nor
which itemtypes are sensitive.

See :doc:`/plugins/reauthentication` for the whole recipe: registering the strategy,
implementing an in-place one, providing the prompt template, and delegating the verification to
an external service.

.. _reauth_dev_testing:

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
