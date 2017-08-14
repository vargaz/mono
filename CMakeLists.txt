cmake_minimum_required (VERSION 3.6)

project (mono)

include(GNUInstallDirs)

find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()

# Get rid of the annoying 'has no symbols' messages from ar/ranlib on osx
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
SET(CMAKE_C_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <OBJECTS>")
SET(CMAKE_C_ARCHIVE_FINISH   "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
SET(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <OBJECTS>")
SET(CMAKE_CXX_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
endif ()

add_subdirectory (mono)
