#
# pre.mk:
#
#   Makefile fragment included at the end of conf.mk
#

ifndef .FEATURES
$(error GNU make 3.81 or later is required)
endif

ifndef top_builddir
$(error top_builddir must be set)
endif

# Make 'all' the default target
all:

# Compute srcdir/top_srcdir
ifeq ($(abs_top_srcdir),$(abs_top_builddir))
top_srcdir := $(top_builddir)
srcdir := .
else
top_srcdir := $(abs_top_srcdir)
pwd := $(shell pwd)
thisdir := $(patsubst $(abs_top_builddir)%,%,$(pwd))
srcdir := $(abs_top_srcdir)/$(thisdir)
$(info srcdir: $(srcdir))
endif

# FIXME:
am--refresh:
