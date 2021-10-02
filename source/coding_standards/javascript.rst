JavaScript Coding standards
===========================

ECMAScript Level
----------------

All JavaScript code should be written to support the target ECMAScript version specified for the version of GLPI you are writing the code for.
This version can be found in the `.eslintrc.json` file in the `parserOptions.ecmaVersion` property.

For reference, versions of GLPI before 9.5.0 had a target ECMAScript version of 5 due to its support of Internet Explorer 11.
Starting with GLPI 9.5.0, the target version was bumped to 6 (2015).

Functions
---------

Function names must be written in *camelCaps*:

.. code-block:: JavaScript

   function getUserName(a, b = 'foo') {
      //do something here!
   }

   class ExampleClass {

      getUserName(a, b = 'foo') {
         //do something here!
      }
   }

Space after opening parenthesis and before closing parenthesis are forbidden. For parameters which have a default value, add a space before and after the equals sign.

All functions MUST have a JSDoc block especially if it has parameters or is not a simple getter/setter.

Classes
-------

If you are writing code for versions of GLPI before 9.5.0, you may not use classes as class support was added in EMCAScript 6.

Class names must be written in `PascalCase`.

..code-block:: JavaScript

   class ExampleClass {

   }

   class ExampleClass extends BaseClass {

   }

In general, you should create a new file for each class.

Comments
--------

For simple or one-line comments, use `//`.

For multi-line or JSDoc comments, use '/** */'

Function JSDoc blocks MUST contain:

- Description
- Parameter types and descriptions
- Return type

Function JSDoc blocks SHOULD contain:

- The version of GLPI or the plugin that the function was introduced

.. code-block:: JavaScript

    /**
     * Short description (single line)
     *
     * This is an optional longer description that can span
     * multiple lines.
     *
     * @since 10.0.0
     *
     * @param {{}} a First parameter description
     * @param {string} b Second parameter description
     *
     * @returns {string}
     */
    function getUserName(a, b = 'foo') {

    }

JSDoc sections MUST be in the following order with an empty line between them:

- Short description (one line)
- Long description
- '@deprecated'
- '@since'
- '@param'
- '@return'
- '@see'
- '@throw'
- '@todo'

Variable types
--------------

When type hinting in JSDoc blocks, you MAY use any of the native types or class names.

If you want to create custom types/object shapes without creating a class, you MAY define a new type using the JSDoc '@typedef' tag.

Quoting Strings
---------------

Using single quotes for simple strings is preferred. If you are writing for GLPI 9.5.0 or higher, you may use the ECMAScript 6 template literals feature.

When your strings contain HTML content, you SHOULD use template literals (if possible). This lets you format your HTML across multiple lines for better readability and easily inject variable values without concatenation.

Files
-----

Regular JavaScript files MUST have only lowercase characters in the name. If using modules, the file name MAY have captialized characters.

JavaScript files for tests MAY contain uppercase characters.