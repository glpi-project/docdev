Symfony Twig Components
=======================

.. versionadded:: 12.0

Twig Components is a `Symfony UX bundle <https://symfony.com/bundles/ux-twig-component/current/index.html>`_ allowing to use components in Twig template, inspired by HTML components. It aims to replace Twig macros.

It also enables a cleaner integration with a :code:`Vue.js`-like syntax, making components easier to maintain and review compared to the legacy macro-based integration.

The following components are available:

.. toctree::
    :maxdepth: 1

    alert
    mfacodeinput

Usage
-----

Twig components support various integration modes. We recommend using the **Component HTML Syntax**.


Component HTML Syntax
^^^^^^^^^^^^^^^^^^^^^

`Symfony Documentation <https://symfony.com/bundles/ux-twig-component/current/index.html#component-html-syntax>`_

.. code-block:: twig

    <twig:Alert heading="My alert title" content="My message" />

This syntax resembles modern frontend frameworks.

To pass dynamic values such as variables, booleans, or arrays, prefix the prop name with ``:`` and use a Twig expression:

.. code-block:: twig

    <twig:Alert heading="Overridden title" :content="My message" color="danger" :important="true">
        <twig:block name="heading">
            <h4 class="alert-heading">
                Custom heading block
            </h4>
            {{ parent() }} {# Renders the parent content — here: "Overridden title" #}
        </twig:block>
    </twig:Alert>

Most components also support a default ``content`` block. To inject content into it, place your markup directly inside the ``<twig:xx>`` tag:

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

Attributes
^^^^^^^^^^

`Symfony Documentation <https://symfony.com/bundles/ux-twig-component/current/index.html#component-attributes>`_

Any attribute passed to a component tag that does not match a declared prop is not discarded: it is collected into a special ``attributes`` variable and can be rendered on the root element with ``{{ attributes.defaults({...}) }}``.

This is how consumers can pass ``class``, ``id``, ``data-*`` or ``role`` to a component without the component having to declare a prop for each of them:

.. code-block:: twig

    <div {{ attributes.defaults({class: 'alert alert-info', role: 'alert'}) }}>
        ...
    </div>

    {# <twig:Alert class="mb-0" /> renders: <div class="alert alert-info mb-0" role="alert"> #}

``class`` is handled specially: the defaults come first and the caller's value is appended, rather than one
replacing the other.

Creating a Component
--------------------

`Symfony Documentation <https://symfony.com/bundles/ux-twig-component/current/index.html>`_

A Twig component consists of two parts: a **PHP class** that declares the props and logic, and a **Twig template** that defines the markup.

The PHP Class
^^^^^^^^^^^^^

Create a class under ``src/Twig/Components/`` and annotate it with ``#[AsTwigComponent]``.

By default, **Public properties** become the component's props and are automatically available as variables in the template.

**Public methods** are also accessible from the template via the special ``this`` variable.

.. code-block:: php

    <?php
    namespace Twig\Components;

    use Symfony\UX\TwigComponent\Attribute\AsTwigComponent;

    #[AsTwigComponent(name: 'MyComponent', template: 'twig_components/MyComponent.html.twig')]
    class MyComponent
    {
        public string $title = '';
        public bool $important = false;

        public function getComputedClass(): string
        {
            return $this->important ? 'text-bold' : '';
        }
    }

The ``name`` parameter sets the tag name used in templates (``<twig:MyComponent />``). If omitted, it is derived from the class namespace relative to ``Twig\Components``.

The ``template`` parameter is also optional. If omitted, Symfony derives the template path from the class namespace, resolved under ``templates/twig_components/``.

.. note::

    For components with multiple variants (e.g., ``Alert:Success``, ``Alert:Danger``), the recommended pattern is to extract shared props and logic into an abstract base class, then create lightweight variant classes that extend it and override the relevant defaults. See ``src/Twig/Components/Alert/`` (`Github <https://github.com/glpi-project/glpi/tree/main/src/Twig/Components/Alert/>`_) for a real-world example. Its shared template lives in a dedicated ``templates/twig_components/Alert/`` folder, named ``Base.html.twig`` rather than ``Alert.html.twig``.

.. warning::

    Do not name a template file the same as its containing folder (e.g. ``templates/twig_components/Alert/Alert.html.twig``). GLPI's anonymous-component auto-discovery derives a component name from every template path under ``templates/twig_components/`` (``/`` becomes ``:``), so a folder and file sharing a name registers a false second component (here, ``Alert:Alert``) that is broken if ever invoked, since it has no backing PHP class.

The Twig Template
^^^^^^^^^^^^^^^^^

Place templates under ``templates/twig_components/``. Props are available directly as template variables. The component object itself is accessible via ``this``, which is useful for calling methods:

.. code-block:: twig

    <div class="{{ this.computedClass }}">
        {% block heading %}
            {% if title|length %}
                <h4>{{ title }}</h4>
            {% endif %}
        {% endblock %}

        {% block content %}{% endblock %}
    </div>

Define ``{% block %}`` sections for any part of the markup that consumers may need to override.

The ``{% block content %}`` block is special: any markup placed directly inside the component tag (without an explicit ``<twig:block>``) is injected into it automatically:

.. code-block:: twig

    <twig:Alert>This text is injected into the content block.</twig:Alert>

Variants
^^^^^^^^

Variant components share a base class and, typically, the same template. The class name determines the component tag name: a class ``Twig\Components\Alert\Danger`` automatically resolves to the tag ``<twig:Alert:Danger>``.

.. code-block:: php

    <?php
    namespace Twig\Components\Alert;

    use Symfony\UX\TwigComponent\Attribute\AsTwigComponent;

    #[AsTwigComponent(template: 'twig_components/Alert/Base.html.twig')]
    final class Danger extends AbstractAlert
    {
        public string $color = 'danger';
    }

The ``template`` parameter is specified explicitly here because all Alert variants share a single template file (``twig_components/Alert/Base.html.twig``).

Testing
^^^^^^^

Two levels of tests are recommended:

- **Unit tests**: instantiate the PHP class directly and assert prop defaults and method return values. No GLPI environment needed.
- **Rendering tests**: render a Twig string using ``TemplateRenderer::getInstance()->renderFromStringTemplate()`` and assert the resulting HTML. These extend ``GLPITestCase``.

Tests live in ``tests/functional/Twig/Components/`` (`GitHub <https://github.com/glpi-project/glpi/tree/main/tests/functional/Twig/Components/>`_). See ``AlertTest.php`` and ``AlertRenderingTest.php`` for examples.

Debugging
^^^^^^^^^

To list all registered components and their resolved template paths, run:

::

    bin/console symfony:debug:twig-component

    # Using Makefile
    make console c='symfony:debug:twig-component'
