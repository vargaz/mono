#
# rules.mk
#
#   Makefile rules implementing automake+libtool as GNU Make constructs.
#
# - Should be included after the body of a Makefile.
# - Similar to quagmire: http://code.google.com/p/quagmire/
#

# FIXME: Add a namespace like in quagmire ?
#
# The code below uses complex variable substitutions, read the GNU Make manual
# to understand it:
# http://www.gnu.org/software/make/manual/make.html
# We can't define temporary variables inside a define, so have to duplicate a lot of stuff.
#

NULL :=
# OSX's /bin/echo can't handle -e so we have to generate a variable with spaces as its value
INDENT := $(NULL)      # end of line
ECHO=echo

# FIXME: Cross compilation
IS_DARWIN := $(subst Darwin,1,$(findstring Darwin,$(shell uname)))

#
# Compilation
#

DEFAULT_INCLUDES=-I. -I$(top_builddir)
CFLAGS += $(DEFAULT_INCLUDES) $(AM_CPPFLAGS) $(AM_CFLAGS) -DHAVE_CONFIG_H

PIC_CFLAGS=-fPIC -DPIC

%.o: $(srcdir)/%.c
	$(if $(V),,@$(ECHO) "CC$(INDENT)$@";) $(CC) -c $(CPPFLAGS) $(CFLAGS) -o $@ $< -MD -MP -MF .deps/$(patsubst %.o,%.Po,$@)

%.o: %.s
	$(if $(V),,@$(ECHO) "AS$(INDENT)$@";) $(AS) $(ASFLAGS) -o $@ $<

# A macro for adding custom C compilation rules
define add-cc-comp-rule
# $(1) is the name of the target
# $(2) is the name of the source
# $(3) is the name of the CFLAGS var to use
$(1): $(2)
	$(if $(V),,@$(ECHO) "CC$(INDENT)$$@";) $$(CC) -c $$(CPPFLAGS) $$(CFLAGS) $$($(3)) -o $$@ $$< -MD -MP -MF .deps/$$(patsubst %.o,%.Po,$$@)

$(patsubst %.o,%-pic.o,$(1)): $(2)
	$(if $(V),,@$(ECHO) "CC$(INDENT)$$@";) $$(CC) -c $$(CPPFLAGS) $$(CFLAGS) $(PIC_CFLAGS) $$($(3)) -o $$@ $$< -MD -MP -MF .deps/$$(patsubst %.o,%.Po,$$@)
endef # add-cc-comp-rule

#
# Libraries
#

STATIC_LIB_SUFFIX = .a
SHARED_LIB_SUFFIX = $(if $(IS_DARWIN),.dylib,.so)
PIC_LIB_SUFFIX = -pic.a
PIC_OBJ_SUFFIX = -pic.o

define add-ltlib-rules
# $(1) is the library name, $(2) is the prefix used by the automake variables
# $(3) is yes for installable libraries, '' otherwise

$(1)_OBJECTS := $(patsubst %.s,%.o,$(patsubst %.c,$(2)-%.o, $(subst /,-,$(filter-out %.h, $($(2)_SOURCES)))))
ifneq ($(3)$(enable_shared),)
$(1)_PIC_OBJECTS := $(patsubst %.s,%.o,$(patsubst %.c,$(2)-%$(PIC_OBJ_SUFFIX), $(subst /,-,$(filter-out %.h, $($(2)_SOURCES)))))
endif

# Add a rule for normal source files
$(eval $(call add-cc-comp-rule,$(2)-%.o,$(srcdir)/%.c,$(2)_CFLAGS))

# Add rules for source files in subdirectories
$(foreach adir,$(patsubst %/,%,$(filter-out ./, $(sort $(dir $($(2)_SOURCES))))),$(eval $(call add-cc-comp-rule,$(2)-$(adir)-%.o,$(srcdir)/$(adir)/%.c,$(2)_CFLAGS)))

# Collect dependend libraries
all-lt-deps += $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$(filter %.la,$($(2)_LIBADD)))
all-lt-deps += $(patsubst %.a,%$(STATIC_LIB_SUFFIX),$(filter %.a,$($(2)_LIBADD)))

# Temporary directories holding the extracted dependent libraries
$(1)_LT_DIRS := $(patsubst %,.libs/%,$(notdir $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$(filter %.la,$($(2)_LIBADD)))))
$(1)_LT_DIRS_2 := $(patsubst %,.libs/%,$(notdir $(patsubst %.a,%$(STATIC_LIB_SUFFIX),$(filter %.a,$($(2)_LIBADD)))))

# Contents of dependent libraries
$(1)_LT_FILES := $(patsubst %,.libs/%/*.o,$(notdir $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$(filter %.la,$($(2)_LIBADD)))))
$(1)_LT_FILES_2 := $(patsubst %,.libs/%/*.o,$(notdir $(patsubst %.a,%$(STATIC_LIB_SUFFIX),$(filter %.a,$($(2)_LIBADD)))))
$(1)_PIC_LIBS := $(foreach ltlib,$(filter %.la,$($(2)_LIBADD)),$(patsubst %.la,%$(PIC_LIB_SUFFIX),$(dir $(ltlib))/$(notdir $(ltlib))))

all-objects += $$($(1)_OBJECTS) $$($(1)_PIC_OBJECTS)

all-static-libs += $(1)$(STATIC_LIB_SUFFIX) $(1)$(PIC_LIB_SUFFIX)
all-shared-libs += $(1)$(SHARED_LIB_SUFFIX)

all-am: $(1)

.PHONY: $(1)

ifeq ($(3),yes)
# Create a static lib + a shared lib
$(1): $(1)$(STATIC_LIB_SUFFIX) $(1)$(SHARED_LIB_SUFFIX)
else ifeq ($(enable_shared),yes)
ifneq ($(findstring -static,$($(2)_LDFLAGS)),)
# Create a static lib only
$(1): $(1)$(STATIC_LIB_SUFFIX)
else
# Create a static lib + a pic lib
$(1): $(1)$(STATIC_LIB_SUFFIX) $(1)$(PIC_LIB_SUFFIX)
endif
else
$(1): $(1)$(STATIC_LIB_SUFFIX)
endif

# Rules for creating the library
$(1)$(STATIC_LIB_SUFFIX): $$($(1)_OBJECTS) $$($(1)_LT_DIRS) $$($(1)_LT_DIRS_2)
	$(if $(V),,@$(ECHO) "LD$(INDENT)$$@";) $(RM) $$@ && $(AR) qc $$@ $$($(1)_OBJECTS) $$($(1)_LT_FILES) $$($(1)_LT_FILES_2)
$(1)$(PIC_LIB_SUFFIX): $$($(1)_PIC_OBJECTS) $$($(1)_LT_DIRS) $$($(1)_LT_DIRS_2)
	$(if $(V),,@$(ECHO) "LD$(INDENT)$$@";) $(RM) $$@ && $(AR) qc $$@ $$($(1)_PIC_OBJECTS) $$($(1)_LT_FILES) $$($(1)_LT_FILES_2)
$(1)$(SHARED_LIB_SUFFIX): $$($(1)_PIC_OBJECTS) $$($(1)_PIC_LIBS)
	$(if $(V),,@$(ECHO) "LD$(INDENT)$$@";) $(RM) $$@ && $(CC) --shared -o $$@ $$($(1)_PIC_OBJECTS) $$($(1)_PIC_LIBS)
endef # add-ltlib-rules

# Add rules for each library
$(foreach lib,$(lib_LTLIBRARIES),$(eval $(call add-ltlib-rules,$(patsubst %.la,%,$(lib)),$(subst .,_,$(subst -,_,$(lib))),yes)))
$(foreach lib,$(noinst_LTLIBRARIES),$(eval $(call add-ltlib-rules,$(patsubst %.la,%,$(lib)),$(subst .,_,$(subst -,_,$(lib))),)))
$(foreach lib,$(noinst_LIBRARIES),$(eval $(call add-ltlib-rules,$(patsubst %.a,%,$(lib)),$(subst .,_,$(subst -,_,$(lib)))),))

#
# Executables
#

define add-program-rules
# $(1) is the executable name, $(2) is the prefix used by the automake variables

# Collect object files, filtering out headers and files in other directories
# Object files will be named <libtool name>-<srcname>.o
# If $(2)_SOURCES is not defined, use $(1).c
$(1)_OBJECTS := $(patsubst %.s,%.o,$(patsubst %.c,$(2)-%.o, $(notdir $(filter-out %.h, $(if $($(2)_SOURCES),$($(2)_SOURCES),$(1).c)))))
# Add a compilation rule for these files using the per target CFLAGS
$(eval $(call add-cc-comp-rule,$(2)-%.o,$(srcdir)/%.c,$(2)_CFLAGS))

# Add rules for source files in other directories
$(foreach srcfile,$(filter ../%, $(filter-out %.h, $($(2)_SOURCES))),$(eval $(call add-cc-comp-rule,$(patsubst %.c,$(2)-%.o,$(notdir $(srcfile))),$(srcdir)/$(srcfile),$(2)_CFLAGS)))

# FIXME: Link against the shared version if available unless -static is in LDFLAGS
$(1)_REAL_LDADD := $(patsubst %.lo,%.o, $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$($(2)_LDADD)))

# automake uses -static to mark that the executable should be linked against
# the static versions of libtool libs.
$(2)_REAL_LDFLAGS := $(subst -static,,$($(2)_LDFLAGS))

# Collect dependend libraries
$(1)_LIB_DEPS := $(patsubst %.a,%$(STATIC_LIB_SUFFIX),$(filter %.a,$($(2)_LDADD)))

all-objects += $$($(1)_OBJECTS)

all-am: $(1)

# The rule linking the executable
$(1): $$($(1)_OBJECTS) $$($(1)_LIB_DEPS)
	$(if $(V),,@$(ECHO) "LD$(INDENT)$$@";) $(CC) -o $$@ $$($(1)_OBJECTS) $$($(2)_REAL_LDFLAGS) $$($(1)_REAL_LDADD) $(LIBS)
endef # add-program-rules

# Add rules for each entry in $(bin/noinst_PROGRAMS)
$(foreach exe,$(bin_PROGRAMS),$(eval $(call add-program-rules,$(exe),$(subst .,_,$(subst -,_,$(exe))))))
$(foreach exe,$(noinst_PROGRAMS),$(eval $(call add-program-rules,$(exe),$(subst .,_,$(subst -,_,$(exe))))))

#
# Dependencies
#

depdir = .deps

# Make the object files depend on the deps dir
define depdir-rule
$(1): | $(depdir)/$(dir $(1))
endef
$(foreach obj,$(all-objects),$(eval $(call depdir-rule,$(obj))))

map = $(foreach a,$(2),$(call $(1),$(a)))

# Add a rule for each dep dir
define add-depdir-rule
$(depdir)/$(1):
	@mkdir -p $$@
endef
$(foreach dir,$(sort $(call map,dir,$(all-objects))),$(eval $(call add-depdir-rule,$(dir))))

# Load dependencies
$(foreach obj,$(all-objects),$(eval -include $(depdir)/$(dir $(obj))/$(patsubst %.o,%.Po,$(obj))))

#
# Libtool libs
#

.libs:
	$(if $(V),,@) mkdir .libs

# Add a target for each referenced libtool library which extracts it into a temporary
# dir
define add-extract-rule
.libs/$(2): $(1)
	$(if $(V),,@) $(RM) -r $$@ && mkdir -p $$@ && cd $$@ && ar x $(3)
.libs/$(2): | .libs
endef

$(foreach lib,$(sort $(all-lt-deps)),$(eval $(call add-extract-rule,$(lib),$(notdir $(lib)),$(abspath $(lib)))))

#
# Out-of-tree build support
#

copy-makefiles:

ifneq ($(top_srcdir),$(top_builddir))

define add-makefile-rule

$(1)/Makefile: $(srcdir)/$(1)/Makefile
	mkdir -p $(1) && cp $$< $$@

copy-makefiles: $(1)/Makefile
endef

Makefile: $(srcdir)/Makefile
	cp $< $@

$(foreach dir,$(SUBDIRS),$(eval $(call add-makefile-rule,$(dir))))

endif

#
# Regeneration of Makefiles
#
Makefile: Makefile.am
	cd $(top_builddir) && ./config.status mk

#
# Regeneration of configure
#
ifeq ($(top_builddir),.)

Makefile: $(top_builddir)/config.status

$(top_builddir)/config.status: $(top_srcdir)/configure
	./config.status --recheck

$(top_srcdir)/configure: $(top_srcdir)/configure.in
	cd $(top_srcdir) && autoconf

all: $(top_srcdir)/configure

endif

#
# dist
#

DISTFILES = Makefile $(EXTRA_DIST) $(wildcard *.in)

ifeq ($(top_builddir),.)

DISTFILES += configure.in configure autogen.sh README LICENSE NEWS AUTHORS

distdir = $(PACKAGE)-$(VERSION)

dist: distdir
	tar czf $(distdir).tar.gz $(distdir)

distdir:
	$(RM) -r $(distdir)
	mkdir $(distdir)
	cp $(sort $(DISTFILES)) $(distdir)/
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir distdir top_distdir=../$(distdir) distdir=../$(distdir)/$$dir || exit 1; done

else

distdir:
	mkdir -p $(distdir)
	cp $(sort $(DISTFILES)) $(distdir)/ || for i in $(DISTFILES); do if test ! -d $$i; then cp $$i $(distdir)/ || exit 1; fi; done
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir distdir top_distdir=../$(top_distdir) distdir=../$(distdir)/$$dir || exit 1; done
endif

#
# Other targets
#

all: all-recursive

# FIXME: This is needed just to build generated files early
all: $(BUILT_SOURCES) all-local
	$(MAKE) $(AM_MAKEFLAGS) all-am

all-am:

%-recursive: copy-makefiles
	@for dir in $(SUBDIRS); do $(MAKE) -C $$dir $* || exit 1; done

clean: clean-default clean-local clean-recursive

clean-default:
	$(RM) -r .libs .deps $(all-objects) $(all-static-libs) $(all-shared-libs) $(CLEANFILES)

check: check-local check-recursive

all-local:
clean-local:
dist-local:
check-local:

.PHONY: clean all dist check
.PHONY: all-local clean-local dist-local check-local

