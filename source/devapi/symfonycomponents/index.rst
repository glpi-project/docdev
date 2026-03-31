Symfony Twig Components
=======================

.. versionadded:: 12.0

Twig Components is a `Symfony UX bundle <https://symfony.com/bundles/ux-twig-component/current/index.html>`_ giving us the possibility to configure component in PHP.

It also enable a cleaner integration and `vuejs` like integration making it easier to maintain and review (compared to the old macro integration).

Following components are available:

.. toctree::
    :maxdepth: 1

    alert

Recommended usage
^^^^^^^^^^^^^^^^^

Twig component support various integration mode, we recommend the following one:

.. code-block:: twig

    <twig:Alert title="My alert title" messages="My message" />

It exist a `component` twig method, this usage is not advise and should be use for rare case as it's less readable and less flexible (no block overload, visually blending with other twig method).

.. code-block:: twig

    {{ component('Alert', {
        type: 'warning',
        title: __('The Legacy API is enabled. It is recommended to only use the new API when possible.')
    }) }}
