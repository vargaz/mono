project (mini)

# FIXME:
set (AMD64 ON)

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

#
# METADATA/
#

set (metadata_win32_sources
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

set (metadata_unix_sources
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
set (metadata_platform_sources ${metadata_win32_sources})
else()
set (metadata_platform_sources ${metadata_unix_sources})
endif ()

set(metadata_common_sources
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

set (metadata_gc_dependent_sources
	gc-stats.c
	gc.c
	monitor.c
	mono-hash.c
	mono-conc-hash.c)

set (metadata_sgen_sources
	sgen-bridge.c
	sgen-bridge.h
	sgen-bridge-internals.h
	sgen-old-bridge.c
	sgen-new-bridge.c
	sgen-tarjan-bridge.c
	sgen-toggleref.c
	sgen-toggleref.h
	sgen-stw.c
	sgen-mono.c
	sgen-client-mono.h)

# FIXME: Config

addprefix (metadata_sources ../metadata/ "${metadata_platform_sources};${metadata_common_sources};${metadata_gc_dependent_sources};${metadata_sgen_sources}")

#
# UTILS/
#
set (utils_win32_sources
	os-event-win32.c)
set (utils_unix_sources
	os-event-unix.c)

if (HOST_WIN32)
set (utils_platform_sources ${utils_win32_sources})
else()
set (utils_platform_sources ${utils_unix_sources})
endif ()

set (utils_common_sources
	mono-md5.c
	mono-sha1.c
	mono-logger.c
	mono-logger-internals.h
	mono-codeman.c
	dlmalloc.h
	dlmalloc.c
	mono-counters.c
	mono-compiler.h
	mono-complex.h
	mono-dl.c
	mono-dl-windows.c
	mono-dl-darwin.c
	mono-dl-posix.c
	mono-dl.h
	mono-dl-windows-internals.h
	mono-log-windows.c
	mono-log-common.c
	mono-log-posix.c
	mono-log-android.c
	mono-log-darwin.c
	mono-internal-hash.c
	mono-internal-hash.h
	mono-io-portability.c
	mono-io-portability.h
	monobitset.c
	mono-filemap.c
	mono-math.c
	mono-mmap.c
	mono-mmap-windows.c
	mono-mmap.h
	mono-mmap-internals.h
	mono-mmap-windows-internals.h
	mono-os-mutex.h
	mono-os-mutex.c
	mono-coop-mutex.h
	mono-once.h
	mono-lazy-init.h
	mono-networkinterfaces.c
	mono-networkinterfaces.h
	mono-proclib.c
	mono-proclib-windows.c
	mono-proclib.h
	mono-proclib-windows-internals.h
	mono-publib.c
	mono-string.h
	mono-time.c
	mono-time.h
	strenc.h
	strenc.c
	mono-uri.c
	mono-poll.c
	mono-path.c
	mono-os-semaphore.h
	mono-coop-semaphore.h
	mono-sigcontext.h
	mono-stdlib.c
	mono-property-hash.h
	mono-property-hash.c
	mono-value-hash.h
	mono-value-hash.c
	freebsd-elf_common.h
	freebsd-elf32.h
	freebsd-elf64.h
	freebsd-dwarf.h
	dtrace.h
	gc_wrapper.h
	mono-error.c
	mono-error-internals.h
	monobitset.h
	mono-codeman.h
	mono-counters.h
	mono-digest.h
	mono-error.h
	mono-machine.h
	mono-math.h
	mono-membar.h
	mono-path.h
	mono-poll.h
	mono-uri.h
	mono-stdlib.h
	valgrind.h
	mach-support.c
	mach-support.h
	memcheck.h
	mono-context.c
	mono-context.h
	mono-stack-unwinding.h
	hazard-pointer.c
	hazard-pointer.h
	lock-free-queue.c
	lock-free-queue.h
	lock-free-alloc.c
	lock-free-alloc.h
	lock-free-array-queue.c
	lock-free-array-queue.h
	mono-linked-list-set.c
	mono-linked-list-set.h
	mono-threads.c
	mono-threads-state-machine.c
	mono-threads-posix.c
	mono-threads-posix-signals.c
	mono-threads-mach.c
	mono-threads-mach-helper.c
	mono-threads-windows.c
	mono-threads-linux.c
	mono-threads-freebsd.c
	mono-threads-netbsd.c
	mono-threads-openbsd.c
	mono-threads-android.c
	mono-threads-haiku.c
	mono-threads.h
	mono-threads-debug.h
	mono-threads-api.h
	mono-threads-coop.c
	mono-threads-coop.h
	mono-tls.h
	mono-tls.c
	linux_magic.h
	mono-memory-model.h
	atomic.h
	atomic.c
	mono-hwcap.h
	mono-hwcap.c
	mono-hwcap-vars.h
	bsearch.h
	bsearch.c
	mono-signal-handler.h
	mono-conc-hashtable.h
	mono-conc-hashtable.c
	json.h
	json.c
	networking.c
	networking-posix.c
	networking-fallback.c
	networking-missing.c
	networking-windows.c
	networking.h
	mono-rand.c
	mono-rand-windows.c
	mono-rand.h
	mono-rand-windows-internals.h
	memfuncs.c
	memfuncs.h
	parse.c
	parse.h
	checked-build.c
	checked-build.h
	os-event.h
	refcount.h
	w32api.h)

if (AMD64)
set (utils_arch_sources
	mach-support-amd64.c)
else()
message (FATAL_ERROR "")
endif()

if (CROSS_COMPILE)
set (utils_arch_sources "${utils_arch_sources};mono-hwcap-cross.c")
elseif (AMD64)
set (utils_arch_sources "${utils_arch_sources};mono-hwcap-x86.c")
else()
message (FATAL_ERROR "")
endif()

addprefix (utils_sources ../utils/ "${utils_platform_sources};${utils_arch_sources};${utils_common_sources}")

#
# MINI/
#

add_library (monosgen "${metadata_sources};${utils_sources}")
#add_library(monosgen "main-sgen.c" "${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h")

# FIXME: Use the previous format
string(TIMESTAMP BUILD_DATE)

add_custom_command (
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  COMMAND echo "const char *build_date = \"${BUILD_DATE}\";" > ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  VERBATIM
)
