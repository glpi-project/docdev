Symfony Twig Components
=======================

.. versionadded:: 12.0

Twig Components is a `Symfony UX bundle <https://symfony.com/bundles/ux-twig-component/current/index.html>`_ giving us the possibility to configure component in PHP.

It also enable a cleaner integration and :code:`vuejs` like integration making it easier to maintain and review (compared to the old macro integration).

Following components are available:

.. toctree::
    :maxdepth: 1

    alert

Usage
-----
Twig component support various integration mode, we recommend using the **Component HTML Syntax**


Component HTML Syntax
^^^^^^^^^^^^^^^^^^^^^

`Symfony Documentation <https://symfony.com/bundles/ux-twig-component/current/index.html#component-html-syntax>`_


.. code-block:: twig

    <twig:Alert title="My alert title" messages="My message" />

Using this syntax ressemble a lot like modern frontend framework.

For example, if you want to pass variables, boolean or array you can do a twig block like the following

.. code-block:: twig

    <twig:Alert title="Overridden tittle" :messages="['Message 1', 'Message 2']" type="danger" :important="true">
        <twig:block name="title">
            <h4 class="alert-title">
                Custom title block
            </h4>
            {{ parent() }} -- Injecting parent datas (here will be `Overridden tittle`)
        </twig:block>
    </twig:Alert>

Most of the component also have support the default block that should be named :code:`{% block content %}` inside the twig template.

To inject data into it, you just avec to set data inside the <twig:xx> block.

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

It exist a `component` twig method, this usage is not advise and should be use for rare case as it's less readable and less flexible (no block overload, visually blending with other twig method).

.. code-block:: twig

    {{ component('Alert', {
        type: 'warning',
        title: __('My alert title.')
    }) }}

In the components documentation we will not display this integration mode.
