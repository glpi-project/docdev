Source Code management
======================

GLPi source code management is handled by [GIT](https://en.wikipedia.org/wiki/Git) and hosted on [GitHub](https://github.com/glpi-project/glpi).

In order to contribute to the source code, you will have to know a few things about Git and the development model we follow.

Branches
--------

On the Git repository, you will  find several existing branches:
- `master` contains the next major release source code,
- `xx/bugfixes` contains the next minor release source code,
- you should not care about all other branches that may exists, they should have been deleted right now.


The `master ` branch is where new features are added. This code is reputed as _non stable_.

The `xx/bugfixes` branches is where bugs are fixed. This code is reputed as _stable_.<br/>
Those branches are created when any major version is released. At the time I wrote these lines, latest stable version is `9.1` so the current bugfix branch is `9.1/bugfixes`. As old versions are not supported, old bugfixes branches will not be changed at all; while they're still existing.

Testing
-------

Unfortunately, Unfortunatelyit tests in GLPi are not numerous... But that's willing to change, and we'd like - as far as possible - that proposals contains unit tests for the bug/feature they're related.

ANyways, existing unit tests may never be broken, if you made a change that breaks something, check your code, or change the unit tests, but fix that! ;)

Workflow
--------

### In short...

In a short form, here is the workflow we'll follow:
- create a ticket
- fork, create a specific branch, hack
- open a pr

Each bug will be fixed in a branch that came from the correct `bugfixes` branch. Once merged back to the branch, developper must backport the fixes in the `master`; just with a simple cherry-pick for simple cases, or opening another pull request if changes are huge.

Each feature will be hacked in a branch that came from `master`, and will be merged back to `master`.

### General

Most of the times, when you'll want to contribute to the project, you'll have to retrieve the code and change it before you can report upstream. Note that I will detail here the basic command line instructions to get things working; but of course, you'll find equivalents in your favorite Git GUI/tool/whatever ;)

Just work with a:
```
$ git clone https://github.com/glpi-project/glpi.git
```

A directory named `glpi` will bre created where you've issued the clone.

Then - if you did not alreay - you will have to create a fork of the repository on your github account; using the `Fork` button from the [GLPi's Github page](https://github.com/glpi-project/glpi/). This will take a few moments, and you will have a repository created, `{you user name}/glpi - forked from glpi-project/glpi`.

Add your fork as a remote from the cloned directory:
```
$ git remote add my_fork https://github.com/{your user name}/glpi.git
```

You can replace `my_fork` with what you want but `origin` (just remember it); and you will find you fork URL from the Github UI.

A basic good practice using Git is to create a branch for everything you want to do; we'll talk about that in the sections below. Just keep in mind that you will publish your branches on you fork, so you can propose your changes.

Whan you open a new pull request, it will be reviewed by one or more member of the community. If you're asked to make some changes, just commit again on your local branch, push it, and you're done; the pull request will be automatically updated.

### Bugs

Well... Bugs happens :) If you find a bug in the current stable release, you'll have to work on the `bugfixes` branch; and, as we've said already, create a specific branch to work on. You may name your branch explicitely like `9.1/fix-sthing` or to reference an existing issue `9.1/fix-1234`; just prefix it with `{version}/fix-`.

Generally, the very first step for a bug is to be [filled in a ticket](https://github.com/glpi-project/glpi/issues).

From the clone directory:
```
$ git checkout -b 9.1/bugfixes origin/9.1/bugfixes
$ git branch 9.1/fix-bad-api-callback
$ git co 9.1/fix-bad-api-callback
```
At this point, you're working on an only local branch named `9.1/fix-api-callback`. You can now work to solve the issue, and commit (as frequently as you want).

At the end, you will want to get your changes back to the project. So, just push the branch to your fork remote:
```
$ git push -u my_fork 9.1/fix-api-callback
```

Last step is to create a Pull Request (PR) to get your changes back to the project. You'll find the button to do this visiting your fork or even main project github page.

Just remember here we're working on some bugfix, that should reach the `bugfixes` branch; the PR creation will probably propose you to merge against the `master` branch; and maybe will tell you they are conflicts, or many commits you do not know about... Just set the base branch to the correct bugfixes and that should be good.

### Features

Before doing any work on any feature, mays sure it has been discussed by the community. Open - if it does not exists yet - a ticket with your detailled proposition. Fo technical features, you can work directly on github; but for work proposals, you should take a look at our [feature proposal platform](http://glpi.userecho.com/).

If you want to add a new feature, you will have to work on the `master` branch, and create a local branch with the name you want, prefixed with `feature/`.

From the clone directory:
```
$ git branch feautre/my-killer-feature
$ git co feature/my-killler feature
```

You'll notice we do no change branch on the first step; that is just because `master` is the default branch, and therefore the one you'll be set on just fafter cloning. At this point, you're working on an only local branch named `feature/my-killer-feature`. You can now work and commit (as frequently as you want).

At the end, you will want to get your changes back to the project. So, just push the branch on your fork remote:
```
$ git push -u my_fork feature/my-killer-feature
```

### Commit messages

There are several good practices regarding commit messages, but thus is quite simple:
- the commit message may refer an existing ticket if any, with keywords like `refs #1234` or `see #1234"` to make a simple reference, `closes #1234` or `fixes #1234` to get issue automatically closed once the code will be merged back on the project;
- the first line of the commit should be as short and as concise as possible
- if you want or have to provide details, let a blank line after the first commit line, and go on. Please avoid very long lines (some conventions talks about 80 characters maximum per line, to keep it lisible).

