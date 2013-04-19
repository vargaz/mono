thisdir = tools/ikdasm
SUBDIRS =
include ../../build/rules.make

PROGRAM = ikdasm.exe

IKVM_REFLECT_DIR=../../../external/ikvm/reflect

LOCAL_MCS_FLAGS = \
	/r:System.Security.dll	\
	/define:NO_SYMBOL_WRITER \
	$(IKVM_REFLECT_DIR)/*.cs \
	$(IKVM_REFLECT_DIR)/Emit/*.cs \
	$(IKVM_REFLECT_DIR)/Metadata/*.cs \
	$(IKVM_REFLECT_DIR)/Reader/*.cs \
	$(IKVM_REFLECT_DIR)/Writer/*.cs \
	$(IKVM_REFLECT_DIR)/Impl/ITypeOwner.cs \
	$(IKVM_REFLECT_DIR)/Impl/SymbolSupport.cs

include ../../build/executable.make
