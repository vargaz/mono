thisdir = class/Mono.Http
SUBDIRS = 
include ../../build/rules.make

DEP_LIBS = System System.XML System.Web ICSharpCode.SharpZipLib Mono.Security

LIBRARY = Mono.Http.dll
LIB_MCS_FLAGS = -r:$(corlib) \
		-r:System.dll \
		-r:System.Xml.dll \
		-r:System.Web.dll \
		-r:ICSharpCode.SharpZipLib.dll \
		-r:Mono.Security.dll

NO_TEST = yes

include ../../build/library.make
