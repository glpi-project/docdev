Symfony Twig Components
=======================

.. versionadded:: 12.0

Twig Components is a `Symfony UX bundle <https://symfony.com/bundles/ux-twig-component/current/index.html>`_ that allows configuring components in PHP.

It also enables a cleaner integration with a :code:`Vue.js`-like syntax, making components easier to maintain and review compared to the legacy macro-based integration.

The following components are available:

.. toctree::
    :maxdepth: 1

    alert

Usage
-----

Twig components support various integration modes. We recommend using the **Component HTML Syntax**.


Component HTML Syntax
^^^^^^^^^^^^^^^^^^^^^

`Symfony Documentation <https://symfony.com/bundles/ux-twig-component/current/index.html#component-html-syntax>`_

.. code-block:: twig

    <twig:Alert title="My alert title" messages="My message" />

This syntax resembles modern frontend frameworks.

To pass dynamic values such as variables, booleans, or arrays, prefix the prop name with ``:`` and use a Twig expression:

.. code-block:: twig

    <twig:Alert title="Overridden title" :messages="['Message 1', 'Message 2']" type="danger" :important="true">
        <twig:block name="title">
            <h4 class="alert-title">
                Custom title block
            </h4>
            {{ parent() }} {# Renders the parent content — here: "Overridden title" #}
        </twig:block>
    </twig:Alert>

Most components also support a default ``content`` block. To inject content into it, place your markup directly inside the ``<twig:xx>`` tag:

.. code-block:: twig

    <twig:Alert:Danger>
        <twig:block name="title">
            <h2 class="alert-title">
                Custom title block
            </h2>
        </twig:block>

        <div>
            My alert content
        </div>
    </twig:Alert:Danger>

.. image:: /_static/images/symfonycomponents/alert-custom-block.png
   :alt: Example with custom twig block


Component Twig Syntax
^^^^^^^^^^^^^^^^^^^^^

There is also a ``component()`` Twig function, but its use is discouraged except in rare cases. It is less readable and less flexible than the HTML syntax (no block overrides, and it visually blends in with other Twig function calls).

.. code-block:: twig

    {{ component('Alert', {
        type: 'warning',
        title: __('My alert title.')
    }) }}

This integration mode will not be shown in the component documentation.
