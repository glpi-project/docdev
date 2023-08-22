Javascript
==========

Vue.js
------

Please refer to :doc:`the core Vue developer documentation first <../devapi/javascript>`.

Plugins that wish to use custom Vue components must implement their own webpack config to build the components and add them to the `window.Vue.components` object.

Sample webpack config (derived from the config used in GLPI itself for Vue):
.. code-block:: javascript

    const webpack = require('webpack');
    const path = require('path');
    const VueLoaderPlugin = require('vue-loader').VueLoaderPlugin;

    const config = {
        entry: {
            'vue': './js/src/vue/app.js',
        },
        externals: {
            // prevent duplicate import of Vue library (already done in ../../public/build/vue/app.js)
            vue: 'window _vue',
        },
        output: {
            filename: 'app.js',
            chunkFilename: "[name].js",
            chunkFormat: 'module',
            path: path.resolve(__dirname, 'public/build/vue'),
            publicPath: '/public/build/vue/',
            asyncChunks: true,
            clean: true,
        },
        module: {
            rules: [
                {
                    // Vue SFC
                    test: /\.vue$/,
                    loader: 'vue-loader'
                },
                {
                    // Build styles
                    test: /\.css$/,
                    use: ['style-loader', 'css-loader'],
                },
            ]
        },
        plugins: [
            new VueLoaderPlugin(), // Vue SFC support
            new webpack.ProvidePlugin(
                {
                    process: 'process/browser'
                }
            ),
            new webpack.DefinePlugin({
                __VUE_OPTIONS_API__: false, // We will only use composition API
                __VUE_PROD_DEVTOOLS__: false,
            }),
        ],
        resolve: {
            fallback: {
                'process/browser': require.resolve('process/browser.js')
            },
        },
        mode: 'none', // Force 'none' mode, as optimizations will be done on release process
        devtool: 'source-map', // Add sourcemap to files
        stats: {
            // Limit verbosity to only usefull information
            all: false,
            errors: true,
            errorDetails: true,
            warnings: true,

            entrypoints: true,
            timings: true,
        },
        target: "es2020"
    };

    module.exports = config

Note the use of the ``externals`` option. This will prevent webpack from including Vue itself when building your components since it is already imported by the bundle in GLPI itself.
The core GLPI bundle sets ``window._vue`` to the vue module and the plugin's externals option will map any imports from 'vue' to that.
This will drastically reduce the size of your imports.

For your entrypoint, it is mostly the same as the core GLPI one except you should use the ``defineAsyncComponent`` method in ``window.Vue`` instead of importing it from Vue itself.

Example entrypoint:

.. code-block:: javascript

    // Require all Vue SFCs in js/src directory
    const component_context = import.meta.webpackContext('.', {
        regExp: /\.vue$/i,
        recursive: true,
        mode: 'lazy',
        chunkName: '/vue-sfc/[request]'
    });
    const components = {};
    component_context.keys().forEach((f) => {
        const component_name = f.replace(/^\.\/(.+)\.vue$/, '$1');
        components[component_name] = {
            component: window.Vue.defineAsyncComponent(() => component_context(f)),
        };
    });
    // Save components in global scope
    window.Vue.components = Object.assign(window.Vue.components || {}, components);

To keep your components from colliding with core components or other plugins, it you should organize them inside the `js/src/Plugin/Yourplugin` folder.
This will ensure plugin components are registered as ``Plugin/Yourplugin/YourComponent``. You can organize components further with additional subfolders.