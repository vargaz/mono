thisdir = class/System.Transactions
SUBDIRS = 
include ../../build/rules.make

LIBRARY = System.Transactions.dll
ifdef MOBILE_PROFILE
LIB_REFS = System
KEYFILE = ../ecma.pub
LIB_MCS_FLAGS = /define:MOBILE
else
LIB_REFS = System System.Configuration
KEYFILE = ../ecma.pub
LIB_MCS_FLAGS =
endif

TEST_MCS_FLAGS = $(LIB_MCS_FLAGS)

include ../../build/library.make
