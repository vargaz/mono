thisdir = class/ICSharpCode.SharpZipLib
SUBDIRS = 
include ../../build/rules.make

DEP_LIBS = System System.XML

LIBRARY = ICSharpCode.SharpZipLib.dll
LIBRARY_SNK = SharpZipLib.key

LIB_MCS_FLAGS = /r:$(corlib) /r:System.dll /r:System.Xml.dll
NO_TEST = yes
EXTRA_DISTFILES = SharpZipLib.pub $(LIBRARY_SNK)

include ../../build/library.make
