Alert
=====

.. versionadded:: 12.0.0

Renders an alert box (also known as callout) in the HTML.

Props and blocks are aligned on the `Symfony UX Toolkit bootstrap Alert <https://ux.symfony.com/toolkit/kits/bootstrap/components/alert>`_, so that the component stays easy to migrate to the Toolkit in the future.

.. image:: /_static/images/symfonycomponents/alert-1.png
   :alt: Danger alert

Props
-----

All props are optional.

* :code:`color` **string**.

  * Possible values: :code:`primary`, :code:`secondary`, :code:`success`, :code:`danger`, :code:`warning`, :code:`info` (default), :code:`light`, :code:`dark`.

* :code:`heading` **string|null**. The optional alert heading.

* :code:`content` **string**. The alert message, used when the ``content`` block is not overridden.

* :code:`icon` **string**. A CSS icon class, for example :code:`ti ti-info-circle`.

  * If not set, the icon is automatically determined from the alert ``color``.

* :code:`dismissible` **bool**. When ``true``, renders a dismiss button and the dismissal transition classes.

  * Default: ``false``.



* :code:`important` **bool**. When ``true``, the alert is visually highlighted (Tabler's ``alert-important``).

  * Default: ``false``.

* :code:`link_text` **string|null**. Label of the action link. If not defined, the :code:`link_url` is displayed instead.

* :code:`link_url` **string|null**. URL of an optional action link, either internal or external.

* :code:`link_blank` **bool**. If ``true``, the link target is :code:`_blank`, :code:`_self` otherwise.

  * Default: ``false``.

Additional attributes
^^^^^^^^^^^^^^^^^^^^^^

Any attribute that isn't one of the props above (for example ``class``, ``id``, ``data-*`` or ``role``) is forwarded to the root ``<div>`` element.
``class`` is *appended* to the component's own classes rather than replacing them:

.. code-block:: twig

    <twig:Alert class="mb-0" role="status" />

Blocks
------

heading
^^^^^^^

Completely overrides the heading, including the wrapping ``<h4>`` element.

content
^^^^^^^

Completely overrides the message area.

.. code-block:: twig

    <twig:Alert:Danger>
        <twig:block name="heading">
            <h2 class="alert-heading">
                Custom heading block
            </h2>
        </twig:block>

        <div>
            My alert content
        </div>
    </twig:Alert:Danger>

.. image:: /_static/images/symfonycomponents/alert-custom-block.png
   :alt: Example with custom twig block

close
^^^^^

The dismiss control, rendered only when ``dismissible`` is ``true``. Overriding it lets you replace the default close button entirely.

icon
^^^^

The leading icon, rendered before the heading. Overriding it with an empty block removes the icon.

action
^^^^^^

The action, rendered on the right of the content.

.. image:: /_static/images/symfonycomponents/alert-actions.png
   :alt: Example with action defined

Variants
--------

Pre-typed variant components are available as shortcuts:

.. code-block:: twig

    <twig:Alert:Success>Success alert</twig:Alert:Success>
    <twig:Alert:Info>Info alert</twig:Alert:Info>
    <twig:Alert:Warning>Warning alert</twig:Alert:Warning>
    <twig:Alert:Danger>Danger alert</twig:Alert:Danger>

    <twig:Alert>Main alert</twig:Alert>
    <twig:Alert color="danger">Main alert with color danger</twig:Alert>

.. image:: /_static/images/symfonycomponents/alert-variants.png
   :alt: Alert variants

.. note::

    The ``type``/``title``/``message`` prop names used before GLPI 12.0.0's initial release have been renamed
    to ``color``/``heading``/``content`` to match the Symfony UX Toolkit. There is no backward-compatibility
    alias; update any custom call site to use the new names.
