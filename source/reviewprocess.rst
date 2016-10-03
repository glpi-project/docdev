Review process
==============

Here is the process you must follow when you are reviewing a PR.

1. Make sure the destination branch is the correct one:

  * `master` for new features,
  * `xx/bugfixes` for bug fixes

2. Check if unit tests are not failing,
3. Check if coding standards checks are not failing,
4. Review the code itself. It must follow :doc:`GLPi's coding standards <codingstandards>`,
5. Using the Github review process, approve, request changes or just comment the PR,

  * If some new methods are added, or if the request made important changes in the code, you should ask the developer to write some more unit tests

6. A PR can be merged back if two developers approved it, or if one developer approved it more than one day ago,
7. A bugfix PR that has been merged into the `xx/bugfixes` branch must be reported on the `master` branch. If the `master` already contains many changes, you may have to change some code before doing this. f changes are consequent, maybe should you open a new PR against the `master` branch for it,
8. Say thanks to the contributor :-)
