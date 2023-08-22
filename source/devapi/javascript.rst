Javascript
==========

Vue.js
------

Starting in GLPI 10.1, we have added support for Vue.
.. note::

    Only SFCs (Single-file Components) using the Components API is supported. Do not use the Options API.

To ease integration, there is no Vue app mounted on the page body itself. Instead, each specific feature that uses Vue such as the debug toolbar mounts its own Vue app on a container element.
Components must all be located in the ``js/src/vue`` folder for them to be built.
Components should be grouped into subfolders as a sort of namespace separation.
There are some helpers stored in the ``window.Vue`` global to help manage components and mount apps.

### Building

Two npm commands exist which can be used to build or watch (auto-build when the sources change) the Vue components.

.. code-block:: bash

   npm run build:vue

.. code-block:: bash

   npm run watch:vue


The ``npm run build`` command will also build the Vue components in addition to the regular JS bundles.

To improve performance, the components are not built into a single file. Instead, webpack chunking is utilized.
This results a single smaller entrypoint ``app.js`` being generated and a separate file for each component.
The components that are automatically built utilize ``defineAsyncComponent`` to enable the loading of those components on demand.

Further optimizations can be done by directly including a Vue component inside a main component to ensure it is built into the main component's chunk to reduce the number of requests.
This could be useful if the component wouldn't be reused elsewhere. Just note that the child component would also have its own chunk generated since there is no way to exclude it.

### Mounting

The Vue `createApp` function can be located at `window.Vue.createApp`.
Each automatically built component is automatically tracked in `window.Vue.components`.

To create an app and mount a component, you can use the following code:

.. code-block:: javascript

   const app = window.Vue.createApp(window.Vue.components['Debug/Toolbar'].component);
   app.mount('#my-app-wrapper');

Replace ``Debug/Toolbar`` with the relative path to your component without the ``.vue`` extension and ``#my-app-wrapper`` with an ID selector for the wrapper element which would need to already existing in the DOM.

For more information about Vue, please refer to the `official documentation <https://vuejs.org/guide/introduction.html>`_.