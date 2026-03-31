Alert
=====

.. versionadded:: 12.0.0

Display an alert in the html where it is placed.

.. image:: /_static/images/symfonycomponents/alert-1.png
   :alt: Danger alert

Props
-----
All fields are optional.

* :code:`type` **string**.

  * Possible values: :code:`info` (default), :code:`success`, :code:`warning`, :code:`danger`.

* :code:`title` **string**.

* :code:`messages` **string|array<string>**. Message content, a list can be passed.

* :code:`icon` **string**. CSS icon class, for example :code:`ti ti-info-circle`.

  * If not defined, it will be calculated based on the alert type.

* :code:`important` **bool**. False by default, highlight the alert.

Blocks
------

title
^^^^^
Completely override the title field. Even the `<h4>` field

content
^^^^^^^
Completely override the message field.

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
Multiple variation of the Alert exist, you can find the listed options here:

.. code-block:: twig

    <twig:Alert:Success>Success alert</twig:Alert:Success>
    <twig:Alert:Info>Info alert</twig:Alert:Info>
    <twig:Alert:Warning>Warning alert</twig:Alert:Warning>
    <twig:Alert:Danger>Danger alert</twig:Alert:Danger>

    <twig:Alert>Main alert</twig:Alert>
    <twig:Alert type="danger">Main alert with type danger</twig:Alert>

.. image:: /_static/images/symfonycomponents/alert-variants.png
   :alt: Alert variants
