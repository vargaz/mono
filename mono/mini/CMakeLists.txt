project (mini)

function (addprefix var prefix list)
    foreach (i ${list})
        set (f ${f} ${prefix}/${i})
    endforeach ()
    set (${var} ${f} PARENT_SCOPE)
endfunction()

include_directories(
	${PROJECT_BINARY_DIR}/../..
	${PROJECT_SOURCE_DIR}/../
	${PROJECT_SOURCE_DIR}/../eglib)

set (METADATA_WIN32_SOURCES_BASE
	console-win32.c
	console-win32-internals.h
	cominterop-win32-internals.h
	w32file-win32.c
	w32file-win32-internals.h
	icall-windows.c
	icall-windows-internals.h
	marshal-windows.c
	marshal-windows-internals.h
	mono-security-windows.c
	mono-security-windows-internals.h
	w32mutex-win32.c
	w32semaphore-win32.c
	w32event-win32.c
	w32process-win32.c
	w32process-win32-internals.h
	w32socket-win32.c
	w32error-win32.c)

set (METADATA_UNIX_SOURCES_BASE
	console-unix.c
	w32mutex-unix.c
	w32semaphore-unix.c
	w32event-unix.c
	w32process-unix.c
	w32process-unix-internals.h
	w32process-unix-osx.c
	w32process-unix-bsd.c
	w32process-unix-haiku.c
	w32process-unix-default.c
	w32socket-unix.c
	w32file-unix.c
	w32file-unix-glob.c
	w32file-unix-glob.h
	w32error-unix.c)

if (HOST_WIN32)
set (METADATA_PLATFORM_SOURCES_BASE ${METADATA_WIN32_SOURCES_BASE})
else()
set (METADATA_PLATFORM_SOURCES_BASE ${METADATA_UNIX_SOURCES_BASE})
endif ()

addprefix (METADATA_PLATFORM_SOURCES ../metadata/ "${METADATA_PLATFORM_SOURCES_BASE}")

# FIXME: Config

add_library (monosgen ${METADATA_PLATFORM_SOURCES})
#add_library(monosgen "main-sgen.c" "${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h")

# FIXME: Use the previous format
string(TIMESTAMP BUILD_DATE)

add_custom_command (
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  COMMAND echo "const char *build_date = \"${BUILD_DATE}\";" > ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  VERBATIM
)
