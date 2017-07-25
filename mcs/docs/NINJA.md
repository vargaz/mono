Ninja Build Support
===================

There is minimal support for building parts of the class libraries using Ninja instead of Make.

Usage
------

- Run `make ninja-gen` in `mcs/` to generate the ninja build files.
- Run `make ninja` to build.

Implementation
--------------

The `ninja-gen` target will run a makefile target in each subdirectory which will generate ninja fragments into `build/deps`, then
concatenates them together into one `.ninja` file. The actual generation of ninja files is done by the `build/gen-ninja.py` script.

The main difference between make and ninja is that ninja runs each command from the root directory, so all the paths need to
be transformed to be relative to the `mcs/` directory. This includes source files, resources, signing key files etc.

Issues
------

- Only the net_4_x profile is supported.
- No support for automatically regenerating the ninja build files.
- Only running the csc compiler is supported, signing, stringreplace, generating built sources etc, are missing.
- No windows support.

