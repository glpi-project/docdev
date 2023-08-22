Plugins
=======

GLPI provides facilities to develop plugins, and there are many `plugins that have been already published <http://plugins.glpi-project.org>`_.

.. note::

   Plugins are designed to add features to GLPI core.

   This is a sub-directory in the ``plugins`` of GLPI; that would contains all related files.

Generally speaking, there is really a few things you have to do in order to get a plugin working; many considerations are up to you. Anyways, this guide will provide you some guidelines to get a plugins repository as consistent as possible :)

If you want to see more advanced examples of what it is possible to do with plugins, you can take a look at the `example plugin source code <http://github.com/pluginsGLPI/example/>`_.

.. toctree::
   :maxdepth: 2

   guidelines
   requirements
   database
   objects
   hooks
   crontasks
   massiveactions
   tips
   notifications
   test
   tutorial
   javascript
