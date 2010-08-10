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
# to understand it.
# We can't define temporary variables inside a define, so have to duplicate a lot of stuff.
#

#
# Compilation
#

DEFAULT_INCLUDES=-I. -I$(top_builddir)
CFLAGS += $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CFLAGS) -DHAVE_CONFIG_H

%.o: $(srcdir)/%.c
	$(if $(V),,@echo -e "CC\\t$@";) $(CC) -c $(CPPFLAGS) $(CFLAGS) -o $@ $< -MD -MP -MF .deps/$(patsubst %.o,%.Po,$@)

%.o: %.s
	$(if $(V),,@echo -e "AS\\t$@";) $(AS) $(ASFLAGS) -o $@ $<

# A macro for adding custom C compilation rules
define add-cc-comp-rule
# $(1) is the name of the target
# $(2) is the name of the source
# $(3) is the name of the CFLAGS var to use
$(1): $(2)
	$(if $(V),,@echo -e "CC\\t$$@";) $$(CC) -c $$(CPPFLAGS) $$(CFLAGS) $$($(3)) -o $$@ $$< -MD -MP -MF .deps/$$(patsubst %.o,%.Po,$$@)
endef # add-cc-comp-rule

#
# Static libs
#

STATIC_LIB_SUFFIX = .a

define add-ltlib-rules
# $(1) is the library name, $(2) is the prefix used by the automake variables

$(1)_OBJECTS := $(patsubst %.s,%.o,$(patsubst %.c,$(2)-%.o, $(filter-out %.h, $($(2)_SOURCES))))
$(eval $(call add-cc-comp-rule,$(2)-%.o,$(srcdir)/%.c,$(2)_CFLAGS))

# Collect dependend libraries
all-lt-deps += $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$(filter %.la,$($(2)_LIBADD)))
all-lt-deps += $(patsubst %.a,%$(STATIC_LIB_SUFFIX),$(filter %.a,$($(2)_LIBADD)))

# Temporary directories holding the extracted dependent libraries
$(1)_LT_DIRS := $(patsubst %,.libs/%,$(notdir $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$(filter %.la,$($(2)_LIBADD)))))
$(1)_LT_DIRS_2 := $(patsubst %,.libs/%,$(notdir $(patsubst %.a,%$(STATIC_LIB_SUFFIX),$(filter %.a,$($(2)_LIBADD)))))

# Contents of dependent libraries
$(1)_LT_FILES := $(patsubst %,.libs/%/*.o,$(notdir $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$(filter %.la,$($(2)_LIBADD)))))
$(1)_LT_FILES_2 := $(patsubst %,.libs/%/*.o,$(notdir $(patsubst %.a,%$(STATIC_LIB_SUFFIX),$(filter %.a,$($(2)_LIBADD)))))

all-objects += $$($(1)_OBJECTS)

all-static-libs += $(1)$(STATIC_LIB_SUFFIX)

all-am: $(1)

.PHONY: $(1)

$(1): $(1)$(STATIC_LIB_SUFFIX)

$(1)$(STATIC_LIB_SUFFIX): $$($(1)_OBJECTS) $$($(1)_LT_DIRS) $$($(1)_LT_DIRS_2)
	$(if $(V),,@echo -e "LD\\t$$@";) $(RM) $$@ && $(AR) qc $$@ $$($(1)_OBJECTS) $$($(1)_LT_FILES) $$($(1)_LT_FILES_2)
endef # add-ltlib-rules

# Add rules for each library
$(foreach lib,$(noinst_LTLIBRARIES) $(lib_LTLIBRARIES),$(eval $(call add-ltlib-rules,$(patsubst %.la,%,$(lib)),$(subst .,_,$(subst -,_,$(lib))))))
$(foreach lib,$(noinst_LIBRARIES),$(eval $(call add-ltlib-rules,$(patsubst %.a,%,$(lib)),$(subst .,_,$(subst -,_,$(lib))))))

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

$(1)_REAL_LDADD := $(patsubst %.lo,%.o, $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$($(2)_LDADD)))

# Collect dependend libraries
$(1)_LIB_DEPS := $(patsubst %.a,%$(STATIC_LIB_SUFFIX),$(filter %.a,$($(2)_LDADD)))

all-objects += $$($(1)_OBJECTS)

all-am: $(1)

# The rule linking the executable
$(1): $$($(1)_OBJECTS) $$($(1)_LIB_DEPS)
	$(if $(V),,@echo -e "LD\\t$$@";) $(CC) -o $$@ $$($(1)_OBJECTS) $($(2)_LDFLAGS) $$($(1)_REAL_LDADD) $(LIBS)
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
	$(RM) -r .libs .deps $(all-objects) $(all-static-libs) $(CLEANFILES)

check: check-local check-recursive

all-local:
clean-local:
dist-local:
check-local:

.PHONY: clean all dist check
.PHONY: all-local clean-local dist-local check-local

