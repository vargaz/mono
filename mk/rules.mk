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
# Static libs
#

STATIC_LIB_SUFFIX = .a

# $(1) is the library name, $(2) is the prefix used by the automake variables
define add-ltlib-rules

$(1)_OBJECTS := $(patsubst %.s,%.o,$(patsubst %.c,%.o, $(filter-out %.h, $($(2)_SOURCES))))

# Can't define temporary variables inside a define, so have to duplicate a lot of stuff

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

endef

$(foreach lib,$(noinst_LTLIBRARIES),$(eval $(call add-ltlib-rules,$(patsubst %.la,%,$(lib)),$(subst .,_,$(subst -,_,$(lib))))))
$(foreach lib,$(lib_LTLIBRARIES),$(eval $(call add-ltlib-rules,$(patsubst %.la,%,$(lib)),$(subst .,_,$(subst -,_,$(lib))))))

#
# Executables
#

define add-program-rules

$(1)_OBJECTS := $(patsubst %.c,%.o, $(filter-out %.h, $($(1)_SOURCES)))

$(1)_REAL_LDADD := $(patsubst %.lo,%.o, $(patsubst %.la,%$(STATIC_LIB_SUFFIX),$($(1)_LDADD)))

all-objects += $$($(1)_OBJECTS)

all-am: $(1)

$(1): $$($(1)_OBJECTS)
	$(if $(V),,@echo -e "LD\\t$$@";) $(CC) -o $$@ $$($(1)_OBJECTS) $($(1)_LDFLAGS) $$($(1)_REAL_LDADD) $(LIBS)
endef

$(foreach exe,$(bin_PROGRAMS),$(eval $(call add-program-rules,$(exe))))
$(foreach exe,$(noinst_PROGRAMS),$(eval $(call add-program-rules,$(exe))))

#
# Compilation
#

DEFAULT_INCLUDES=-I. -I$(top_builddir)
CFLAGS += $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CFLAGS) -DHAVE_CONFIG_H

%.o: $(srcdir)/%.c
	$(if $(V),,@echo -e "CC\\t$@";) $(CC) -c $(CPPFLAGS) $(CFLAGS) -o $@ $< -MD -MP -MF .deps/$(patsubst %.o,%.Po,$@)

%.o: %.s
	$(if $(V),,@echo -e "AS\\t$@";) $(AS) $(ASFLAGS) -o $@ $<

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

