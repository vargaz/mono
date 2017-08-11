project (mini)

include_directories(
	${PROJECT_BINARY_DIR}/../..
	${PROJECT_SOURCE_DIR}/../
	${PROJECT_SOURCE_DIR}/../eglib)

set (WIN32_SOURCES ../metadata/console-win32.c
	../metadata/console-win32-internals.h
	../metadata/cominterop-win32-internals.h
	../metadata/w32file-win32.c
	../metadata/w32file-win32-internals.h
	../metadata/icall-windows.c
	../metadata/icall-windows-internals.h
	../metadata/marshal-windows.c
	../metadata/marshal-windows-internals.h
	../metadata/mono-security-windows.c
	../metadata/mono-security-windows-internals.h
	../metadata/w32mutex-win32.c
	../metadata/w32semaphore-win32.c
	../metadata/w32event-win32.c
	../metadata/w32process-win32.c
	../metadata/w32process-win32-internals.h
	../metadata/w32socket-win32.c
	../metadata/w32error-win32.c)

set (UNIX_SOURCES
	../metadata/console-unix.c
	../metadata/w32mutex-unix.c
	../metadata/w32semaphore-unix.c
	../metadata/w32event-unix.c
	../metadata/w32process-unix.c
	../metadata/w32process-unix-internals.h
	../metadata/w32process-unix-osx.c
	../metadata/w32process-unix-bsd.c
	../metadata/w32process-unix-haiku.c
	../metadata/w32process-unix-default.c
	../metadata/w32socket-unix.c
	../metadata/w32file-unix.c
	../metadata/w32file-unix-glob.c
	../metadata/w32file-unix-glob.h
	../metadata/w32error-unix.c)

if (HOST_WIN32)
set (PLATFORM_SOURCES ${WIN32_SOURCES})
else()
set (PLATFORM_SOURCES ${UNIX_SOURCES})
endif ()

add_library (monosgen ${PLATFORM_SOURCES})
#add_library(monosgen "main-sgen.c" "${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h")

# FIXME: Use the previous format
string(TIMESTAMP BUILD_DATE)

add_custom_command (
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  COMMAND echo "const char *build_date = \"${BUILD_DATE}\";" > ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  VERBATIM
)
