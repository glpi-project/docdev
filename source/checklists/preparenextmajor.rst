Prepare next major release
--------------------------

Once a major release has been finished, it's time to think about the next one!

You'll have to remember a few steps in order to get that working well:

* bump version in ``config/define.php``
* create SQL empty script (copying last one) in ``install/mysql/glpi-{version}-empty.sql``
* change empty SQL file calls in ``inc/toolbox.class.php`` (look for the ``$DB->runFile`` call)
* create a PHP migration script copying provided template ``install/update_xx_xy.tpl.php``

  * change its main comment to reflect reality
  * change method name
  * change version in ``displayTitle`` and ``setVersion`` calls

* add the new ``case`` in ``install/update.php`` and ``tools/cliupdate.php``; that will include your new PHP migration script and then call the function defined in it
* change the ``include`` and the function called in the ``--force`` option part of the ``tools/cliupdate.php`` script

That's all, folks!