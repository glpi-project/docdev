Mfa:CodeInput
=============

.. versionadded:: 12.0.0

Renders a one-time-code field split into one input per digit, used on the two-factor authentication and re-authentication screens.

Props
-----

All props are optional.

* :code:`digits` **int**. Number of digit inputs to render.

  * Default: ``6``.

Usage
-----

.. code-block:: twig

    <twig:Mfa:CodeInput />
    <twig:Mfa:CodeInput :digits="8" />

Digits are submitted as a ``totp_code[]`` array, to be joined back server side:

.. code-block:: php

    $totp_code = implode('', $request->request->all('totp_code'));

Behavior
--------

The component loads its own JavaScript module. It moves focus to the next cell as a digit is typed, handles ``Backspace`` and the left and right arrow keys, and spreads a pasted code across the cells.

.. note::

    The form is never submitted automatically once the last digit is filled. The user validates with the form button, which avoids an unexpected context change for assistive technologies.
