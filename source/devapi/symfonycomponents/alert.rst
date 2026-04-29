Alert
=====

.. versionadded:: 12.0.0

Renders an alert box (also known as callout) in the HTML.

.. image:: /_static/images/symfonycomponents/alert-1.png
   :alt: Danger alert

Props
-----

All props are optional.

* :code:`type` **string**.

  * Possible values: :code:`info` (default), :code:`success`, :code:`warning`, :code:`danger`.

* :code:`title` **string**.

* :code:`messages` **string|array<string>**. The alert message. An array can be passed to display multiple messages.

* :code:`icon` **string**. A CSS icon class, for example :code:`ti ti-info-circle`.

  * If not set, the icon is automatically determined from the alert type.

* :code:`important` **bool**. When ``true``, the alert is visually highlighted.

  * Default: ``false``.

* :code:`link_text` **string**. Alert link, either internal or external.

* :code:`link_url` **string**. Text for the link. If not defined will display the :code:`link_text`

* :code:`link_blank` **bool**. If true link target will be :code:`_blank`, :code:`_self` otherwise

  * Default: ``true``.

Blocks
------

title
^^^^^

Completely overrides the title, including the wrapping ``<h4>`` element.

content
^^^^^^^

Completely overrides the message area.

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

Variants
--------

Pre-typed variant components are available as shortcuts:

.. code-block:: twig

    <twig:Alert:Success>Success alert</twig:Alert:Success>
    <twig:Alert:Info>Info alert</twig:Alert:Info>
    <twig:Alert:Warning>Warning alert</twig:Alert:Warning>
    <twig:Alert:Danger>Danger alert</twig:Alert:Danger>

    <twig:Alert>Main alert</twig:Alert>
    <twig:Alert type="danger">Main alert with type danger</twig:Alert>

.. image:: /_static/images/symfonycomponents/alert-variants.png
   :alt: Alert variants
