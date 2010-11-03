thisdir = class/System.Data.Services
SUBDIRS = 
include ../../build/rules.make

DEP_LIBS = System System.Core System.ServiceModel System.ServiceModel.Web

LIBRARY = System.Data.Services.dll

LIB_MCS_FLAGS = \
	-d:NET_3_5	\
	-r:System.dll \
	-r:System.Core.dll \
	-r:System.ServiceModel.dll \
	-r:System.ServiceModel.Web.dll \

include ../../build/library.make
