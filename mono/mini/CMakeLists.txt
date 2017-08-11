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
set (METADATA_PLATFORM_SOURCES ${METADATA_WIN32_SOURCES_BASE})
else()
set (METADATA_PLATFORM_SOURCES ${METADATA_UNIX_SOURCES_BASE})
endif ()

set(METADATA_COMMON_SOURCES
	appdomain.c
	domain.c
	appdomain-icalls.h
	assembly.c	
	assembly-internals.h
	attach.h	
	attach.c	
	cil-coff.h	
	class.c		
	class-internals.h
	class-inlines.h	
	class-accessors.c
	cominterop.c	
	cominterop.h	
	console-io.h	
	coree.c 	
	coree.h 	
	coree-internals.h
	culture-info.h  
	culture-info-tables.h
	debug-helpers.c	
	debug-mono-symfile.h
	debug-mono-symfile.c
	debug-mono-ppdb.h
	debug-mono-ppdb.c
	decimal-ms.c	
	decimal-ms.h	
	domain-internals.h
	environment.c	
	environment.h	
	exception.c	
	exception.h	
	exception-internals.h
	w32file.c	
	w32file.h	
	w32file-internals.h
	filewatcher.c	
	filewatcher.h	
	gc-internals.h	
	icall.c		
	icall-internals.h
	icall-def.h	
	image.c		
	image-internals.h
	jit-info.c	
	loader.c	
	locales.c	
	locales.h	
	lock-tracer.c	
	lock-tracer.h	
	marshal.c	
	marshal.h	
	marshal-internals.h
	mempool.c	
	mempool.h	
	mempool-internals.h
	metadata.c	
	metadata-verify.c
	metadata-internals.h
	method-builder.h 
	method-builder.c 
	mono-basic-block.c
	mono-basic-block.h
	mono-config.c	
	mono-debug.h	
	mono-debug.c	
	debug-internals.h
	mono-endian.c	
	mono-endian.h	
	mono-hash.h	
	mono-conc-hash.h	
	mono-mlist.c	
	mono-mlist.h	
	mono-perfcounters.c
	mono-perfcounters.h
	mono-perfcounters-def.h
	mono-ptr-array.h
	mono-route.c	
	mono-route.h	
	monitor.h	
	normalization-tables.h
	number-formatter.h
	number-ms.c	
	number-ms.h	
	object.c
	object-internals.h
	opcodes.c	
	property-bag.h
	property-bag.c
	w32socket.c	
	w32socket.h	
	w32socket-internals.h	
	w32process.c	
	w32process.h	
	w32process-internals.h	
	profiler.c	
	profiler-private.h
	rand.h		
	rand.c		
	remoting.h	
	remoting.c	
	runtime.c	
	mono-security.c	
	security.h	
	security-core-clr.c
	security-core-clr.h
	security-manager.c
	security-manager.h
	string-icalls.c 
	string-icalls.h 
	sysmath.h	
	sysmath.c	
	tabledefs.h 	
	threads.c	
	threads-types.h	
	threadpool.c
	threadpool.h
	threadpool-worker-default.c
	threadpool-worker.h
	threadpool-io.c
	threadpool-io.h
	verify.c	
	verify-internals.h
	wrapper-types.h
	dynamic-image-internals.h
	dynamic-stream.c
	dynamic-stream-internals.h
	reflection-cache.h
	custom-attrs-internals.h
	sre-internals.h
	reflection-internals.h
	file-mmap-posix.c
	file-mmap-windows.c
	file-mmap.h
	object-offsets.h
	abi-details.h
	metadata-cross-helpers.c
	seq-points-data.h
	seq-points-data.c
	handle.c
	handle.h
	w32mutex.h
	w32semaphore.h
	w32event.h
	w32handle-namespace.h
	w32handle-namespace.c
	w32handle.h
	w32handle.c
	w32error.h
	reflection.c
	dynamic-image.c
	sre.c
	sre-encode.c
	sre-save.c
	custom-attrs.c
	fdhandle.h
	fdhandle.c)

addprefix (METADATA_SOURCES ../metadata/ "${METADATA_PLATFORM_SOURCES};${METADATA_COMMON_SOURCES}")

# FIXME: Config

add_library (monosgen ${METADATA_SOURCES})
#add_library(monosgen "main-sgen.c" "${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h")

# FIXME: Use the previous format
string(TIMESTAMP BUILD_DATE)

add_custom_command (
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  COMMAND echo "const char *build_date = \"${BUILD_DATE}\";" > ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  VERBATIM
)
