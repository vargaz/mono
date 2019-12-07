#
# Configure checks
#

include(CheckTypeSize)
include(CheckStructHasMember)
include(TestBigEndian)

if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  set(DARWIN 1)
endif()

function(ac_check_headers)
  foreach(arg ${ARGN})
	check_include_file ("${arg}" FOUND_${arg})
	string(TOUPPER "${arg}" var1)
	string(REPLACE "/" "_" var2 ${var1})
	string(REPLACE "." "_" var3 ${var2})
	if (FOUND_${arg})
	  set(HAVE_${var3} 1 PARENT_SCOPE)
	endif()
  endforeach(arg)
endfunction()

function(ac_check_funcs)
  foreach(arg ${ARGN})
	check_function_exists ("${arg}" FOUND_${arg})
	string(TOUPPER "${arg}" var1)
	string(REPLACE "/" "_" var2 ${var1})
	string(REPLACE "." "_" var3 ${var2})
	if (FOUND_${arg})
	  set(HAVE_${var3} 1 PARENT_SCOPE)
	endif()
  endforeach(arg)
endfunction()

ac_check_headers (sys/mkdev.h sys/types.h sys/stat.h sys/filio.h sys/sockio.h sys/utime.h sys/un.h sys/syscall.h sys/uio.h sys/param.h sys/sysctl.h)
ac_check_headers (sys/prctl.h sys/socket.h sys/utsname.h sys/select.h sys/inotify.h sys/user.h sys/poll.h sys/wait.h sts/auxv.h sys/resource.h)
ac_check_headers (sys/event.h sys/ioctl.h sys/errno.h sys/sendfile.h sys/statvfs.h sys/statfs.h sys/mman.h sys/mount.h sys/time.h)
ac_check_headers (memory.h strings.h stdint.h unistd.h netdb.h utime.h semaphore.h libproc.h alloca.h ucontext.h pwd.h)

ac_check_headers (gnu/lib-names.h
				 netinet/tcp.h
				 netinet/in.h
				 link.h
				 arpa/inet.h
				 unwind.h
				 poll.h
				 grp.h
				 wchar.h
				 linux/magic.h
				 android/legacy_signal_inlines.h
				 android/ndk-version.h
				 execinfo.h
				 pthread.h
				 pthread_np.h
				 net/if.h
				 dirent.h
				 CommonCrypto/CommonDigest.h
				 curses.h
				 term.h
				 termios.h
				 dlfcn.h
				 /usr/include/malloc.h
				 getopt.h
				 pwd.h
				 iconv.h
				 alloca.h)

check_function_exists (sigaction kill clock_nanosleep getgrgid_r getgrnam_r getresuid setresuid kqueue backtrace_symbols mkstemp mmap)
check_function_exists (madvise getrusage getpriority setpriority dladdr sysconf getrlimit prctl nl_langinfo)
check_function_exists (sched_getaffinity sched_setaffinity getpwnam_r getpwuid_r readlink chmod lstat getdtablesize ftruncate msync)
check_function_exists (gethostname getpeername utime utimes openlog closelog atexit popen strerror_r inet_pton inet_aton)
check_function_exists (pthread_getname_np
  pthread_setname_np
  pthread_cond_timedwait_relative_np
  pthread_kill
  pthread_attr_setstacksize
  pthread_get_stackaddr_np
  shm_open
  poll
  getfsstat
  mremap
  posix_fadvise
  vsnprintf
  sendfile
  statfs
  statvfs
  setpgid
  system
  fork
  execv
  execve
  waitpid
  localtime_r
  mkdtemp
  getrandom
  execvp
  strlcpy
  stpcpy
  strtok_r
  rewinddir
  vasprintf
  strndup
  getpwuid_r
  getprotobyname
  getprotobyname_r
  getaddrinfo)

if (NOT DARWIN)
  ac_check_headers (sys/random.h)
  ac_check_funcs (getentropy)
endif()

check_struct_has_member("struct kinfo_proc" kp_proc "sys/types.h;sys/param.h;sys/sysctl.h;sys/proc.h" HAVE_STRUCT_KINFO_PROC_KP_PROC)

check_type_size("void*" SIZEOF_VOID_P)
check_type_size("long" SIZEOF_LONG)
check_type_size("long long" SIZEOF_LONG_LONG)

TEST_BIG_ENDIAN (IS_BIG_ENDIAN)

# FIXME:
set(TARGET_SIZEOF_VOID_P "${SIZEOF_VOID_P}")
set(SIZEOF_REGISTER "${SIZEOF_VOID_P}")

if (IS_BIG_ENDIAN)
  set(TARGET_BYTE_ORDER G_BIG_ENDIAN)
else()
  set(TARGET_BYTE_ORDER G_LITTLE_ENDIAN)
endif()
