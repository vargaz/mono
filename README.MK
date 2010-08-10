This branch contains the beginnings of an automake replacement written as GNU Make
macros, in the style of http://code.google.com/p/quagmire/.

Design:
- target GNU make 3.81 + GNU systems.
- implement automake+libtool as GNU Make constructs, keep autoconf for now,
  require no/minimal changes to Makefile.am-s.
- generate Makefile-s from Makefile.am-s:
  - change automake conditionals to make conditionals (if -> ifdef)
  - set top_buildir
  - include $(top_buildir)/conf.mk
  - include rules.mk at the bottom
  - no substitutions, use a single conf.mk file.
