
.. warning::

    ⚠️ Cette formation nécessite les pré-requis d'apprentissage suivants:

    - Une connaissance de l'usage de GLPI
    - Un niveau correct dans le développement WEB:
        - PHP
        - HTML
        - CSS
        - SQL
        - Javascript (Jquery)
    - être familier de l'utilisation de la ligne de commande


Développement d'un plugin
=========================

📝 Dans cette première partie, nous allons créer un nouveau plugin que nous nommerons "My plugin" (clef : ``myplugin``).
Nous couvrirons le démarrage du projet ainsi que la mise en place des éléments de base.

Pré-requis
----------

Voici la liste des briques nécessaires au démarrage de votre projet de plugin GLPI:

* un serveur web fonctionnel,
* la dernière version stable de `GLPI <https://github.com/glpi-project/glpi/releases>`_ installée en local,
* un éditeur de texte ou IDE (par ex `vscode <https://code.visualstudio.com>`_ ou `phpstorm <https://www.jetbrains.com/phpstorm/>`_),
* le gestionnaire de version `git <https://git-scm.com/>`_.
* le gestionnaire de dépendances PHP: `Composer`_

Amorcez votre projet
--------------------

.. warning::

    ⚠️ Si vous possédez une copie des données de production dans votre glpi, assurez-vous, avant de commencer la formation, de désactiver les notifications par mail sur votre instance locale.
    Ceci afin d'éviter d'envoyer des mails non désirés à des utilisateurs présents dans les données importées.


Tout d’abord, voici quelques ressources:

* le plugin `Empty`_ et sa `documentation <https://glpi-plugins.readthedocs.io/en/latest/empty/index.html>`_. Ce plugin est un kit (ou squelette) de démarrage rapide d'un nouveau plugin.
* le plugin `Example <https://github.com/pluginsGLPI/example>`_. Il se veut exhaustif dans l'utilisation des possibilités offertes par l'api interne de GLPI pour les plugins.


Mon nouveau plugin
^^^^^^^^^^^^^^^^^^

Clonez avec git le dépôt du plugin ``empty`` directement dans le répertoire ``plugins`` de votre dossier GLPI.

.. code-block:: bash

   cd /path/to/glpi/plugins
   git clone https://github.com/pluginsGLPI/empty.git

Vous pouvez maintenant utiliser le script ``plugin.sh`` qui se trouve dans le répertoire ``empty`` pour créer votre nouveau plugin. Vous devez lui passer en paramètre le nom de votre plugin et le numéro de la première version, exemple avec ``myplugin`` :

.. code-block:: shell

   cd empty
   chmod +x plugin.sh
   ./plugin.sh myplugin 0.0.1

.. note::

    | ℹ️ Veuillez noter qu'il faut absolument respecter certaines conditions pour le choix du nom du plugin : aucun espace et aucun caractère spécial n'est autorisé.
    | Ce nom est ensuite utilisé pour déclarer le répertoire de votre plugin ainsi que les noms des fonctions, des constantes, etc.
    | ``My-Plugin`` va également créer un répertoire ``MyPlugin``.
    | Les majuscules dans le nom du dossiers vont poser problème pour certaines fonctions du cœur.

    Restez simple !


Une fois la commande lancée, cela va créer un répertoire ``myplugin`` au même niveau que le répertoire ``empty`` que vous avez dans le dossier ``/path/to/glpi/plugin``, ainsi que les fichiers et méthodes associés à un squelette vide d'un plugin.

.. note::

    ℹ️ Si votre outil ``empty`` n'est pas dans le répertoire de votre GLPI, vous pouvez préciser un répertoire de destination de votre nouveau plugin, exemple :

    .. code-block:: shell

        ./plugin.sh myplugin 0.0.1 /path/to/another/glpi/plugins/

Récupération des dépendances `Composer`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Dans votre terminal, depuis le dossier du plugin, lancez la commande suivante:

.. code-block:: shell

   cd ../myplugin
   composer install


Structure minimale d'un plugin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. raw:: html

   <pre>
   📂 glpi
     📂 plugins
       📂 myplugin
          📁 ajax
          📁 front
          📁 src
          📁 locales
          📁 tools
          📁 vendor
          🗋 composer.json
          🗋 hook.php
          🗋 LICENSE
          🗋 myplugin.xml
          🗋 myplugin.png
          🗋 Readme.md
          🗋 setup.php
   </pre>

* Le dossier ``📂 front`` sert à recevoir les actions de nos objets (ajouter, modifier, afficher, etc).
* Le dossier ``📂 ajax`` reçoit les appels ajax (jquery).
* Vos classes seront placées dans le dossier ``📂 src``.
* Si besoin, les traductions au format `gettext`_ seront stockées dans le dossier ``📂 locales``.
* Le dossier optionnel ``📂 templates`` contient les fichiers de templates TWIG de votre plugin.
* Le dossier ``📂 tools`` contient de base (fourni par le plugin empty) un ensemble de scripts optionnels pouvant être utilisés pour la maintenance et le développement de votre plugin. Il est maintenant plus courant d'obtenir ces scripts via les dossiers ``📂 vendor`` et ``📂 node_modules``.
* Le dossier ``📂 vendor`` contient:
  * des librairies php pour votre plugin,
  * des outils d'aide au développement fourni par le modèle ``empty``.

* Le dossier ``📂 node_modules`` contient:
  * des librairies javascript pour votre plugin,

* le fichier ``🗋 composer.json`` décrit les dépendances PHP de votre projet.
* le fichier ``🗋 package.json`` décrit les dépendances javascript de votre projet.
* le fichier ``🗋 myplugin.xml`` fournit pour la `publication de votre plugin <#publier-votre-plugin>`_ , les données le décrivant.
* l'image ``🗋 myplugin.png`` est généralement incluse dans le contenu du fichier précédent et sert à représenter votre plugin dans le `catalogue <http://plugins.glpi-project.org>`_
* le fichier ``🗋 setup.php`` <#setupphp-minimal>`_ permet d'initialiser votre plugin.
* le fichier ``🗋 hook.php`` <#hookphp-minimal>`_ comporte les fonctions de base de votre plugin (des-installation, hooks généralistes, etc).


setup.php minimal
^^^^^^^^^^^^^^^^^

Suite à l'utilisation du script ``plugin.sh``, votre répertoire ``📂 myplugin`` doit contenir le fichier ``🗋 setup.php``

Il doit contenir les parties de code suivantes:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   define('PLUGIN_MYPLUGIN_VERSION', '0.0.1');

Une déclaration optionnelle de constante pour le numéro de version utilisé plus loin (dans la fonction ``plugin_version_myplugin`` ).


**🗋 setup.php**

.. code-block:: php
   :lineno-start: 3

   <?php

   function plugin_init_myplugin() {
      global $PLUGIN_HOOKS;

      $PLUGIN_HOOKS['csrf_compliant']['myplugin'] = true;
   }

Cette fonction d'initialisation est importante, nous y déclarerons plus tard nos ``Hooks`` sur l'api interne de GLPI.
Elle est systématiquement lancée sur **toutes** les pages de GLPI sauf si la fonction ``_check_prerequisites`` n'est pas vérifiée (voir plus bas).
Nous déclarons, à minima, que les formulaires du plugin sont protégés contre les vulnérabilités `CSRF <https://fr.wikipedia.org/wiki/Cross-Site_Request_Forgery>`_ même si pour le moment notre plugin ne contient aucun formulaire.


**🗋 setup.php**

.. code-block:: php
   :lineno-start: 9

   <?php

   // Minimal GLPI version, inclusive
   define("PLUGIN_MYPLUGIN_MIN_GLPI_VERSION", "10.0.0");

   // Maximum GLPI version, exclusive
   define("PLUGIN_MYPLUGIN_MAX_GLPI_VERSION", "10.0.99");

   function plugin_version_myplugin()
   {
       return [
           'name'           => 'MonNouveauPlugin',
           'version'        => PLUGIN_MYPLUGIN_VERSION,
           'author'         => '<a href="http://www.teclib.com">Teclib\'</a>',
           'license'        => 'MIT',
           'homepage'       => '',
           'requirements'   => [
               'glpi' => [
                   'min' => PLUGIN_MYPLUGIN_MIN_GLPI_VERSION,
                   'max' => PLUGIN_MYPLUGIN_MAX_GLPI_VERSION,
               ]
       ];
   }

Cette fonction permet de spécifier les différentes données qui seront affichées dans le menu ``Configuration > Plugins`` de GLPI ainsi que quelques contraintes minimales.
Nous réutilisons la constante ``PLUGIN_MYPLUGIN_VERSION`` déclarée plus haut.
Vous pouvez changer les différentes lignes pour adapter à vos coordonnées.

.. note::

    ℹ️ **Choix d'une licence**

    Le choix d'une licence est **important** et a de nombreuses conséquences sur l'usage futur de vos développements. En fonction de vos préférences, vous pouvez choisir une orientation plus permissive ou contraignante.
    Des sites existent pour vous aider dans ce choix tel que https://choosealicense.com/.

    Dans l'exemple, la licence choisie est `MIT <https://fr.wikipedia.org/wiki/Licence_MIT>`_.
    C'est un choix très populaire qui laisse à l'utilisateur beaucoup de libertés dans l'utilisation de vos travaux. Elle demande simplement de conserver la notice (le texte de la licence) et de respecter le copyright; vous ne pouvez pas être dépossédés de vos travaux, la paternité devant être conservée.

**🗋 setup.php**

.. code-block:: php
   :lineno-start: 32

   <?php

   function plugin_myplugin_check_config($verbose = false)
   {
       if (true) { // Your configuration check
           return true;
       }

       if ($verbose) {
           _e('Installed / not configured', 'myplugin');
       }

       return false;
   }

Cette fonction est appelée systématiquement sur **toutes** les pages de GLPI.
Elle permet de désactiver automatiquement le plugin si les critères définis ne sont pas ou plus vérifiés (en retournant ``false``).


hook.php minimal
^^^^^^^^^^^^^^^^

Ce fichier doit contenir à minima les fonctions d'installation et de désinstallation:

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   function plugin_myplugin_install()
   {
       return true;
   }

   function plugin_myplugin_uninstall()
   {
       return true;
   }

Quand toutes les étapes sont correctes, nous devons retourner ``true``.
Nous remplirons ces fonctions plus loin dans ce document avec des créations et suppressions de tables.


Installez votre plugin
^^^^^^^^^^^^^^^^^^^^^^

.. image:: /_static/images/install_plugin.png
   :alt: mon plugin listé dans la configuration


Suite à ces premières étapes, votre plugin doit pouvoir s'installer et s'activer dans le menu ``Configuration > Plugins``.


Création d'un objet
-------------------

| 📝 Dans cette partie, nous allons ajouter un itemtype dans notre plugin et le faire interagir avec GLPI.
| Celui-ci sera un objet maître permettant de regrouper plusieurs "assets".
| Nous le nommerons "Superasset".

Utilisation de `CommonDBTM`_ et création de classes métier
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Cette super classe permet de manipuler les tables MySQL via du code php.
Vos classes métiers (présentes dans le dossier ``src``) peuvent hériter de celle-ci et sont appelées "itemtype" par convention.

.. note::

    ℹ️ **Conventions:**

    * Les classes doivent impérativement suivre `le modèle de nommage PSR-12 <https://www.php-fig.org/psr/psr-12/>`_. Nous maintenons un guide à ce propos dans la `documentation développeur <https://glpi-developer-documentation.readthedocs.io/en/master/codingstandards.html>`_

    * `Les tables SQL <https://glpi-developer-documentation.readthedocs.io/en/master/devapi/database/dbmodel.html#naming-conventions>`_ correspondantes à vos classes doivent suivre ce schéma de nommage: ``glpi_plugin_pluginkey_names``
        * un préfixe global ``glpi_``
        * un préfixe pour les plugins ``plugin_``
        * la clef du plugin ``myplugin_``
        * le nom de l'itemtype au pluriel ``superassets``

    * `Les champs de tables <http://glpi-developer-documentation.readthedocs.io/en/master/devapi/dbmodel.html#fields>`_ suivent aussi quelques conventions:
        * il y a impérativement une clef ``auto-incremented primary`` nommée ``id``
        * les clefs étrangères sont nommées comme le nom de la table à laquelle elles font référence sans le préfixe ``glpi_`` et avec un suffixe ``id``, exemple: ``plugin_myotherclasses_id`` fait référence à la table ``glpi_plugin_myotherclasses``

        **Attention !** GLPI n'utilise pas de contrainte forte pour sa gestion des clefs étrangères. N'utilisez donc pas les mots clefs ``FOREIGN`` ou ``CONSTRAINT``.

    * quelques conseils supplémentaire :
        * finissez toujours vos fichiers par un retour à la ligne supplémentaire
        * ne mettez pas de balise php fermante ``?>``, voir https://www.php.net/manual/fr/language.basic-syntax.instruction-separation.php


        Pour ces points, la raison est pour éviter des erreurs de concaténations lors de l'utilisation des fonctions require/include


Nous allons créer notre première classe en plaçant un fichier ``🗋 Superasset.php`` dans le dossier ``📂src`` de notre plugin:

.. raw:: html

   <pre>
   📂glpi
      📂plugins
         📂myplugin
            ...
            📂src
               🗋 Superasset.php
            ...
   </pre>


Nous déclarerons à minima quelques parties:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php
   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;

   class Superasset extends CommonDBTM
   {
       // right management, we'll change this later
       static $rightname = 'computer';

       /**
        *  Name of the itemtype
        */
       static function getTypeName($nb=0)
       {
           return _n('Super-asset', 'Super-assets', $nb);
       }
   }

.. warning::

    ⚠️  **Attention:**
    Le ``namespace`` doit respecter le `CamelCase <https://en.wikipedia.org/wiki/Camel_case>`_

.. note::

    ℹ️  Voici les méthodes les plus couramment utilisées, héritées de `CommonDBTM`_ :

    `add(array $input) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1229-L1240>`_
    :  Ajoute un nouvel objet dans la table.
    Le paramètre input contient les champs de la table.
    Si l'ajout se passe correctement, l'objet sera rempli avec les données fournies.
    Elle renvoie l'id de la ligne ajoutée ou ``false`` dans le cas d'une erreur.

    .. code-block:: php
       :linenos:

        <?php

        namespace GlpiPlugin\Myplugin;
        use Toolbox;

        $superasset = new Superasset;
        $superassets_id = $superasset->add([
                'name' => 'My super asset'
        ]);
        if (!superassets_id) {
            Toolbox::logDebug("we failed to create my super asset");
        }

    `getFromDB(integer $id) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L285-L292>`_
    :  Charge l'id d'une ligne dans l'objet courant.
    Les données ainsi récupérées seront disponibles dans la propriété ``fields`` de l'objet
    Elle retourne ``false`` dans le cas où l'objet n'existe pas.

    .. code-block:: php
        :lineno-start: 11

        <?php

        use Toolbox;

        if ($superasset->getFromDB($superassets_id)) {
            Toolbox::logDebug($superasset->fields);
        }

    `update(array $input) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1561-L1570>`_
    :  Met à jour les champs de ligne identifiée par la clef ``id`` avec le paramètre $input
    Cette clef ``id`` doit être inclue dans le paramètre input.
    Renvoi un booléen.

    .. code-block:: php
        :lineno-start: 16

        <?php

        use Toolbox;

        if ($superasset->update([
                'id'      => $superassets_id,
                'comment' => 'my comments'
        ])) {
            Toolbox::logDebug($superasset->fields);
        }

    `delete(array $input, bool $force = false) <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2027-L2036>`_
    :  Supprime la ligne identifiée par la clef id (présente dans ``$input`` ).
    Le paramètre force permet d'indiquer si la ligne doit être mise en corbeille (``false`` , un champ ``is_deleted`` est nécessaire dans la table associée à votre classe) ou supprimé complétement de la table (``true``).
    Cette méthode renvoie un booléen.

    .. code-block:: php
        :lineno-start: 23

        <?php

        use Toolbox;

        if ($superasset->delete(['id' => $superassets_id])) {
            Toolbox::logDebug("My super asset is in trashbin");
        }

        if ($superasset->delete(['id' => $superassets_id], true)) {
            Toolbox::logDebug("My super asset is purged");
        }

Installation
^^^^^^^^^^^^

Dans la fonction ``plugin_myplugin_install`` de votre fichier ``🗋 hook.php``, nous allons gérer la création de la table MySQL correspondante à notre itemtype ``Superasset``.

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use DBConnection;
   use GlpiPlugin\Myplugin\Superasset;
   use Migration;

   function plugin_myplugin_install()
   {
       global $DB;

       $default_charset   = DBConnection::getDefaultCharset();
       $default_collation = DBConnection::getDefaultCollation();

       // instantiate migration with version
       $migration = new Migration(PLUGIN_MYPLUGIN_VERSION);

       // create table only if it does not exist yet!
       $table = Superasset::getTable();
       if (!$DB->tableExists($table)) {
           //table creation query
           $query = "CREATE TABLE `$table` (
                     `id`         int unsigned NOT NULL AUTO_INCREMENT,
                     `is_deleted` TINYINT NOT NULL DEFAULT '0',
                     `name`      VARCHAR(255) NOT NULL,
                     PRIMARY KEY  (`id`)
                    ) ENGINE=InnoDB
                    DEFAULT CHARSET={$default_charset}
                    COLLATE={$default_collation}";
           $DB->queryOrDie($query, $DB->error());
       }

       //execute the whole migration
       $migration->executeMigration();

       return true;
   }

Nous ajoutons ici, en plus d'une clef primaire, un champ de type ``VARCHAR`` qui pourra contenir un nom saisi par l'utilisateur ainsi qu'un flag indiquant la mise en corbeille de la ligne.

.. note::
    📝 Vous pouvez, si vous le souhaitez, ajouter d'autres champs (restez raisonnable :wink:) avec d'autres types.

Pour gérer nos migrations d'une version à une autre de notre plugin, nous pouvons utiliser la classe `Migration`_ de GLPI.

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use Migration;

   function plugin_myplugin_install()
   {
       global $DB;

       // instantiate migration with version
       $migration = new Migration(PLUGIN_MYPLUGIN_VERSION);

       ...

       if ($DB->tableExists($table)) {
           // missing field
           $migration->addField(
               $table,
               'fieldname',
               'string'
           );

           // missing index
           $migration->addKey(
               $table,
               'fieldname'
           );
       }

       //execute the whole migration
       $migration->executeMigration();

       return true;
   }

.. warning::

  ℹ️ La classe `Migration `_ inclut de nombreuses méthodes permettant de manipuler vos tables et champs.
  Tous les appels seront ajoutés à un registre des changements et seront finalement exécutés lors de l'appel de la méthode ``executeMigration``.

  Voici quelques exemples:

  `addField($table, $field, $type, $options) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L389-L407>`_
    ajoute un nouveau champ à une table

  `changeField($table, $oldfield, $newfield, $type, $options) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L462-L479>`_
    Modifie le nom ou le type d'un champ d'une table

  `dropField($table, $field) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L534-L542>`_
    Supprime un champ d'une table

  `dropTable($table) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L553-L560>`_
    Supprime une table.

  `renameTable($oldtable, $newtable) <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L654-L662>`_
    Renomme une table.

  Consultez la documentation de la classe `Migration`_ pour les autres méthodes disponible.

  .. raw:: html

    <hr />

  le paramètre ``$type`` des différentes fonctions est le meme que pour la méthode privée `fieldFormat <https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php#L252-L262>`_ de la classe `Migration`_ et permet un raccourci pour les types SQL les plus courants (bool, string, integer, date, datatime, text, longtext,  autoincrement, char)


Désinstallation
^^^^^^^^^^^^^^^

Pour désinstaller notre plugin, nous souhaitons "nettoyer" toutes les données ajoutées lors de l'installation et aussi celle saisies par l'utilisateur (nous verrons plus tard que nous pouvons ajouter des données concernant nos classes dans des objets natifs de GLPI).

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;

   function plugin_myplugin_uninstall()
   {
       global $DB;

       $tables = [
           Superasset::getTable(),
       ];

       foreach ($tables as $table) {
           if ($DB->tableExists($table)) {
               $DB->queryOrDie(
                   "DROP TABLE `$table`",
                   $DB->error()
               );
           }
       }

      return true;
   }


Utilisation du framework
^^^^^^^^^^^^^^^^^^^^^^^^

Quelques fonctions utilitaires supplémentaires:

.. code-block:: php

   <?php

   Toolbox::logError($var1, $var2, ...);

Cette méthode permet d'enregistrer dans le fichier ``glpi/files/_log/php-errors.log`` le contenu de ses paramètres (qui peuvent être des chaînes de caractères, des tableaux, des objets instanciés, des booléens, etc).

.. code-block:: php

   <?php

   Html::printCleanArray($var);

Cette méthode affichera un tableau de "debug" de la variable fournie en paramètre. Elle n'accepte pas d'autre type que ``array``.


Actions courantes sur un objet
------------------------------

.. note::

    📝 Nous allons maintenant  ajouter les actions les plus communes à notre itemtype ``Superasset``:

    * Afficher une liste et un formulaire d'ajout / édition
    * définir les routes d'ajout / modification / suppression

Dans notre dossier ``front``, nous allons avoir besoin de deux nouveaux fichiers.

.. raw:: html

   <pre>
   📂 glpi
      📂 plugins
         📂 myplugin
            ...
            📂 front
               🗋 superasset.php
               🗋 superasset.form.php
            ...
   </pre>


.. warning::

    ℹ️ Dans ces fichiers, nous ferons appel au framework de glpi via le code suivant:

    .. code-block:: php

        <?php

        include ('../../../inc/includes.php');

Le premier fichier du nom de notre itemtype (``superasset.php``) permettra d'afficher la liste des lignes sauvegardées dans notre table.

Il utilisera la méthode show du `moteur de recherche`_ (Search) interne de GLPI.

**🗋 front/superasset.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;

   include ('../../../inc/includes.php');

   Html::header(Superasset::getTypeName(),
                $_SERVER['PHP_SELF'],
                "plugins",
                Superasset::class,
                "superasset");
   \Search::show(Superasset::class);
   \Html::footer();

Les fonctions ``header`` et ``footer`` de la classe `Html`_ nous permettent d'habiller notre page avec l'interface graphique de glpi (menu, fil d’Ariane, bas de page, etc).

Le second fichier (``superasset.form.php``) avec le suffixe ``.form`` recevra les actions courantes CRUD.

**🗋 front/superasset.form.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;
   use Html;

   include ('../../../inc/includes.php');

   $supperasset = new Superasset();

   if (isset($_POST["add"])) {
       $newID = $supperasset->add($_POST);

       if ($_SESSION['glpibackcreated']) {
           \Html::redirect(Superasset::getFormURL()."?id=".$newID);
       }
       Html::back();

   } else if (isset($_POST["delete"])) {
       $supperasset->delete($_POST);
       $supperasset->redirectToList();

   } else if (isset($_POST["restore"])) {
       $supperasset->restore($_POST);
       $supperasset->redirectToList();

   } else if (isset($_POST["purge"])) {
       $supperasset->delete($_POST, 1);
       $supperasset->redirectToList();

   } else if (isset($_POST["update"])) {
       $supperasset->update($_POST);
       \Html::back();

   } else {
       // fill id, if missing
       isset($_GET['id'])
           ? $ID = intval($_GET['id'])
           : $ID = 0;

       // display form
       Html::header(
          Superasset::getTypeName(),
          $_SERVER['PHP_SELF'],
          "plugins",
          Superasset::class,
          "superasset"
       );
       $supperasset->display(['id' => $ID]);
       Html::footer();
   }

Toutes les actions courantes définies dans ce fichier sont gérées automatiquement par la classe `CommonDBTM`_.
Pour l'action manquante d'affichage, nous allons créer une méthode ``showForm`` dans notre classe ``Superasset``.
À noter que celle-ci existe déjà dans la superclasse ``CommonDBTM`` et s'affiche via un template TWIG générique.

Nous allons donc utiliser notre propre template qui étendra le générique (celui-ci affichant seulement les champs communs).

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Glpi\Application\View\TemplateRenderer;

   class Superasset extends CommonDBTM
   {

        ...

       function showForm($ID, $options=[])
       {
           $this->initForm($ID, $options);
           // @myplugin est un raccourci pour indiquer d'aller chercher
           // dans le dossier **templates** de votre propre plugin
           TemplateRenderer::getInstance()->display('@myplugin/superasset.form.html.twig', [
               'item'   => $this,
               'params' => $options,
           ]);

           return true;
       }
   }

**🗋 templates/superasset.form.html.twig**

.. code-block:: twig
   :linenos:

   {% extends "generic_show_form.html.twig" %}
   {% import "components/form/fields_macros.html.twig" as fields %}

   {% block more_fields %}
       blabla
   {% endblock %}

Suite à cela, un appel dans notre navigateur à notre page http://glpi/plugins/myplugin/front/superasset.form.php devrait afficher le formulaire de création.

.. warning::

    ℹ️  le fichier ``🗋 components/form/fields_macros.html.twig`` (importé dans l'exemple) inclut des fonctions twig pouvant afficher des champs Html courants tel que:

    ``{{ fields.textField(name, value, label = '', options = {}) }}``
    :  retourne l'html d'un input de type ``text``.

    ``{{ fields.hiddenField(name, value, label = '', options = {}) }``
    :  retourne l'html d'un input de type ``hidden``.

    ``{{ dateField(name, value, label = '', options = {}) }``
    :  retourne l'html d'un sélecteur de date (via la libraire [flatpickr])

    ``{{ datetimeField(name, value, label = '', options = {}) }``
    :  retourne l'html d'un sélecteur de date et d'heure (via la libraire [flatpickr])

    Voir le code source du fhcier ``🗋 templates/components/form/fields_macros.html.twig`` pour plus de détails et de macros.


Insertion dans le menu et fil d’Ariane
--------------------------------------

Idéalement, nous souhaiterions accéder à nos nouvelles pages sans taper directement l'url dans notre navigateur.

Nous allons donc définir notre premier ``hook`` dans l'init de notre plugin.

Éditons le fichier ``setup.php`` et la fonction ``plugin_init_myplugin`` :

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;

   function plugin_init_myplugin()
   {
       ...

       // add menu hook
       $PLUGIN_HOOKS['menu_toadd']['myplugin'] = [
           // insert into 'plugin menu'
           'plugins' => Superasset::class
       ];
   }

Ce ``hook`` indique que notre itemtype ``Superasset`` définit une fonction d'affichage du menu.
Editons notre classe et ajoutons les méthodes adaptées:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;

   class Superasset extends CommonDBTM
   {
       ...

       /**
        * Define menu name
        */
       static function getMenuName($nb = 0)
       {
           // call class label
           return self::getTypeName($nb);
       }

       /**
        * Define additionnal links used in breacrumbs and sub-menu
        *
        * A default implementation is provided by CommonDBTM
        */
       static function getMenuContent()
       {
           $title  = self::getMenuName(2);
           $search = self::getSearchURL(false);
           $form   = self::getFormURL(false);

           // define base menu
           $menu = [
               'title' => __("My plugin", 'myplugin'),
               'page'  => $search,

               // define sub-options
               // we may have multiple pages under the "Plugin > My type" menu
               'options' => [
                   'superasset' => [
                       'title' => $title,
                       'page'  => $search,

                       //define standard icons in sub-menu
                       'links' => [
                           'search' => $search,
                           'add'    => $form
                       ]
                   ]
               ]
           ];

           return $menu;
       }
   }

La fonction ``getMenuContent`` peut paraître redondante au premier abord mais chacune des entrées codées adresse des parties de l'affichage différentes.
La partie ``options`` sert notamment à avoir un 4ème niveau de fil d'Ariane et ainsi avoir un sous menu cliquable dans votre page d'entrée.

.. image:: /_static/images/breadcrumbs.png
   :alt: Fil d’Ariane


Chaque clef ``page`` sert à indiquer sur quelle url s'applique la partie en cours.

.. note::

    ℹ️ Le menu de GLPI est chargé dans ``$_SESSION['glpimenu']`` à la connexion.
    Pour visualiser vos changements, si vous n'êtes pas en mode ``DEBUG``,  vous devrez vous déconnecter et reconnecter.

.. note::

    ℹ️ Notez qu'il est tout à fait possible d'avoir un seul niveau de menu pour le plugin (3 niveaux au global), il suffit de déplacer la partie ``links`` au premier niveau du tableau ``$menu``

.. note::

    ℹ️ Il est aussi possible de définir des ``links`` personnalisés.
    Il suffit pour cela de remplacer la clef (par exemple, add ou search) par un html contenant une balise image

    .. code-block:: php

        'links' = [
            '<img src="path/to/my.png" title="my custom link">' => $url
        ]

Définir des onglets
-------------------

GLPI fournit 3 méthodes standards pour la définition des onglets:

`defineTabs(array $options = []) <https://forge.glpi-project.org/apidoc/class-CommonGLPI.html#_defineTabs>`_
:  Déclaration des classes fournissant des onglets à la classe courante.

`getTabNameForItem(CommonGLPI $item, boolean $withtemplate = 0) <https://forge.glpi-project.org/apidoc/class-CommonGLPI.html#_getTabNameForItem>`_
:  Déclare les titres affichés pour les onglets.

`displayTabContentForItem(CommonGLPI $item, integer $tabnum = 1, boolean $withtemplate = 0) <https://forge.glpi-project.org/apidoc/class-CommonGLPI.html#_displayTabContentForItem>`_
:  Permet l'affichage du contenu des onglets.

Onglets standards
^^^^^^^^^^^^^^^^^

De base certaines classes de l'api interne vous permettent d'ajouter un comportement avec un code minimal

C'est le cas pour les notes (`Notepad`_) et l'historique (`Log`_).

Voici un exemple pour ces deux systèmes:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Notepad;
   use Log;

   class Superasset extends CommonDBTM
   {
       // permits to automaticaly store logs for this itemtype
       // in glpi_logs table
       public $dohistory = true;

       ...

       function defineTabs($options = [])
       {
           $tabs = [];
           $this->addDefaultFormTab($tabs)
               ->addStandardTab(Notepad::class, $tabs, $options)
               ->addStandardTab(Log::class, $tabs, $options);

           return $tabs;
       }
   }

L'affichage d'une instance de votre itemtype depuis la page ``front/superasset.php?id=1`` doit maintenant comporter 3 onglets:

* l'onglet principal du nom de votre itemtype
* l'onglet Notes
* l'onglet Historique


Onglets personnalisés
^^^^^^^^^^^^^^^^^^^^^

De façon similaire, nous pouvons cibler une autre classe de notre plugin:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Notepad;
   use Log;

   class Superasset extends CommonDBTM
   {
       // permits to automaticaly store logs for this itemtype
       // in glpi_logs table
       public $dohistory = true;

       ...

       function defineTabs($options = [])
       {
           $tabs = [];
           $this->addDefaultFormTab($tabs)
               ->addStandardTab(Superasset_Item::class, $tabs, $options);
               ->addStandardTab(Notepad::class, $tabs, $options)
               ->addStandardTab(Log::class, $tabs, $options);

           return $tabs;
       }

Dans cette nouvelle classe nous devrons définir les deux autres méthodes pour contrôler le titre et le contenu de l'onglet:

**🗋 src/Superasset_Item.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Glpi\Application\View\TemplateRenderer;

   class Superasset_Item extends CommonDBTM
   {
       /**
        * Tabs title
        */
       function getTabNameForItem(CommonGLPI $item, $withtemplate = 0)
       {
           switch ($item->getType()) {
               case Superasset::class:
                   $nb = countElementsInTable(self::getTable(),
                       [
                           'plugin_myplugin_superassets_id' => $item->getID()
                       ]
                   );
                   return self::createTabEntry(self::getTypeName($nb), $nb);
           }
           return '';
       }

       /**
        * Display tabs content
        */
       static function displayTabContentForItem(CommonGLPI $item, $tabnum = 1, $withtemplate = 0)
       {
           switch ($item->getType()) {
               case Superasset::class:
                   return self::showForSuperasset($item, $withtemplate);
           }

           return true;
       }

       /**
        * Specific function for display only items of Superasset
        */
       static function showForSuperasset(Superasset $superasset, $withtemplate = 0)
       {
           TemplateRenderer::getInstance()->display('@myplugin/superasset_item_.html.twig', [
               'superasset' => $superasset,
           ]);
       }
   }

Comme précédemment, nous utilisons un template pour gérer notre affichage.

**🗋 templates/superasset_item.html.twig**

.. code-block:: twig
   :linenos:

   {% import "components/form/fields_macros.html.twig" as fields %}

   example content

.. note::

    📝 **Exercice** :
    Pour la suite de cette partie, vous devrez compléter notre plugin pour permettre l'installation / désinstallation des données de cette nouvelle classe ``Superasset_Item``.

    Sa table devrait inclure les champs suivants:


    * un identifiant (id)
    * une clef étrangère vers la table ``plugin_myplugin_superassets``
    * deux champs pour faire la liaison avec un itemtype:

    * ``itemtype``, le nom de la classe à associer (ex: `Computer`_)
    * ``items_id``, une clef étrangère vers l'id de l'item

    Note, votre plugin doit être ré-installé ou mis à jour pour que la création de la table soit effectuée.
    Vous pouvez forcer le changement de status de votre plugin pour "A mettre à jour" en modifiant le numéro de version dans le fichier ``setup.php``.


    Pour l'exercice, nous nous limiterons à associer des ordinateurs (`Computer`_) que nous pourrons afficher avec la fonction suivante:

    .. code-block:: twig

        {{ fields.dropdownField(
            'Computer',
            'items_id',
            '',
            __('Add a computer')
        ) }}

    Nous inclurons dans notre onglet un **"mini" formulaire** pour insérer les items_id des ordinateurs à notre table. Les actions du formulaire pouvant être traitées par le fichier ``myplugin/front/supperasset.form.php``

    Note, les formulaires de GLPI envoyés en POST sont protégés par un jeton ([CSRF]).
    vous pouvez inclure un champs caché pour valider le formulaire:

    .. code-block:: twig

        <input type="hidden" name="_glpi_csrf_token" value="{{ csrf_token() }}">

    Nous ajouterons aussi en dessous du formulaire une liste des ordinateurs déjà associés.


Cibler des objets du cœur
^^^^^^^^^^^^^^^^^^^^^^^^^

Nous pouvons aussi permettre à notre classe d'ajouter des onglets sur les objets natifs du cœur.
Nous déclarons cet ajout via une nouvelle ligne dans notre fonction d'init:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   function plugin_init_myplugin()
   {
      ...

       Plugin::registerClass(GlpiPlugin\Myplugin\Superasset_Item::class, [
           'addtabon' => 'Computer'
       ]);
   }

Le titre et le contenu de cet onglet se font comme précédemment avec les méthodes:


* ``CommonDBTM::getTabNameForItem()``
* ``CommonDBTM::displayTabContentForItem()``

.. note::

    📝 **Exercice** :
    Complétez les méthodes précédentes pour afficher dans les ordinateurs un nouvel onglet listant les ``SuperAsset`` qui lui sont associés.


Définir des Searchoptions
-------------------------

les `Searchoptions`_ sont des registres de colonnes pour le moteur de recherche de GLPI. Elles permettent de déclarer comment doivent s'afficher ou être interrogées les données d'un itemtype.

Dans notre classe, il faut déclarer une fonction ``rawSearchOptions``:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;

   class Superasset extends CommonDBTM
   {
       ...

       function rawSearchOptions()
       {
           $options = [];

           $options[] = [
               'id'   => 'common',
               'name' => __('Characteristics')
           ];

           $options[] = [
               'id'    => 1,
               'table' => self::getTable(),
               'field' => 'name',
               'name'  => __('Name'),
               'datatype' => 'itemlink'
           ];

           $options[] = [
               'id'    => 2,
               'table' => self::getTable(),
               'field' => 'id',
               'name'  => __('ID')
           ];

           $options[] = [
               'id'           => 3,
               'table'        => Superasset_Item::getTable(),
               'field'        => 'id',
               'name'         => __('Number of associated assets', 'myplugin'),
               'datatype'     => 'count',
               'forcegroupby' => true,
               'usehaving'    => true,
               'joinparams'   => [
                   'jointype' => 'child',
               ]
           ];

           return $options;
       }
   }

Suite à l'ajout de notre fonction, depuis la page de liste de notre itemtype, nous devrions pouvoir ajouter nos nouvelle colonnes depuis l’icône "clef à molette":


.. image:: /_static/images/search.png
   :alt: Search form


Ces options seront aussi présentes en critères de recherche dans le même formulaire.

Chaque ``option`` est identifiée par une clef ``id`` dans le tableau généré.
Cette clef est utilisée dans d'autres parties de glpi.
Elle doit être **absolument** unique.
Les index '1' et '2' sont "réservés" par convention au nom et à l'ID de l'objet.

La `documentation des searchoptions <http://glpi-developer-documentation.readthedocs.io/en/master/devapi/search.html#search-options>`_ décrit toutes les options possibles pour la définition du tableau à renvoyer.

Cibler d'autres objets
^^^^^^^^^^^^^^^^^^^^^^

Il est aussi possible d'enrichir les searchoptions d'un itemtype natif de GLPI. Par exemple, nous pourrions vouloir afficher dans la liste des ordinateurs les "Superasset" associés:

**🗋 hook.php**

.. code-block:: php
   :lineno-start: 50

   <?php

   use GlpiPlugin\Myplugin\Superasset;
   use GlpiPlugin\Myplugin\Superasset_Item;

   ...

   function plugin_myplugin_getAddSearchOptionsNew($itemtype)
   {
       $sopt = [];

       if ($itemtype == 'Computer') {
           $sopt[] = [
               'id'           => 12345,
               'table'        => Superasset::getTable(),
               'field'        => 'name',
               'name'         => __('Associated Superassets', 'myplugin'),
               'datatype'     => 'itemlink',
               'forcegroupby' => true,
               'usehaving'    => true,
               'joinparams'   => [
                   'beforejoin' => [
                       'table'      => Superasset_Item::getTable(),
                       'joinparams' => [
                           'jointype' => 'itemtype_item',
                       ]
                   ]
               ]
           ];
       }

       return $sopt;
   }

Comme précédemment, vous devez fournir un id pour vos nouvelles searchoptions qui n'écrase pas les existantes de ``Computer``.

Vous pouvez utiliser un outil présent dans le dossier ``tools`` du dépôt git de GLPI (non présent dans les archives de "release") pour vous aider à lister les **id** déjà déclarés (par le cœur et les plugins présents sur votre ordinateur) pour un itemtype particulier.

.. code-block:: shell

   /usr/bin/php /path/to/glpi/tools/getsearchoptions.php --type=Computer


Préférences d'affichage du moteur de recherche
----------------------------------------------

Comme vu dans le `paragraphe précédent <#définir-des-searchoptions>`_, nous avons avons manuellement ajouté (par l'icône "clef à molette") des colonnes à la liste de notre itemtype.
Ces colonnes sont enregistrées par l'objet DisplayPreference (table ``glpi_displaypreferences``).
Ces préférences peuvent être globales (champ ``users_id = 0``) ou personnelles (champ ``users_id != 0``), sont ordonnées (champ ``rank``) et cible un itemtype plus une ``searchoption`` (champ ``num``).

.. warning::

    **⚠️ Attention**
    Les préférences globales s'appliquent à tous les utilisateurs et ne peuvent pas être réinitialisées de façon rapide. Il faut apporter un soin particulier à vérifier qu'ajouter des colonnes par défaut à tous les utilisateurs ne provoquera pas de blocage de l'interface voir de GLPI.


.. note::

    📝 **Exercice**:
    Vous ajouterez aux fonctions d'installation et de désinstallation du plugin l'ajout et la suppression des préférences globales pour que l'affichage par défaut de notre objet comporte quelques colonnes.


Hooks d’évènements standards
----------------------------

Dans le cycle de vie d'un objet de GLPI, nous pouvons intervenir via notre plugin avant et après chaque événement (ajout, modification, suppression).

Pour nos propres objets, les méthodes suivantes peuvent être implémentées:

* `prepareInputForAdd <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1536-L1543>`_
* `post_addItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1549-L1554>`_
* `prepareInputForUpdate <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1977-L1984>`_
* `post_updateItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L1990-L1997>`_
* `pre_deleteItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2248-L2254>`_
* `post_deleteItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2148-L2153>`_
* `post_purgeItem <https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php#L2158-L2163>`_

Pour chacun des évènements effectivement appliqués sur la base de données, nous avons une méthode qui est exécutée avant et une autre après.

.. note::

    📝 **Exercice**:
    Ajoutez les méthodes nécessaires à la classe ``PluginMypluginSuperasset`` pour vérifier que le champ ``name`` soit correctement rempli lors de l'ajout et de la mise à jour.

    Dans le cas de la suppression (complète), nous nous assurerons de purger les données associées dans l'autre classe/table.

Les plugins peuvent aussi intercepter les évènements standards des objets du cœur afin d'y appliquer des changements (ou même refuser l’évènement). Voici le nom des ``hooks``:

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Plugin\Hooks;

   ...

   Hooks::PRE_ITEM_ADD;
   Hooks::ITEM_ADD;
   Hooks::PRE_ITEM_DELETE;
   Hooks::ITEM_DELETE;
   Hooks::PRE_ITEM_PURGE;
   Hooks::ITEM_PURGE;
   Hooks::PRE_ITEM_RESTORE;
   Hooks::ITEM_RESTORE;
   Hooks::PRE_ITEM_UPDATE;
   Hooks::ITEM_UPDATE;

Plus d'informations sont disponibles dans la `documentation des ``hooks`` <http://glpi-developer-documentation.readthedocs.io/en/master/plugins/hooks.html#standards-hooks>`_ et notamment sur la partie des `évènements standards. <http://glpi-developer-documentation.readthedocs.io/en/master/plugins/hooks.html#items-business-related>`_

Pour tous ces appels, nous obtiendrons une instance de l'objet courant en paramètre de notre fonction de "callback". Nous pourrons donc accéder à ses champs courants (``$item->fields``) ou ceux envoyés par le formulaire (``$item->input``).
Cette instance sera passée par référence (comme tous les objets php).

Nous déclarons l'usage de l'un de ces ``hooks`` dans la fonction d'init du plugin et ajouterons une fonction de ``callback``:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Superasset;

   ...

   function plugin_init_myplugin()
   {
      ...

       // callback a function (declared in hook.php)
       $PLUGIN_HOOKS['item_update']['myplugin'] = [
           'Computer' => 'myplugin_computer_updated'
       ];

       // callback a class method
       $PLUGIN_HOOKS['item_add']['myplugin'] = [
            'Computer' => [
                 Superasset::class, 'computerUpdated'
            ]
       ];
   }

dans les deux cas (fonction de ``hook.php`` ou méthode de classe), le prototype des fonctions sera fait sur ce modèle:

.. code-block:: php
   :linenos:

   <?php

   use CommonDBTM;
   use Session;

   function hookCallback(CommonDBTM $item)
   {
       ...

       // if we need to stop the process (valid for pre* hooks)
       if ($mycondition) {
           // clean input
           $item->input = [];

           // store a message in session for warn user
           Session::addMessageAfterRedirect('Action forbidden because...');

           return;
      }
   }

.. note::

    📝 **Exercice**:
    Utilisez un ``hook`` interceptant la suppression définitive (purge) d'un ordinateur pour vérifier que des lignes de nos objets y sont associées et les supprimer également dans ce cas.


Importer des librairies (Javascript / CSS)
------------------------------------------

Les plugins peuvent déclarer l'import de librairies supplémentaires depuis leur fonction init.

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Plugin\Hooks;

   function plugin_init_myplugin()
   {
       ...

       // css & js
       $PLUGIN_HOOKS[Hooks::ADD_CSS]['myplugin'] = 'myplugin.css';
       $PLUGIN_HOOKS[Hooks::ADD_JAVASCRIPT]['myplugin'] = [
           'js/common.js',
       ];

       // on ticket page (in edition)
       if (strpos($_SERVER['REQUEST_URI'], "ticket.form.php") !== false
           && isset($_GET['id'])) {
           $PLUGIN_HOOKS['add_javascript']['myplugin'][] = 'js/ticket.js.php';
       }

       ...
   }

Plusieurs choses à noter:

* Les chemins de chargement sont **relatifs** au répertoire du plugin.
* Les scripts ainsi déclarés seront par défaut chargés sur **toutes** les pages des glpi. Il convient de vérifier la page courante dans cette fonction init.
* L'extension du script n'est **pas** vérifiée par GLPI, vous pouvez tout à fait charger un fichier php en script js. Vous devrez forcer le mimetype ensuite dans le fichier chargé (ex: ``header("Content-type: application/javascript");``).
* Vous pouvez utilisez la libraire ``requirejs`` pour charger des ressources externes à glpi ou à votre plugin. Les chemins des scripts étant forcement absolus, l'url racine de GLPI sera forcement ajoutée en préfixe lors du chargement. Le `plugin XIVO <https://github.com/pluginsGLPI/xivo>`_ pour GLPI utilise cette méthode de chargement.
* Si vous souhaitez modifier le dom de glpi et notamment ce qui est affiché en formulaire principal, je vous conseille d'appeler votre code 2 fois (au chargement de la page et à celui de l'onglet en cours) et pensez à ajouter une classe permettant de vérifier l'application effective de votre code :

.. code-block:: javascript
   :linenos:

   $(function() {
       doStuff();
       $(".glpi_tabs").on("tabsload", function(event, ui) {
           doStuff();
       });
   });

   var doStuff = function()
   {
       if (! $("html").hasClass("stuff-added")) {
           $("html").addClass("stuff-added");

           // do stuff you need
           ...

       }
   };

.. note::

    📝 **Exercices**:

    #. Ajouter une icône supplémentaire dans le menu préférences (en haut à droite à coté du 'login' utilisateur), permettant d'afficher sur un clic la configuration générale de GLPI. Pour afficher votre icône, vous pouvez utiliser :

      * `tabler-icons <https://tabler-icons.io/>`_ (préféré), ex: ``<a href='...' class='ti ti-mood-smile'></a>``).
      * `font-awesome v6 <https://fontawesome.com>`_, ex: ``<a href='...' class='fas fa-face-smile'></a>``).

    #. Dans la page d'edition d'un ticket, ajouter une icône pour s'auto-associer en tant que demandeur sur le modèle de celle présente pour la partie "attribué à".

Hooks d'affichage
-----------------

Depuis la version 9.1.2 de GLPI, il est maintenant possible d'afficher des données dans les formulaires des objets natifs via de nouveaux hooks.
Voir `Items display related <http://glpi-developer-documentation.readthedocs.io/en/master/plugins/hooks.html#items-display-related>`_ dans la documentation des plugins.

Nous les déclarons comme les ``hooks`` précédents:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Plugin\Hooks;
   use GlpiPlugin\Myplugin\Superasset;

   function plugin_init_myplugin()
   {
      ...

       $PLUGIN_HOOKS[Hooks::PRE_ITEM_FORM]['myplugin'] = [
           Superasset::class, 'preItemFormComputer'
       ];
   }

.. warning::

    ℹ️ **Important**
    Ces fonctions d'affichage diffèrent un peu des autres ``hooks`` au niveau des paramètres passés à la fonction de callback.
    Nous aurons un ``array`` contenant les clefs suivantes:


    * **'item'** avec l'objet CommonDBTM courant
    * **'options'**, ``array`` passée depuis la fonction showForm de l'objet courant

    exemple d'un appel par le coeur :

    .. code-block:: php

        <?php

        Plugin::doHook("pre_item_form", ['item' => $this, 'options' => &$options]);

.. note::

    📝 **Exercice**:
    Ajouter en entête du formulaire d'édition des ordinateurs indiquant le nombre de ``Super asset`` associés.
    Ce nombre devrait être un lien vers `l'onglet ajouté précédemment <#cibler-des-objets-du-cœur>`_ aux objets ordinateurs.
    Le lien pointera vers la même page mais avec un paramètre `forcetab=PluginMypluginSuperasset$1`.


Ajouter une page de configuration
---------------------------------

Afin de rendre optionnelles certaines parties de notre plugin, nous allons proposer un onglet dans la configuration générale de GLPI.

Précédemment, nous avons ajouté, via des hooks dans le fichier setup.php, un onglet aux ordinateurs ainsi qu'au début de leurs formulaires. Nous allons donc définir deux options de configuration afin d'activer / désactiver ces affichages à loisir.

GLPI fournit une table ``glpi_configs``, stockant la configuration du logiciel, qui permet aux plugins, via un système de contexte, de sauvegarder leurs propres données sans définir de table supplémentaire.

Tout d’abord, créons une nouvelle classe dans le dossier ``src/`` nommée Config.php dont voici le squelette:

**🗋 src/Config.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use Config;
   use CommonGLPI;
   use Dropdown;
   use Html;
   use Session;
   use Glpi\Application\View\TemplateRenderer;
   use Toolbox;

   class Config extends \Config
   {

       static function getTypeName($nb = 0)
       {
           return __('My plugin', 'myplugin');
       }

       static function getConfig()
       {
           return Config::getConfigurationValues('plugin:myplugin');
       }

       function getTabNameForItem(CommonGLPI $item, $withtemplate = 0)
       {
           switch ($item->getType()) {
               case Config::class:
                   return self::createTabEntry(self::getTypeName());
           }
           return '';
       }

       static function displayTabContentForItem(
           CommonGLPI $item,
           $tabnum = 1,
           $withtemplate = 0
       ) {
           switch ($item->getType()) {
               case Config::class:
                   return self::showForConfig($item, $withtemplate);
           }

           return true;
       }

       static function showForConfig(
           Config $config,
           $withtemplate = 0
       ) {
           global $CFG_GLPI;

           if (!self::canView()) {
               return false;
           }

           $current_config = self::getConfig();
           $canedit        = Session::haveRight(self::$rightname, UPDATE);

           TemplateRenderer::getInstance()->display('@myplugin/config.html.twig', [
               'current_config' => $current_config,
               'can_edit'       => $canedit
           ]);
       }
   }

De nouveau, nous gérons l'affichage dans un gabarit dédié:

**🗋 templates/config.html.twig**

.. code-block:: twig
   :linenos:

   {% import "components/form/fields_macros.html.twig" as fields %}

   {% if can_edit %}
       <form name="form" action="{{ "Config"|itemtype_form_path }}" method="POST">
           <input type="hidden" name="config_class" value="GlpiPlugin\\Myplugin\\Config">
           <input type="hidden" name="config_context" value="plugin:myplugin">
           <input type="hidden" name="_glpi_csrf_token" value="{{ csrf_token() }}">

           {{ fields.dropdownYesNo(
               'myplugin_computer_tab',
               current_config['myplugin_computer_tab'],
               __("Display tab in computer", 'myplugin')
           ) }}

           {{ fields.dropdownYesNo(
               'myplugin_computer_form',
               current_config['myplugin_computer_form'],
               __("Display information in computer form", 'myplugin')
           ) }}

           <button type="submit" class="btn btn-primary mx-1" name="update" value="1">
               <i class="ti ti-device-floppy"></i>
               <span>{{ _x('button', 'Save') }}</span>
           </button>
       </form>
   {% endif %}

Ce squelette récupéra les appels à un onglet dans le menu ``Configuration > Générale`` pour afficher le formulaire dédié à notre plugin.
Il n'est pas utile d'ajouter de fichier dans le dossier ``front``, notre formulaire renvoie vers la page ``front/config.form`` du cœur et sauvegardera les données sans plus de travaux.

Vous pouvez constater que nous affichons, via la fonction ``myplugin_computer_form`` deux champs Oui/Non nommés 'myplugin_computer_tab' et 'myplugin_computer_form'.

.. note::

    ✍️ Complétez le fichier ``setup.php`` en définissant l'ajout de l'onglet à la classe Config.

    Par ailleurs, vous devrez ajouter aux fonctions d'installation et de désinstallation l'ajout et la suppression des lignes de la table glpi_configs.
    Vous pourrez utiliser les fonctions suivantes :

    .. code-block:: php

        <?php

        use Config;

        Config::setConfigurationValues('##context##', [
            '##config_name##' => '##config_default_value##'
        ]);

    .. code-block:: php

        <?php

        use Config;

        $config = new Config();
        $config->deleteByCriteria(['context' => '##context##']);

    *Pensez à remplacer les noms entourés par '##' par vos propre valeurs*


Gérer les droits
----------------

Afin de limiter l’accès aux fonctionnalités de notre plugin à certains de nos utilisateurs, nous pouvons utiliser le système de la classe `Profile`_ de GLPI.

Celle-ci vérifie de base la propriété ``$rightname`` des classes héritant de `CommonDBTM`_ pour tous les évènements standard.
Ces vérifications sont effectuées par les fonctions ``static`` can*:


* `canCreate <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canCreate>`_ pour la méthode `add <(https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_add>`_)
* `canUpdate <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canUpdate>`_ pour la méthode `update <(https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_update>`_)
* `canDelete <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canDelete>`_ pour la méthode `delete <(https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_delete>`_)
* `canPurge <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_canPurge>`_ pour la méthode `delete <(https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_delete>`_) aussi mais dans le cas ou le paramètre ``$force = true``

Afin de spécialiser la vérification de nos droits, nous pouvons re-définir ces fonctions statiques dans nos classes.

Si nous avons besoin de vérifier un droit manuellement dans notre code métier, la classe `Session`_ nous fourni quelques méthodes:

.. code-block:: php
   :linenos:

   <?php

   use Session;

   if (Session::haveRight(self::$rightname, CREATE)) {
      // OK
   }

   // we can also test a set multiple rights with AND operator
   if (Session::haveRightsAnd(self::$rightname, [CREATE, READ])) {
      // OK
   }

   // also with OR operator
   if (Session::haveRightsOr(self::$rightname, [CREATE, READ])) {
      // OK
   }

   // check a specific right (not your class one)
   if (Session::haveRight('ticket', CREATE)) {
      // OK
   }

Les méthodes ci dessus retournent toutes un booléen. Si nous voulons un arrêt de la page avec un message à destination de l'utilisateur, il existe des méthodes équivalente avec le préfixe ``check`` à la place de ``have``:


* `checkRight <https://github.com/glpi-project/glpi/blob/10.0.15/src/Session.php#L1109-L1117>`_
* `checkRightsOr <https://github.com/glpi-project/glpi/blob/10.0.15/src/Session.php#L1128-L1136>`_

.. warning::

    ℹ️ Si vous avez besoin de vérifier un droit directement dans une requête SQL, utilisez les opérateurs sur les bits ``&`` et ``|``:

    .. code-block:: php

        <?php

        $query = "SELECT `glpi_profiles_users`.`users_id`
            FROM `glpi_profiles_users`
            INNER JOIN `glpi_profiles`
                ON (`glpi_profiles_users`.`profiles_id` = `glpi_profiles`.`id`)
            INNER JOIN `glpi_profilerights`
                ON (`glpi_profilerights`.`profiles_id` = `glpi_profiles`.`id`)
            WHERE `glpi_profilerights`.`name` = 'ticket'
                AND `glpi_profilerights`.`rights` & ". (READ | CREATE);
        $result = $DB->query($query);

    Dans cet extrait de code, la partie ``READ | CREATE`` effectue une somme au niveau binaire et la partie ``&`` compare au niveau logique la valeur avec celle de la table.

Les valeurs possibles des droits standards peuvent être trouvés dans le fichier ``inc/define.php`` de GLPI:

.. code-block:: php
   :linenos:

   <?php

   ...

   define("READ", 1);
   define("UPDATE", 2);
   define("CREATE", 4);
   define("DELETE", 8);
   define("PURGE", 16);
   define("ALLSTANDARDRIGHT", 31);
   define("READNOTE", 32);
   define("UPDATENOTE", 64);
   define("UNLOCK", 128);

Ajouter un nouveau droit
^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

    ✍️ `Précédemment <#utilisation-de-commondbtm-et-création-de-classes-métier>`_, nous avons défini la propriété ``$rightname = 'computer'`` sur laquelle nous avons automatiquement les droits en tant que ``super-admin``.
    Nous allons maintenant créer un droit spécifique au plugin.

Tout d’abord, nous allons créer une nouvelle classe dédiée à la gestion des profils:

**🗋 src/Profile.php**

.. code-block:: php
   :linenos:

   <?php
   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use CommonGLPI;
   use Html;
   use Profile as Glpi_Profile;

   class Profile extends CommonDBTM
   {
       public static $rightname = 'profile';

       static function getTypeName($nb = 0)
       {
           return __("My plugin", 'myplugin');
       }

       public function getTabNameForItem(CommonGLPI $item, $withtemplate = 0)
       {
           if (
               $item instanceof Glpi_Profile
               && $item->getField('id')
           ) {
               return self::createTabEntry(self::getTypeName());
           }
           return '';
       }

       static function displayTabContentForItem(
           CommonGLPI $item,
           $tabnum = 1,
           $withtemplate = 0
       ) {
           if (
               $item instanceof Glpi_Profile
               && $item->getField('id')
           ) {
               return self::showForProfile($item->getID());
           }

           return true;
       }

       static function getAllRights($all = false)
       {
           $rights = [
               [
                   'itemtype' => Superasset::class,
                   'label'    => Superasset::getTypeName(),
                   'field'    => 'myplugin::superasset'
               ]
           ];

           return $rights;
       }


       static function showForProfile($profiles_id = 0)
       {
           $profile = new Glpi_Profile();
           $profile->getFromDB($profiles_id);

           TemplateRenderer::getInstance()->display('@myplugin/profile.html.twig', [
               'can_edit' => self::canUpdate(),
               'profile'  => $profile
               'rights'   => self::getAllRights()
           ]);
       }
   }

De nouveau, nous afficheons le formulaire dans un gabarit Twig :

**🗋 templates/profile.html.twig**

.. code-block:: twig
   :linenos:

   {% import "components/form/fields_macros.html.twig" as fields %}
   <div class='firstbloc'>
       <form name="form" action="{{ "Profile"|itemtype_form_path }}" method="POST">
           <input type="hidden" name="id" value="{{ profile.fields['id'] }}">
           <input type="hidden" name="_glpi_csrf_token" value="{{ csrf_token() }}">

           {% set  rnd = profile.displayRightsChoiceMatrix(rights, {
               'canedit': can_edit,
               'title': __("My plugin", 'myplugin'),
           }) %}

           {% if can_edit %}
               <button type="submit" class="btn btn-primary mx-1" name="update" value="1">
                   <i class="ti ti-device-floppy"></i>
                   <span>{{ _x('button', 'Save') }}</span>
               </button>
           {% endif %}
       </form>
   </div>

Enfin dans notre fonction d'init, nous déclarons un nouvel onglet sur l'objet ``Profile``:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Plugin;
   use Profile;
   use GlpiPlugin\Myplugin\Profile as MyPlugin_Profile;

   function plugin_init_myplugin()
   {
      ...

       Plugin::registerClass(MyPlugin_Profile::class, [
           'addtabon' => Profile::class
       ]);
   }

Finalement, nous indiquons à l'installation d'enregistrer le droit et un accès minimal (pour le profil courant ``super-admin``):

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use GlpiPlugin\Myplugin\Profile as MyPlugin_Profile;
   use ProfileRight;

   function plugin_myplugin_install() {
      ...

      // add rights to current profile
      foreach (MyPlugin_Profile::getAllRights() as $right) {
         ProfileRight::addProfileRights([$right['field']]);
      }

      return true;
   }

   function plugin_myplugin_uninstall() {
      ...

      // delete rights for current profile
      foreach (MyPlugin_Profile::getAllRights() as $right) {
         ProfileRight::deleteProfileRights([$right['field']]);
      }

   }

A partir de ce moment, nous pouvons définir nos droits depuis le menu ``Administration > Profils`` et nous pouvons changer la propriété ``$righname`` de notre classe pour ``myplugin::superasset``.

Etendre les droits standards.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Si nous avons besoin de droits spécifiques pour notre plugin, par exemple le droit d'effectuer les associations, il faut surcharger la fonction ``getRights`` dans la classe définissant les droits.

Dans l'exemple de classe ``PluginMypluginProfile`` définit plus haut, nous avons ajouté une méthode getAllRights qui indique que le droit ``myplugin::superasset`` est défini dans la classe ``PluginMypluginSuperasset``.
Celle-ci héritant de CommonDBTM, elle possède une méthode `getRights <https://forge.glpi-project.org/apidoc/class-CommonDBTM.html#_getRights>`_ que nous pouvons surcharger:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   ...

   class Superasset extends CommonDBTM
   {
       const RIGHT_ONE = 128;

       ...

       function getRights($interface = 'central')
       {
           // if we need to keep standard rights
           $rights = parent::getRights();

           // define an additional right
           $rights[self::RIGHT_ONE] = __("My specific rights", "myplugin");

           return $rights;
       }
   }


Actions massives
----------------

Les actions massives de GLPI, mises à disposition des utilisateurs, permettent d'appliquer des modifications à l'ensemble d'une liste ou d'une sélection.


.. image:: http://glpi-developer-documentation.readthedocs.io/en/master/_images/massiveactions.png
   :target: http://glpi-developer-documentation.readthedocs.io/en/master/_images/massiveactions.png
   :alt: contrôles des actions massives


Par défaut, GLPI met à disposition les actions suivantes:


* "Modifier": pour éditer les champs définis dans les searchoptions (exceptées celles qui indique ``'massiveaction' = false``)
* "Mettre à la corbeille" / "Supprimer définitivement"

Il est possible de déclarer des `actions massives supplémentaires <http://glpi-developer-documentation.readthedocs.io/en/master/devapi/massiveactions.html#specific-massive-actions>`_.

Afin d'activer cette fonctionnalité dans votre plugin, il faut déclarer dans l'init le ``hook`` dédié:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   function plugin_init_myplugin()
   {
       ...

       $PLUGIN_HOOKS['use_massive_action']['myplugin'] = true;
   }

Ensuite dans la classe ``Superasset``, il faudra ajouter 3 méthodes:


* ``getSpecificMassiveActions``: déclaration des définitions des actions massives.
* ``showMassiveActionsSubForm``: affichage du sous-formulaire.
* ``processMassiveActionsForOneItemtype``: traitement de l'envoi du formulaire.

Ci dessous, un exemple d'implémentation minimal:

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;
   use Html;
   use MassiveAction;

   class Superasset extends CommonDBTM
   {
       ...

       function getSpecificMassiveActions($checkitem = NULL)
       {
           $actions = parent::getSpecificMassiveActions($checkitem);

           // add a single massive action
           $class        = __CLASS__;
           $action_key   = "myaction_key";
           $action_label = "My new massive action";
           $actions[$class . MassiveAction::CLASS_ACTION_SEPARATOR . $action_key] = $action_label;

           return $actions;
       }

       static function showMassiveActionsSubForm(MassiveAction $ma)
       {
           switch ($ma->getAction()) {
               case 'myaction_key':
                   echo __("fill the input");
                   echo Html::input('myinput');
                   echo Html::submit(__('Do it'), ['name' => 'massiveaction']) . "</span>";

                   break;
           }

           return parent::showMassiveActionsSubForm($ma);
       }

       static function processMassiveActionsForOneItemtype(
           MassiveAction $ma,
           CommonDBTM $item,
           array $ids
       ) {
           switch ($ma->getAction()) {
               case 'myaction_key':
                   $input = $ma->getInput();

                   foreach ($ids as $id) {

                       if (
                           $item->getFromDB($id)
                           && $item->doIt($input)
                       ) {
                           $ma->itemDone($item->getType(), $id, MassiveAction::ACTION_OK);
                       } else {
                           $ma->itemDone($item->getType(), $id, MassiveAction::ACTION_KO);
                           $ma->addMessage(__("Something went wrong"));
                       }
                   }
                   return;
           }

           parent::processMassiveActionsForOneItemtype($ma, $item, $ids);
       }
   }

.. note::

    📝 **Exercice**:
    En vous aidant de la documentation officielle sur les `actions massives <http://glpi-developer-documentation.readthedocs.io/en/master/devapi/massiveactions.html#specific-massive-actions>`_, complétez dans votre plugin, les méthodes présentées ci-dessus pour permettre l'ajout d'un ordinateur via les actions massives des "Super assets".

    Vous pourrez afficher une liste des ordinateurs via l'extrait de code suivant:

    .. code-block:: php

        Computer::dropdown();

Il est aussi possible d'ajouter des actions massives aux itemtype natifs de GLPI.
Pour cela, il faut déclarer une fonction ``_MassiveActions`` dans le fichier hook.php:

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use Computer;
   use MassiveAction;
   use GlpiPlugin\Myplugin\Superasset;

   ...

   function plugin_myplugin_MassiveActions($type)
   {
      $actions = [];
      switch ($type) {
         case Computer::class:
            $class = Superasset::class;
            $key   = 'DoIt';
            $label = __("plugin_example_DoIt", 'example');
            $actions[$class.MassiveAction::CLASS_ACTION_SEPARATOR.$key]
               = $label;

            break;
      }
      return $actions;
   }

L'affichage du sous-formulaire et le traitement de l'envoi se gère de la même façon que pour les massives actions des itemtypes de votre propre plugin.

.. note::

    📝 **Exercice**:
    De la même façon que dans l'exercice précédent, ajoutez la possibilité d'affecter des ordinateurs à une "Super asset".

    Pensez à définir des clefs et labels différents que ceux précédemment développés.

Notifications
-------------

.. warning::
    ⚠️ Il est préférable d'avoir un accés à un serveur smtp et d'avoir saisi la configuration de celui ci dans GLPI (menu ``Configuration > Notifications > Configuration des suivis par courriels``). Dans le cas d'un environnement de développement, vous pouvez installer  `mailhog <https://github.com/mailhog/MailHog>`_ ou `mailcatcher <https://mailcatcher.me/>`_ qui exposent un serveur smtp local et vous permettent de récupérer les mails envoyés par GLPI dans une interface graphique.


    Veuillez aussi noter que GLPI n'envoit pas directement les mails. Il passe par un système de file d'attente.
    Toute les notifications "en attente" sont visibles dans le menu ``Administration > File d'attente des courriels``.
    Vous pouvez envoyer effectivement les mails par ce menu ou en forçant l'action massive ``queuedmail``.

Le système de notifications de GLPI permet l'envoi d'alertes à destination des acteurs d'un événement enregistré.
Par défaut le mode d'envoi est le mail mais il possible d'imaginer d'autres canaux (un envoi vers la messagerie instantanée Telegram est `en cours de développement <https://github.com/pluginsGLPI/telegrambot>`_).

Le système se décompose en plusieurs classes distinctes:

Notification:  L'objet principal. Il reçoit les champs communs tel un nom, l'activation, le mode d'envoi, l’événement déclencheur, un contenu (``NotificationTemplate``), etc.

.. image:: /_static/images/Notification.png
   :alt: Formulaire de l'objet Notification


NotificationTarget: Cette classe définit les destinataires d'une notification.
    Il est possible de définir des acteurs provenant de l'objet qui cible la notification (l'auteur, l'attributaire) comme des acteurs directs (tous les utilisateurs d'un groupe précis).


.. image:: /_static/images/NotificationTarget.png
   :alt: Formulaire de choix des acteurs


NotificationTemplate: Les modèles de notification permettent de construire le mail envoyé réellement et peuvent être choisis dans le formulaire de l'objet Notification. Nous pouvons définir du css dans cet objet et il reçoit une ou plusieurs instances de ``NotificationTemplateTranslation``

.. image:: /_static/images/NotificationTemplate.png
   :alt: Formulaire de modèle de notification


NotificationTemplateTranslation: Cet objet reçoit le contenu traduit des modèles. Veuillez noter qu'en l'absence de langue définie, le contenu s'appliquera quelque soit la langue de l'utilisateur.
Le contenu est généré dynamiquement avec des tags fournis à l'utilisateur et complété par de l'HTML.

.. image:: /_static/images/NotificationTemplateTranslation.png
   :alt: Formulaire de traduction de modèle


Tous ces objets sont gérés nativement par le cœur de GLPI et ne nécessitent pas d'intervention de notre part en terme de développement.

Nous pouvons par contre déclencher l’exécution d'une notification via le code suivant:

.. code-block:: php

   <?php

   use NotificationEvent;

   NotificationEvent::raiseEvent($event, $item);

La clef 'event' correspond au nom de l'événement déclencheur défini dans l'objet ``Notification`` et la clef 'itemtype' l'objet auquel il se rapporte.
Ainsi, cette fonction ``raiseEvent`` cherchera dans la table ``glpi_notifications`` une ligne active avec ces 2 caractéristiques.

Pour utiliser ce déclencheur dans notre plugin, nous ajouterons une nouvelle classe ``PluginMypluginNotificationTargetSuperasset``.
Celle-ci "cible" notre itemtype ``Superasset``, c'est la façon standard de développer des notifications dans GLPI. Nous avons un itemtype ayant une vie propre et un objet de notification s'y rapportant.

**🗋 src/NotificationTargetSuperasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use NotificationTarget;

   class NotificationTargetSuperasset extends NotificationTarget
   {

       function getEvents()
       {
           return [
               'my_event_key' => __('My event label', 'myplugin')
           ];
       }

       function getDatasForTemplate($event, $options = [])
       {
           $this->datas['##myplugin.name##'] = __('Name');
       }
   }

Il faudra indiquer en plus dans notre fonction d'init que notre itemtype ``Superasset`` peux envoyer des notifications:

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Plugin;
   use GlpiPlugin\Myplugin\Superasset;

   function plugin_init_myplugin()
   {
      ...

       Plugin::registerClass(Superasset::class, [
           'notificationtemplates_types' => true
       ]);
   }

Avec ce code minimal, il est possible de créer manuellement, via l'interface de GLPI, une nouvelle notification ciblant notre itemtype ``Superasset`` et avec l’événement 'My event label' et d'utiliser la fonction raiseEvent avec ces paramètres.

.. note::

    📝 **Exercice** :
    Outre le test d'un envoi effectif, vous gérerez l'installation et la désinstallation automatique d'une notification et des objets associés (modèles, traductions).

    Vous pouvez prendre exemple sur la documentation (encore incomplète) sur les `notifications dans les plugins <http://glpi-developer-documentation.readthedocs.io/en/feature-notifications/plugins/notifications.html>`_


Actions automatiques
--------------------

Cette fonctionnalité de GLPI fournit un planificateur de tâches exécutées silencieusement par les clics de l'utilisateur (mode GLPI) ou par le serveur en ligne de commande (mode cli) via un appel du fichier ``front/cron.php`` de glpi.

.. image:: /_static/images/crontask.png
   :alt: image alt

Pour ajouter une ou plusieurs actions automatiques à notre classe, nous y ajoutons ces méthodes:

* ``cronInfo``: déclaration des actions possibles pour la classe ainsi que les libellés associés
* ``cron*Action*``: une fonction pour chaque action définie dans ``cronInfo``. Ces fonctions sont appelées pour lancer le traitement effectif de l'action.

**🗋 src/Superasset.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   use CommonDBTM;

   class Superasset extends CommonDBTM
   {
       ...

       static function cronInfo($name)
       {

           switch ($name) {
               case 'myaction':
                   return ['description' => __('action desc', 'myplugin')];
           }
           return [];
       }

       static function cronMyaction($task = NULL)
       {
           // do the action

           return true;
       }
   }

Pour indiquer l'existence de cette action automatique à GLPI, il suffit de l'installer:

**🗋 hook.php**

.. code-block:: php
   :linenos:

   <?php

   use CronTask;

   function plugin_myplugin_install()
   {

       ...

       CronTask::register(
           PluginMypluginSuperasset::class,
           'myaction',
           HOUR_TIMESTAMP,
           [
               'comment'   => '',
               'mode'      => \CronTask::MODE_EXTERNAL
           ]
       );
   }

Inutile de gérer la supression (unregister) de cette action, GLPI s'occupe de le faire automatiquement à la désinstallation du plugin.


Publier votre plugin
--------------------

Vous estimez votre plugin suffisamment mature et celui-ci couvre un besoin générique, vous pouvez le soumettre à la communauté.

Le `catalogue des plugins <http://plugins.glpi-project.org/>`_ permet aux utilisateurs de GLPI de découvrir, télécharger et suivre les plugins fournis par la communauté de développeurs.

Publiez votre code sur un dépôt git accessible au public (nous utilisons `github <https://github.com/>`_, mais vous pouvez `gitlab <https://gitlab.com/explore>`_), incluez une licence `open source <https://choosealicense.com/>`_ de votre choix et préparez un xml de description de votre plugin.
Le XML doit respecter cette structure:

.. code-block:: xml
   :linenos:

   <root>
      <name>Displayed name</name>
      <key>System name</key>
      <state>stable</state>
      <logo>http://link/to/logo/with/dimensions/40px/40px</logo>
      <description>
         <short>
            <en>short description of the plugin, displayed on list, text only</en>
            <lang>...</lang>
         </short>
         <long>
            <en>short description of the plugin, displayed on detail, Markdown accepted</en>
            <lang>...</lang>
         </long>
      </description>
      <homepage>http://link/to/your/page</homepage>
      <download>http://link/to/your/files</download>
      <issues>http://link/to/your/issues</issues>
      <readme>http://link/to/your/readme</readme>
      <authors>
         <author>Your name</author>
      </authors>
      <versions>
         <version>
            <num>1.0</num>
            <compatibility>0.90</compatibility>
         </version>
      </versions>
      <langs>
         <lang>en_GB</lang>
         <lang>...</lang>
      </langs>
      <license>GPL v2+</license>
      <tags>
         <en>
            <tag>tag1</tag>
         </en>
         <lang>
            <tag>tag1</tag>
         </lang>
      </tags>
      <screenshots>
         <screenshot>http://link/to/your/screenshot</screenshot>
         <screenshot>http://link/to/your/screenshot</screenshot>
         <screenshot>...</screenshot>
      </screenshots>
   </root>

Soignez le contenu de ce XML: ajoutez une belle description en plusieurs langues, une icône représentative et des captures, bref, donnez envie aux utilisateurs :star2:

Enfin, soumettez votre xml sur la `page dédiée <http://plugins.glpi-project.org/#/submit>`_ du catalogue des plugins (une inscription est nécessaire).

Teclib recevra une notification pour cette soumission et après quelques vérifications, activera la publication sur le catalogue.


Divers
------

Interroger la base de données
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Il existe 2 méthodes:

La première consiste à utilise directement la variable globale ``$DB`` et les fonctions de base mysql. Exemple:

.. code-block:: php
   :linenos:

   <?php

   function myfunction()
   {
      global $DB;

      $query = "SELECT * FROM glpi_computers";
      $res   = $DB->query($query);
      if ($DB->numrows($res)) {
         while ($data = $DB->fetch_assoc(res)) {
            ...
         }
      }
   }

Pour plus de détails, regardez l'api et les fonctions disponibles dans la classe `DBmysql <https://forge.glpi-project.org/apidoc/class-DBmysql.html>`_.

La seconde méthode est à privilégier et consiste à utiliser la classe `DBmysqlIterator <https://forge.glpi-project.org/apidoc/class-DBmysqlIterator.html>`_.
Elle a été fortement enrichie depuis la version 9.2 de GLPI et fournit un ``query builder`` exhaustif.
Voir `la documentation développeur <http://glpi-developer-documentation.readthedocs.io/en/master/devapi/dbiterator.html>`_ pour le détail des options possibles.

Voici quelques exemples d'usage:

.. code-block:: php
   :linenos:

   <?php

   foreach ($DB->request(...) as $id => $row) {
       //... work on each row ...
   }

   // => SELECT * FROM `glpi_computers`
   $DB->request(['FROM' => 'glpi_computers']);

   // => SELECT * FROM `glpi_computers`, `glpi_computerdisks`
   //       WHERE `glpi_computers`.`id` = `glpi_computerdisks`.`computer_id`
   $DB->request([
       'FROM' => ['glpi_computers', 'glpi_computerdisks'],
       'FKEY' => [
           'glpi_computers' => 'id',
           'glpi_computerdisks' => 'computer_id'
       ]
   ]);

L'utilisation de cet "iterateur" est conseillé car de futures versions de GLPI utiliseront de multiples moteur de base de données (Postgres par exemple) et à ce passage, vos requêtes seront directement compatibles sans nécessité de ré-écriture.


Tableaux de bord
^^^^^^^^^^^^^^^^

Depuis la version 9.5 de GLPI, des tableaux de bord sont disponibles depuis :


* la page centrale
* le menu Parc
* le menu Assistance

Cette fonctionnalité se décompose en plusieurs concepts - sous classes :


* un grille (``Glpi\Dashboard\Grid``) de placement de 26*24
* une collection de widgets (``Glpi\Dashboard\Widget``) pour permettre d'afficher des données sous forme graphique
* une collection de fournisseurs de données (``Glpi\Dashboard\Provider``) qui effectuent les requêtes SQL sur la base de données
* des droits (``Glpi\Dashboard\Right``) pour définir les droits d'accès à un tableau de bord
* des filtres (``Glpi\Dashboard\Filter``) pouvant s'afficher en entête d'un tableau de bord et impactant les fournisseurs.

Avec ces classes, on peut construire un tableau de bord qui affichera sur sa grille des cartes.
Une carte est une combinaison d'un widget, d'un fournisseur de données, d'un positionnement sur un grille et diverses options (comme une couleur de fond par exemple).

Compléter les existants
~~~~~~~~~~~~~~~~~~~~~~~

Via votre plugin, vous pouvez compléter ces concepts avec vos propres données et codes.

**🗋 setup.php**

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Plugin\Hooks;
   use GlpiPlugin\Myplugin\Dashboard;

   function plugin_init_myplugin()
   {
       ...

       // add new widgets to the dashboard
       $PLUGIN_HOOKS[Hooks::DASHBOARD_TYPES]['myplugin'] = [
           Dashboard::class => 'getTypes',
       ];

       // add new cards to the dashboard
       $PLUGIN_HOOKS[Hooks::DASHBOARD_CARDS]['myplugin'] = [
           Dashboard::class => 'getCards',
       ];
   }

En complément, créons une classe dédiée à nos ajouts aux tableaux de bord de GLPI:

**🗋 src/Dashboard.php**

.. code-block:: php
   :linenos:

   <?php

   namespace GlpiPlugin\Myplugin;

   class Dashboard
   {
       static function getTypes()
       {
           return [
               'example' => [
                   'label'    => __("Plugin Example", 'myplugin'),
                   'function' => __class__ . "::cardWidget",
                   'image'    => "https://via.placeholder.com/100x86?text=example",
               ],
               'example_static' => [
                   'label'    => __("Plugin Example (static)", 'myplugin'),
                   'function' => __class__ . "::cardWidgetWithoutProvider",
                   'image'    => "https://via.placeholder.com/100x86?text=example+static",
               ],
           ];
       }

       static function getCards($cards = [])
       {
           if (is_null($cards)) {
               $cards = [];
           }
           $new_cards =  [
               'plugin_example_card' => [
                   'widgettype'   => ["example"],
                   'label'        => __("Plugin Example card"),
                   'provider'     => "PluginExampleExample::cardDataProvider",
               ],
               'plugin_example_card_without_provider' => [
                   'widgettype'   => ["example_static"],
                   'label'        => __("Plugin Example card without provider"),
               ],
               'plugin_example_card_with_core_widget' => [
                   'widgettype'   => ["bigNumber"],
                   'label'        => __("Plugin Example card with core provider"),
                   'provider'     => "PluginExampleExample::cardBigNumberProvider",
               ],
           ];

           return array_merge($cards, $new_cards);
      }

       static function cardWidget(array $params = [])
       {
           $default = [
               'data'  => [],
               'title' => '',
               // this property is "pretty" mandatory,
               // as it contains the colors selected when adding widget on the grid send
               // without it, your card will be transparent
               'color' => '',
           ];
           $p = array_merge($default, $params);

           // you need to encapsulate your html in div.card to benefit core style
           $html = "<div class='card' style='background-color: {$p["color"]};'>";
           $html.= "<h2>{$p['title']}</h2>";
           $html.= "<ul>";
           foreach ($p['data'] as $line) {
               $html.= "<li>$line</li>";
           }
           $html.= "</ul>";
           $html.= "</div>";

           return $html;
       }

       static function cardWidgetWithoutProvider(array $params = [])
       {
         $default = [
            // this property is "pretty" mandatory,
            // as it contains the colors selected when adding widget on the grid send
            // without it, your card will be transparent
            'color' => '',
         ];
         $p = array_merge($default, $params);

         // you need to encapsulate your html in div.card to benefit core style
         $html = "<div class='card' style='background-color: {$p["color"]};'>
                     static html (+optional javascript) as card is not matched with a data provider
                     <img src='https://www.linux.org/images/logo.png'>
                  </div>";

         return $html;
      }

       static function cardBigNumberProvider(array $params = [])
       {
           $default_params = [
               'label' => null,
               'icon'  => null,
           ];
           $params = array_merge($default_params, $params);

           return [
               'number' => rand(),
               'url'    => "https://www.linux.org/",
               'label'  => "plugin example - some text",
               'icon'   => "fab fa-linux", // font awesome icon
           ];
      }
   }

Quelques explications sur les différentes méthodes :

* ``getTypes()`` : permet de définir les widgets disponibles pour les cartes et les fonctions à appeler pour faire l'affichage.
* ``getCards()`` : permet de définir les cartes disponibles pour les tableaux de bord (quand une est ajoutée à la grille). Comme expliqué précédemment, chacune est définie par une combinaison d'un label, d'un widget et optionnellement un fournisseur de données (provenant de votre plugin ou du coeur de GLPI)
* ``cardWidget()`` : utilise le paramètre fourni pour afficher un html. Libre à vous ici de déléguer l'affichage via un gabarit TWIG et d'utiliser votre bibliothèque javascript préférée.
* ``cardWidgetWithoutProvider()`` : Ne diffère pas énormement de la précédente fonction. Elle n'utilise juste pas le paramètre et retourne un HTML construit statiquement.
* ``cardBigNumberProvider()`` : exemple de fournisseur et du retour attendu par la grille lorsqu'elle affichera la carte.

Afficher votre propre tableau de bord
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Le systeme de tableaux de bord de GLPI étant modulaire, vous pouvez l'utiliser dans vos propres affichages.

.. code-block:: php
   :linenos:

   <?php

   use Glpi\Dashboard\Grid;

   $dashboard = new Grid('myplugin_example_dashboard', 10, 10, 'myplugin');
   $dashboard->show();

Le fait d'ajouter un contexte (``myplugin``) permet de filtrer les tableaux de bord disponible dans la liste déroulante disponible en haut à droite de la grille. Vous ne verrez pas ceux du coeur de GLPI (central, assistance, etc.).


Traduire vos plugins
^^^^^^^^^^^^^^^^^^^^

Tout au long de ce document, les exemples de code fournis ont pris soin d'utiliser les notations `gettext`_ de GLPI pour afficher des locales.
Même si votre plugin n'a pas vocation à publication et est destiné à un public restreint, c'est une bonne pratique de conserver tout de même cet usage de `gettext`_.

Le framework de GLPI fournit les fonctions suivantes pour la définition de vos locales:


* `__(string[, domain]) <https://forge.glpi-project.org/apidoc/function-__.html>`_: chaine de caractère simple.
* `_n(singular, plural, nb[, domain]) <https://forge.glpi-project.org/apidoc/function-_n.html>`_: chaine de caractère au singulier ou pluriel (le choix étant effectué selon la clef 'nb')
* `_sx(context, string[, domain]) <https://forge.glpi-project.org/apidoc/function-_sx.html>`_: identique à __() mais avec une option de contexte.
* `_nx(context, singular, plural, nb[, domain]) <https://forge.glpi-project.org/apidoc/function-_nx.html>`_: identique à _n() mais avec une option de contexte.

Le ``domain`` représente l'endroit ou sont stockées les "locales".
Par défaut (et en absence de ce paramètre), on considère que la chaîne est dans la collection de locales de GLPI. Pour vos plugins, il est important d'ajouter la clef le représentant dans ce paramètre.

Le ``context``, jamais affiché, permet de fournir aux traducteurs une indication sur le contenu de la chaine. Selon les langues, un même mot peut avoir plusieurs significations, nous avons donc besoin d'ajouter une précision.

`gettext`_ fonctionne avec 3 types de fichiers:

* un ``.pot`` généralement du nom de votre plugin recevant les définitions des locales,
* un ou plusieurs fichiers ``.po`` en provenance du fichier ``.pot`` recevant les sources des traductions,
* le même nombre de fichiers binaires ``.mo`` qui correspondent à la version compilée des ``.po``. Ce sont ces fichiers que GLPI utilisera pour afficher les traductions.

Une fois le ``pot`` généré (voir ci dessous les commandes utiles), vous devrez faire un choix pour la génération des autres fichiers:

* Vous pouvez utiliser un logiciel tel que `poedit <https://poedit.net>`_ qui vous permettra de générer en locales vos traductions ``.po``.
* Vous pouvez aussi, dans le cas ou votre plugin est destiné à publication, utiliser le service en ligne `transifex <https://www.transifex.com>`_ (gratuit pour les projets open-source).
  Les plugins publics de Teclib' utilise actuellement ce service.

Si vous avez utilisé comme squelette le plugin `Empty`_, vous bénéficierez d'outils en ligne de commandes pour gérer vos locales:

.. code-block:: shell

   # extrait les chaines gettext de votre code
   # pour les référencer dans un fichier locales/myplugin.pot
   vendor/bin/extract-locales

   # pour tout les fichier locales/*.po, génère un fichier compilé .mo
   vendor/bin/robo locales:mo

   # Envoi le fichier pot vers le service transifex
   vendor/bin/robo locales:push

   # Recupère toutes les traductions (.po) depuis le service transifex
   vendor/bin/robo locales:pull

.. warning::

    ℹ️  Il est possible qu'après la génération des fichiers ``.mo`` que GLPI n'affiche pas la traduction de vos chaînes.
    Le cache php est généralement la cause.
    Il convient de redémarrer votre serveur Web ou le serveur PHP selon votre configuration système.


API Rest
--------

Depuis la version 9.1 de GLPI, celui-ci dispose d'une API externe aux formats REST et XmlRPC.

.. image:: /_static/images/API.png
   :alt: Api configuration


Configuration
^^^^^^^^^^^^^

Par mesure de sécurité, elle est désactivée par défaut.
Depuis le menu ``Configuration > Générale, onglet API``, vous pouvez l'activer.

Elle est accessible depuis votre instance GLPI à l'url:


* ``http://path/to/glpi/apirest.php``
* ``http://path/to/glpi/apixmlrpc.php``

Le premier lien bénéficie d'une documentation intégrée quand vous y accédez depuis un navigateur web (un lien est fourni dès que l'api est active).

Pour le reste de la configuration:


* la connexion avec les identifiants permet d'utiliser un couple ``login`` / ``password`` tel que par l'interface web
* la connexion avec le jeton permet d'utiliser celui affiché dans les préférences utilisateurs

  .. image:: /_static/images/api_external_token.png
     :alt: jeton externe

* les "clients API" permettent de limiter l’accès à l'api pour certaines IP et de récupérer du log si nécessaire. Un client permettant un accès depuis n'importe quelle ip est fourni par défaut.

----

Vous trouverez dans le dépôt suivant un `squelette d'usage de l'api <https://github.com/orthagh/glpi_boostrap_api>`_.
Celui-ci est écrit en php et utilise la librairie `Guzzle <http://docs.guzzlephp.org/en/latest/>`_ pour exécuter ses requêtes HTTP.

Par défaut, il effectue une connexion avec des identifiants définis dans le fichier ``config.inc.php`` (que vous devez créer en copiant le fichier ``config.inc.example``.

.. warning::

    ⚠️ Assurez-vous du fonctionnement du script fourni avant de continuer.


Usage de l'API
^^^^^^^^^^^^^^

Pour l'apprentissage de cette partie, en nous aidant de la documentation intégrée (ou celle disponible sur `github <https://github.com/glpi-project/glpi/blob/master/apirest.md>`__), nous effectuerons une série d'exercices:

.. note::
   * [x] 📝 **Exercice**: Testez une nouvelle connexion via le jeton externe d'authentification de l'utilisateur glpi à la place de la connexion

.. note::
  * [x] 📝 **Exercice**: Ajoutez à la fin de votre script une fermeture de la session.

.. note::
  * [x] 📝 **Exercice**: Simulez le cycle de vie d'un ordinateur:
    * ajoutez l'ordinateur ainsi que quelques volumes (itemtype ``Item_Disk``,
    * modifiez de plusieurs champs,
    * ajoutez lui des informations financière et administratives (itemtype ``Infocom``),
    * affichez son détail dans une page php,
    * effectuez une mise au rebut (corbeille) de l'ordinateur,
    * et ensuite une supression définitive.

.. note::

  * [x] 📝 **Exercice**: Récupérez la liste des ordinateurs et afficher les dans un tableau HTML. L'``endpoint`` à utiliser est "Search items". Si vous souhaitez afficher les libellés des colonnes, il faudra utiliser l'``endpoint`` "List searchOptions".


Production de statistiques
--------------------------

Metabase
^^^^^^^^

.. image:: /_static/images/metabase.png
   :alt: logo metabase

`Metabase`_ est un outil open source d'`informatique décisionnelle`_. Il permet de "poser des questions" à propos de vos données et vous laisse les afficher dans des formats qui font sens, que ce soit un histogramme ou une table détaillée.

Vos questions peuvent être sauvegardées pour plus tard et vous pouvez les regrouper dans des tableaux de bords.
Il est relativement simple de partager vos questions et "dashboards" avec le reste de votre équipe.

Configuration
~~~~~~~~~~~~~

L’exécutable de `Metabase`_ est un fichier ``.jar`` accompagné par défaut d'une base de données `H2 <https://fr.wikipedia.org/wiki/H2_(base_de_donn%C3%A9es>`_).
Le seul pré-requis est la présence du jdk en version 6 mini. Il fonctionne, à priori, sur les versions Oracle et OpenJDK. De notre coté, nous utilisons la version 1.8 d'openjdk.

Vous pouvez trouver la dernière version sur la `page dédiée au jar <http://www.metabase.com/start/jar.html>`_.

.. warning::

    ℹ️ L'équipe de `Metabase`_ fournit des paquets préconfigurés pour les plate-formes suivantes:

    * `image Docker <http://www.metabase.com/start/docker.html>`_
    * `Amazon Web Services <http://www.metabase.com/start/aws.html>`_
    * `Heroku <http://www.metabase.com/start/heroku.html>`_

Une fois récupéré, il se lance simplement via la commande:

.. code-block:: shell

   java -jar metabase.jar

Cette commande lancera le serveur par défaut sur le port 3000, vous devriez donc pouvoir y accéder depuis votre poste à l'adresse ``http://localhost:300`` et voir l'assistant d'installation.

.. image:: /_static/images/metabase_welcomescreen.png
   :alt: accueil metabase


Cet assistant vous demandera de créer un utilisateur d'administration puis de connecter une première base de données.

`Metabase`_ peut connecter plusieurs bases de données pour présenter des questions de plusieurs sources sur un même tableau de bord.
Il est par contre, pour le moment impossible de croiser des données dans une même question.

Dans le cadre de cette formation, la connexion de la base de donnée n'a pas besoin nécessairement d'être sécurisée. Pour une utilisation en production, nous conseillons:


* Un nom d'utilisateur et un mot de passe dédiés à `metabase`_ ;
* Des droits de lecture seulement sur les tables nécessaires à vos requêtes ;
* Un filtrage d’accès (ip par exemple).

Dernière étape de l'assistant, il vous sera demandé si vous autorisez la collecte de données anonymisées sur votre usage du logiciel et si vous souhaitez recevoir des "newsletters".

Utilisation
~~~~~~~~~~~

Après installation, vous arrivez sur l’accueil de `metabase`_ qui vous présente l'activité récente sur le logiciel et les objets récemment vus (normalement aucun à ce niveau).

Questions
"""""""""

Les questions sont le moyen de requérir des données et peuvent être construites de 2 manières.

La manière par défaut est un constructeur de requêtes à base de listes déroulantes. Plutôt intuitif, il permet la construction de données simples et rapides.


.. image:: http://www.metabase.com/docs/v0.22.2/images/Count.png
   :target: http://www.metabase.com/docs/v0.22.2/images/Count.png
   :alt: Constructeur de requêtes

.. |metabase_sql| image:: /_static/images/metabase_sql.png

L'autre méthode, accessible depuis depuis l'icône |metabase_sql|, permet le passage en mode SQL.

.. image:: /_static/images/metabase_SQLInterface.png
   :alt: SQL query


Elle vous permet d'écrire vos requêtes complètement en SQL.
Une fois la requête exécutée, les réponses seront affichées en mode tableau.

.. note::

    📝 **Exercice**: Sans se préoccuper des dates pour le moment, construisez plusieurs questions permettant l'affichage de :


    * le nombre de ticket ouvert chaque mois dans un graphique de type "line"
    * un camembert affichant un top 10 des catégories les plus utilisées dans les tickets.
    * 3 compteurs représentant le nombre de tickets:

    * ouverts
    * fermés
    * en attente

Collections
"""""""""""

Dans le cas d'un volume conséquent, les questions peuvent être organisées dans des "Collections".
Elles font office de dossiers.

Par ailleurs, vous avez la possibilité de définir des groupes (coté administration) et les collections permettent d'accorder des droits de visualisation ou d'édition à ces groupes.

Dashboard
"""""""""

Vos questions peuvent être agrégées dans un tableau de bord.
Outre l'affichage de données multiples, ce concept apporte:


* un mode plein écran
* un rafraichissement automatique de la page
* un mode nuit (font sombre, textes clairs)
* des filtres (voir le `paragraphe sur les variables <#variables>`_ plus loin)

.. image:: /_static/images/metabase_dashboard.png
   :alt: Tableau de bord

Les tableaux de bord seront visibles par les autres utilisateurs si au moins une question est stockée dans une collection à laquelle ils ont accès.
Ils présenteront au maximum toutes les questions avec les bons droits (les autres étant cachées).
Dans le cas de l'absence de collection, vos tableaux de bord seront accessibles à tous les utilisateurs.

Variables
"""""""""

Lors de la création d'une question en mode SQL, vous avez la possibilité de définir des variables dans leur code afin d'exploiter des paramètres.
La syntaxe est la suivante: ``{{variable}}``

Ajouter une variable ouvre automatiquement le panneau à droite de la question pour vous permettre de sélectionner un type.

Les trois premiers disponibles, ``Text``, ``Number`` et ``Date``, permettront l'affichage d'un paramètre pour vos questions uniquement et lors du traitement, la variable sera remplacée par la valeur sélectionnée.

Le dernier, ``Field Filter``, est plus complexe.
Il n'affiche pas de paramètre dans votre question mais vous permettra de cibler un champ particulier d'une table et ainsi d'ajouter des filtres à vos tableaux de bord.

Dans ce cas, ce n'est pas seulement la valeur choisie qui remplacera la variable mais une comparaison complète du champ sélectionné avec la valeur choisie.

C'est particulièrement utile pour définir des sélecteurs de dates relatives:

.. image:: /_static/images/metabase_dashboard_filter.png
   :alt: Filtre de tableau de bord


.. warning::

    ⚠️ Dans le cas de l'absence de choix d'un sélecteur, la variable sera remplacée par ``1=1``

.. note::

    📝 **Exercice**: Ajoutez aux questions précédemment développés un filtre (pour vos "dashboards") permettant de selectionner des dates.

"Data model" et "Data reference"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Quand vous avez ouvert un accès à des utilisateurs avancés, il est interressant de les guider dans la découverte et l'exploitation des données à leur disposition.

Depuis l'administration (sous votre nom d'utilisateur), vous aurez accés à un menu "Data model".
Une fois une base sélectionnée, vous pouvez:


* rendre invisibles certaines tables non pertinentes,
* changer le type des champs: `Metabase`_ effectue lors de la première synchronisation de vos base, un "auto-typage" de vos champs et une détection des clefs étrangères. Dans le cas de GLPI, elles ne sont pas correctement détectées,
* définir des filtres (``segments``) avec des labels,
* de la même façon, des aggrégations (``metrics``).

Cela permet, lors de la création de questions, que le mode constructeur de requêtes soit enrichi:

.. image:: /_static/images/metabase_datamodel_result.png
   :alt: constructeur de requêtes enrichi

Depuis la partie utilisation (sortez de l'administration donc) de metabase, le menu ``Data Reference`` est une sorte de wiki (la première page peut être éditée) pour présenter les données.
Les descriptions des bases et tables sont visibles ici.
C'est l'endroit idéal pour initier vos utilisateurs à la découverte de vos données.

Pulse
~~~~~

Les "Pulses" présents dans le menu général de `Metabase`_ vous aideront à envoyer de façon périodique des questions à d'autres utilisateurs.
2 canaux sont possibles, mail et via l'intégration slack

.. warning::

    ⚠️ Les questions envoyées seront forcement dans un format tableau, les graphiques ne sont pas disponibles ici.

----

.. _Empty:  https://github.com/pluginsGLPI/empty
.. _moteur de recherche:  http://glpi-developer-documentation.readthedocs.io/en/master/devapi/search.html
.. _Composer: https://getcomposer.org/download/
.. _CommonDBTM: https://github.com/glpi-project/glpi/blob/10.0.15/src/CommonDBTM.php
.. _Computer: https://github.com/glpi-project/glpi/blob/10.0.15/src/Computer.php
.. _Html: https://github.com/glpi-project/glpi/blob/10.0.15/src/Html.php
.. _Migration: https://github.com/glpi-project/glpi/blob/10.0.15/src/Migration.php
.. _Notepad: https://github.com/glpi-project/glpi/blob/10.0.15/src/Notepad.php
.. _Log: https://github.com/glpi-project/glpi/blob/10.0.15/src/Log.php
.. _Searchoptions: http://glpi-developer-documentation.readthedocs.io/en/master/devapi/search.html#search-options
.. _Profile: https://github.com/glpi-project/glpi/blob/10.0.15/src/Profile.php
.. _Session: https://github.com/glpi-project/glpi/blob/10.0.15/src/Session.php
.. _gettext: https://www.gnu.org/software/gettext/
.. _Metabase: http://www.metabase.com/
.. _informatique décisionnelle: https://fr.wikipedia.org/wiki/Informatique_d%C3%A9cisionnelle
