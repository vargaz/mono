#
# Configure checks
#

include(CheckTypeSize)
include(CheckStructHasMember)
include(TestBigEndian)

if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  set(DARWIN 1)
endif()

check_include_file ("sys/mkdev.h" HAVE_SYS_MKDEV_H)
check_include_file ("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file ("sys/stat.h" HAVE_SYS_STAT_H)
check_include_file ("memory.h" HAVE_MEMORY_H)
check_include_file ("strings.h" HAVE_STRINGS_H)
check_include_file ("stdint.h" HAVE_STDINT_H)
check_include_file ("unistd.h" HAVE_UNISTD_H)
check_include_file ("sys/filio.h" HAVE_SYS_FILIO_H)
check_include_file ("sys/sockio.h" HAVE_SYS_SOCKIO_H)
check_include_file ("netdb.h" HAVE_NETDB_H)
check_include_file ("utime.h" HAVE_UTIME_H)
check_include_file ("sys/utime.h" HAVE_SYS_UTIME_H)
check_include_file ("semaphore.h" HAVE_SEMAPHORE_H)
check_include_file ("sys/un.h" HAVE_SYS_UN_H)
check_include_file ("sys/syscall.h" HAVE_SYS_SYSCALL_H)
check_include_file ("sys/mkdev.h" HAVE_SYS_MKDEV_H)
check_include_file ("sys/uio.h" HAVE_SYS_UIO_H)
check_include_file ("sys/param.h" HAVE_SYS_PARAM_H)
check_include_file ("sys/sysctl.h" HAVE_SYS_SYSCTL_H)
check_include_file ("libproc.h" HAVE_LIBPROC_H)
check_include_file ("sys/prctl.h" HAVE_SYS_PRCTL_H)
check_include_file ("gnu/lib-names.h" HAVE_GNU_LIB_NAMES_H)
check_include_file ("sys/param.h" HAVE_SYS_PARAM_H)
check_include_file ("sys/socket.h" HAVE_SYS_SOCKET_H)
check_include_file ("sys/utsname.h" HAVE_SYS_UTSNAME_H)
check_include_file ("alloca.h" HAVE_ALLOCA_H)
check_include_file ("ucontext.h" HAVE_UCONTEXT_H)
check_include_file ("pwd.h" HAVE_PWD_H)
check_include_file ("sys/select.h" HAVE_SYS_SELECT_H)
check_include_file ("netinet/tcp.h" HAVE_NETINET_TCP_H)
check_include_file ("netinet/in.h" HAVE_NETINET_IN_H)
check_include_file ("unistd.h" HAVE_UNISTD_H)
check_include_file ("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file ("link.h" HAVE_LINK_H)
check_include_file ("sys/inotify.h" HAVE_SYS_INOTIFY_H)
check_include_file ("arpa/inet.h" HAVE_ARPA_INET_H)
check_include_file ("unwind.h" HAVE_UNWIND_H)
check_include_file ("unistd.h" HAVE_UNISTD_H)
check_include_file ("sys/user.h" HAVE_SYS_USER_H)
check_include_file ("poll.h" HAVE_POLL_H)
check_include_file ("sys/poll.h" HAVE_SYS_POLL_H)
check_include_file ("sys/wait.h" HAVE_SYS_WAIT_H)
check_include_file ("grp.h" HAVE_GRP_H)
check_include_file ("wchar.h" HAVE_WCHAR_H)
check_include_file ("linux/magic.h" HAVE_LINUX_MAGIC_H)
check_include_file ("android/legacy_signal_inlines.h" HAVE_ANDROID_LEGACY_SIGNAL_INLINES_H)
check_include_file ("android/ndk-version.h" HAVE_ANDROID_NDK_VERSION_H)
check_include_file ("execinfo.h" HAVE_EXECINFO_H)
check_include_file ("sys/auxv.h" HAVE_SYS_AUXV_H)
check_include_file ("sys/resource.h" HAVE_SYS_RESOURCE_H)
check_include_file ("pthread.h" HAVE_PTHREAD_H)
check_include_file ("pthread_np.h" HAVE_PTHREAD_NP_H)
check_include_file ("sys/event.h" HAVE_SYS_EVENT_H)
check_include_file ("sys/ioctl.h" HAVE_SYS_IOCTL_H)
check_include_file ("net/if.h" HAVE_NET_IF_H)
check_include_file ("sys/errno.h" HAVE_SYS_ERRNO_H)
check_include_file ("sys/sendfile.h" HAVE_SYS_SENDFILE_H)
check_include_file ("sys/statvfs.h" HAVE_SYS_STATVFS_H)
check_include_file ("sys/statfs.h" HAVE_SYS_STATFS_H)
check_include_file ("sys/mman.h" HAVE_SYS_MMAN_H)
check_include_file ("sys/param.h" HAVE_SYS_PARAM_H)
check_include_file ("sys/mount.h" HAVE_SYS_MOUNT_H)
check_include_file ("sys/time.h" HAVE_SYS_TIME_H)
check_include_file ("dirent.h" HAVE_DIRENT_H)
check_include_file ("CommonCrypto/CommonDigest.h" HAVE_COMMONCRYPTO_COMMONDIGEST_H)
check_include_file ("curses.h" HAVE_CURSES_H)
check_include_file ("term.h" HAVE_TERM_H)
check_include_file ("termios.h" HAVE_TERMIOS_H)
check_include_file ("dlfcn.h" HAVE_DLFCN_H)
check_include_file ("/usr/include/malloc.h" HAVE_USR_INCLUDE_MALLOC_H)

if (NOT DARWIN)
  check_include_file ("sys/random.h" HAVE_SYS_RANDOM_H)
  check_function_exists ("getentropy" HAVE_GETENTROPY)
endif()

check_include_file ("sys/sysctl.h" HAVE_SYS_SYSCTL_H)
check_include_file ("getopt.h" HAVE_GETOPT_H)
check_include_file ("sys/select.h" HAVE_SYS_SELECT_H)
check_include_file ("sys/time.h" HAVE_SYS_TIME_H)
check_include_file ("sys/wait.h" HAVE_SYS_WAIT_H)
check_include_file ("pwd.h" HAVE_PWD_H)
check_include_file ("iconv.h" HAVE_ICONV_H)
check_include_file ("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file ("sys/resource.h" HAVE_SYS_RESOURCE_H)
check_include_file ("alloca.h" HAVE_ALLOCA_H)
check_function_exists ("sigaction" HAVE_SIGACTION)
check_function_exists ("kill" HAVE_KILL)
check_function_exists ("clock_nanosleep" HAVE_CLOCK_NANOSLEEP)
check_function_exists ("getgrgid_r" HAVE_GETGRGID_R)
check_function_exists ("getgrnam_r" HAVE_GETGRNAM_R)
check_function_exists ("getresuid" HAVE_GETRESUID)
check_function_exists ("setresuid" HAVE_SETRESUID)
check_function_exists ("kqueue" HAVE_KQUEUE)
check_function_exists ("backtrace_symbols" HAVE_BACKTRACE_SYMBOLS)
check_function_exists ("mkstemp" HAVE_MKSTEMP)
check_function_exists ("mmap" HAVE_MMAP)
check_function_exists ("madvise" HAVE_MADVISE)
check_function_exists ("getrusage" HAVE_GETRUSAGE)
check_function_exists ("getpriority" HAVE_GETPRIORITY)
check_function_exists ("setpriority" HAVE_SETPRIORITY)
check_function_exists ("dladdr" HAVE_DLADDR)
check_function_exists ("sysconf" HAVE_SYSCONF)
check_function_exists ("getrlimit" HAVE_GETRLIMIT)
check_function_exists ("prctl" HAVE_PRCTL)
check_function_exists ("nl_langinfo" HAVE_NL_LANGINFO)
check_function_exists ("sched_getaffinity" HAVE_SCHED_GETAFFINITY)
check_function_exists ("sched_setaffinity" HAVE_SCHED_SETAFFINITY)
check_function_exists ("getpwnam_r" HAVE_GETPWNAM_R)
check_function_exists ("getpwuid_r" HAVE_GETPWUID_R)
check_function_exists ("readlink" HAVE_READLINK)
check_function_exists ("chmod" HAVE_CHMOD)
check_function_exists ("lstat" HAVE_LSTAT)
check_function_exists ("getdtablesize" HAVE_GETDTABLESIZE)
check_function_exists ("ftruncate" HAVE_FTRUNCATE)
check_function_exists ("msync" HAVE_MSYNC)
check_function_exists ("gethostname" HAVE_GETHOSTNAME)
check_function_exists ("getpeername" HAVE_GETPEERNAME)
check_function_exists ("utime" HAVE_UTIME)
check_function_exists ("utimes" HAVE_UTIMES)
check_function_exists ("openlog" HAVE_OPENLOG)
check_function_exists ("closelog" HAVE_CLOSELOG)
check_function_exists ("atexit" HAVE_ATEXIT)
check_function_exists ("popen" HAVE_POPEN)
check_function_exists ("strerror_r" HAVE_STRERROR_R)
check_function_exists ("inet_pton" HAVE_INET_PTON)
check_function_exists ("inet_aton" HAVE_INET_ATON)
check_function_exists ("pthread_getname_np" HAVE_PTHREAD_GETNAME_NP)
check_function_exists ("pthread_setname_np" HAVE_PTHREAD_SETNAME_NP)
check_function_exists ("pthread_cond_timedwait_relative_np" HAVE_PTHREAD_COND_TIMEDWAIT_RELATIVE_NP)
check_function_exists ("pthread_kill" HAVE_PTHREAD_KILL)
check_function_exists ("pthread_attr_setstacksize" HAVE_PTHREAD_ATTR_SETSTACKSIZE)
check_function_exists ("pthread_get_stackaddr_np" HAVE_PTHREAD_GET_STACKADDR_NP)
check_function_exists ("shm_open" HAVE_SHM_OPEN)
check_function_exists ("poll" HAVE_POLL)
check_function_exists ("getfsstat" HAVE_GETFSSTAT)
check_function_exists ("mremap" HAVE_MREMAP)
check_function_exists ("posix_fadvise" HAVE_POSIX_FADVISE)
check_function_exists ("vsnprintf" HAVE_VSNPRINTF)
check_function_exists ("sendfile" HAVE_SENDFILE)
check_function_exists ("statfs" HAVE_STATFS)
check_function_exists ("statvfs" HAVE_STATVFS)
check_function_exists ("setpgid" HAVE_SETPGID)
check_function_exists ("system" HAVE_SYSTEM)
check_function_exists ("fork" HAVE_FORK)
check_function_exists ("execv" HAVE_EXECV)
check_function_exists ("execve" HAVE_EXECVE)
check_function_exists ("waitpid" HAVE_WAITPID)
check_function_exists ("localtime_r" HAVE_LOCALTIME_R)
check_function_exists ("mkdtemp" HAVE_MKDTEMP)
check_function_exists ("getrandom" HAVE_GETRANDOM)
check_function_exists ("execvp" HAVE_EXECVP)
check_function_exists ("strlcpy" HAVE_STRLCPY)
check_function_exists ("stpcpy" HAVE_STPCPY)
check_function_exists ("strtok_r" HAVE_STRTOK_R)
check_function_exists ("rewinddir" HAVE_REWINDDIR)
check_function_exists ("vasprintf" HAVE_VASPRINTF)
check_function_exists ("strndup" HAVE_STRNDUP)
check_function_exists ("getpwuid_r" HAVE_GETPWUID_R)
check_function_exists ("getprotobyname" HAVE_GETPROTOBYNAME)
check_function_exists ("getprotobyname_r" HAVE_GETPROTOBYNAME_R)
check_function_exists ("getaddrinfo" HAVE_GETADDRINFO)

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
