thisdir = class/System.Web.Extensions.Design
SUBDIRS = 
include ../../build/rules.make

DEP_LIBS = System System.Design

LIBRARY = System.Web.Extensions.Design.dll

LIB_MCS_FLAGS = \
	-define:NET_3_5			\
	-r:System.dll			\
	-r:System.Design.dll		\
	$(OTHER_LIB_MCS_FLAGS)

include ../../build/library.make

