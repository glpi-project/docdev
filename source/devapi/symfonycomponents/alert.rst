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
    <twig:Alert>
        <twig:block name="title">
            <h3 class="alert-title bg-green">
                We can also be more like a vue/nuxt component
            </h3>
        </twig:block>

        <div>
            My content custom alert content
        </div>
    </twig:Alert>

Variants
--------
