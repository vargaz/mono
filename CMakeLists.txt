cmake_minimum_required (VERSION 3.6)

project (mono)

set (WARNING_CFLAGS "-Wall -Wunused -Wmissing-prototypes -Wmissing-declarations -Wstrict-prototypes  -Wmissing-prototypes -Wnested-externs -Wpointer-arith -Wno-cast-qual -Wwrite-strings -Wno-switch -Wno-switch-enum -Wno-unused-value -Wno-attributes -Wno-format-zero-length -Qunused-arguments -Wno-unused-function -Wno-tautological-compare -Wno-parentheses-equality -Wno-self-assign -Wno-return-stack-address -Wno-constant-logical-operand -Wno-zero-length-array -Werror-implicit-function-declaration")

set (CMAKE_C_FLAGS " -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -DHAVE_CONFIG_H -std=gnu99 -fno-strict-aliasing -fwrapv -DMONO_DLL_EXPORT -g ${WARNING_CFLAGS}")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DPLATFORM_MACOSX")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DHAVE_SGEN_GC")

add_subdirectory (mono)
