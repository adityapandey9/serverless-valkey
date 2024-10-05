#ifndef WASI_COMPAT_H
#define WASI_COMPAT_H

#ifdef __wasi__

#include <stddef.h>
#include <stdint.h>
#include <string.h>

// Define socklen_t since it's not available in WASI
typedef uint32_t socklen_t;

#define _POSIX_C_SOURCE 200809L

#ifndef _TIME_T
#define _TIME_T
typedef long long time_t;
#endif  /* _TIME_T */

// Placeholder for socket-related constants
#ifndef SOL_SOCKET
#define SOL_SOCKET 1
#endif

#ifndef IPPROTO_TCP
#define IPPROTO_TCP 6
#endif

#ifndef TCP_NODELAY
#define TCP_NODELAY 6
#endif

#ifndef TCP_USER_TIMEOUT
#define TCP_USER_TIMEOUT 6
#endif

// Socket option placeholder values
#define SO_REUSEADDR 2
#define SO_KEEPALIVE 3
#define SO_ERROR 6
#define SO_RCVTIMEO 4
#define SO_SNDTIMEO 5

// Placeholder for ESOCKTNOSUPPORT and EPFNOSUPPORT
#define ESOCKTNOSUPPORT 1
#define EPFNOSUPPORT 1

// Forward declaration for sockaddr structure
struct sockaddr;

// Sockaddr_un definition if not defined
#ifndef __wasilibc___struct_sockaddr_un_h
#define __wasilibc___struct_sockaddr_un_h
struct sockaddr_un {
    int sun_family;
	unsigned char   sun_len;        /* sockaddr len including null */
	char            sun_path[104];  /* [XSI] path name (gag) */
};
#endif

#ifndef _BSD_SETJMP_H

typedef struct {
    int placeholder;
} jmp_buf;

void longjmp(jmp_buf, int);

#define LUAI_THROW(L,c) longjmp((c)->b, 1)

#define luai_jmpbuf jmp_buf

#endif /* END of _BSD_SETJMP_H */
// Define errno placeholder
// extern int errno;
// #define errno errno
// int errno;

#ifndef _SYS_SOCKET_H_
#define _SYS_SOCKET_H_

// Socket function stubs
int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen) {
    // Unused parameters to avoid warnings
    (void)sockfd; (void)level; (void)optname; (void)optval; (void)optlen;
    return -1;
}

int socket(int domain, int type, int protocol) {
    // Unused parameters to avoid warnings
    (void)domain; (void)type; (void)protocol;
    return -1;
}

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    // Unused parameters to avoid warnings
    (void)sockfd; (void)addr; (void)addrlen;
    return -1;
}

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    // Unused parameters to avoid warnings
    (void)sockfd; (void)addr; (void)addrlen;
    return -1;
}

int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen) {
    // Unused parameters to avoid warnings
    (void)sockfd; (void)level; (void)optname; (void)optval; (void)optlen;
    return -1;
}

#endif /* END of _SYS_SOCKET_H_ */

// Placeholder for strerror and errno
char *strerror(int errnum) {
    // Unused parameter to avoid warning
    (void)errnum;
    return (char *)"Error";
}

#ifndef __WINE_STDIO_H
#define __WINE_STDIO_H

// Handling L_tmpnam and tmpnam
#define L_tmpnam 64

#define lua_tmpnam(b,e)  { e = (tmpnam(b) == NULL); }

#define LUA_TMPNAMBUFSIZE L_tmpnam

char *tmpnam(char *a) {
    (void)a;
    return (char *)"Error";
}

#endif /* __WINE_STDIO_H */

#ifndef _SYS_SIGNAL_H_
#define _SYS_SIGNAL_H_

union sigval {
	/* Members as suggested by Annex C of POSIX 1003.1b. */
	int     sival_int;
	void    *sival_ptr;
};

// Signal handling stubs
typedef struct __siginfo {
	int     si_signo;               /* signal number */
	int     si_errno;               /* errno association */
	int     si_code;                /* signal code */
	int   si_pid;                 /* sending process */
	unsigned int   si_uid;                 /* sender's ruid */
	int     si_status;              /* exit value */
	void    *si_addr;               /* faulting instruction */
	union sigval si_value;          /* signal value */
	long    si_band;                /* band event for SIGPOLL */
	unsigned long   __pad[7];       /* Reserved for Future Use */
} siginfo_t;

union __sigaction_u {
	void    (*__sa_handler)(int);
	void    (*__sa_sigaction)(int, struct __siginfo *,
	    void *);
};

struct sigaction {
    int sa_flags;
    void (*sa_handler)(int);
    siginfo_t sa_mask;
    union __sigaction_u __sigaction_u;  /* signal handler */
};

#define sa_handler      __sigaction_u.__sa_handler
#define sa_sigaction    __sigaction_u.__sa_sigaction


#define SA_ONSTACK      0x0001  /* take signal on signal stack */
#define SA_RESTART      0x0002  /* restart system on signal return */
#define SA_RESETHAND    0x0004  /* reset to SIG_DFL when taking signal */
#define SA_NOCLDSTOP    0x0008  /* do not generate SIGCHLD on child stop */
#define SA_NODEFER      0x0010  /* don't mask the signal we're delivering */
#define SA_NOCLDWAIT    0x0020  /* don't keep zombies around */
#define SA_SIGINFO      0x0040  /* signal handler with SA_SIGINFO args */

#define SI_USER         0x10001 /* [CX] signal from kill() */

#endif  /* !_SYS_SIGNAL_H_ */


#ifndef _STRUCT_TIMEVAL
#define _STRUCT_TIMEVAL         

typedef long __darwin_time_t;
typedef int __darwin_suseconds_t;

struct timeval _STRUCT_TIMEVAL
{
	__darwin_time_t         tv_sec;         /* seconds */
	__darwin_suseconds_t    tv_usec;        /* and microseconds */
};

#endif /* _STRUCT_TIMEVAL */

#ifndef _SYS_TIME_H_
#define _SYS_TIME_H_

struct  itimerval {
	struct  timeval it_interval;    /* timer interval */
	struct  timeval it_value;       /* current value */
};

int setitimer(int, const struct itimerval * __restrict,
    struct itimerval * __restrict);

#endif  /* !_SYS_TIME_H_ */

// void sigsegvHandler(int sig, siginfo_t *info, void *secret) {
//     // Unused parameters to avoid warnings
//     (void)sig; (void)info; (void)secret;
// }

#ifndef _SYS_IOCCOM_H_
#define _SYS_IOCCOM_H_

#define IOCPARM_MASK    0x1fff          /* parameter length, at most 13 bits */

#define _IOC(inout, group, num, len) \
	(inout | ((len & IOCPARM_MASK) << 16) | ((group) << 8) | (num))

#define _IOR(g, n, t)     _IOC(IOC_OUT,	(g), (n), sizeof(t))


#endif  /* !_SYS_IOCCOM_H_ */


#ifndef _SYS_TTYCOM_H_
#define _SYS_TTYCOM_H_

#define TIOCGWINSZ _IOR('t', 104, struct winsize)  /* get window size */

#endif  /* !_SYS_TTYCOM_H_ */

#ifndef _SIGSET_T
#define _SIGSET_T
typedef unsigned int __darwin_sigset_t
typedef __darwin_sigset_t sigset_t;
#endif  /* _SIGSET_T */

#ifndef _USER_SIGNAL_H
#define _USER_SIGNAL_H

int	kill(pid_t, int);

#define	sigemptyset(set)	(*(set) = 0, 0)

int	pthread_sigmask(int, const sigset_t *, sigset_t *);

int	sigaddset(sigset_t *, int);

int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact) {
    // Unused parameters to avoid warnings
    (void)signum; (void)act; (void)oldact;
    return -1;
}

#endif	/* !_USER_SIGNAL_H */


#ifndef _UNISTD_H_
#define	_UNISTD_H_
// Fork, setsid, and dup2 Boilerplate
int fork(void) {
    return -1; // Indicate failure
}

int setsid(void) {
    return -1; // Indicate failure
}

int dup2(int oldfd, int newfd) {
    // Unused parameters to avoid warnings
    (void)oldfd; (void)newfd;
    return -1; // Indicate failure
}

// execve Boilerplate
int execve(const char *pathname, char *const argv[], char *const envp[]) {
    // Unused parameters to avoid warnings
    (void)pathname; (void)argv; (void)envp;
    return -1; // Indicate failure
}


#endif /* _UNISTD_H_ */


#ifndef _SYS_RESOURCE_H_
#define _SYS_RESOURCE_H_

// rlim_t, getrlimit, setrlimit Boilerplate
typedef int rlim_t;

struct rlimit {
    rlim_t rlim_cur;
    rlim_t rlim_max;
};

int getrlimit(int resource, struct rlimit *rlim) {
    // Unused parameters to avoid warnings
    (void)resource; (void)rlim;
    return -1;
}

int setrlimit(int resource, const struct rlimit *rlim) {
    // Unused parameters to avoid warnings
    (void)resource; (void)rlim;
    return -1;
}

// Placeholder for RLIMIT_NOFILE
#define RLIMIT_NOFILE 0 

#endif  /* !_SYS_RESOURCE_H_ */


// setjmp and longjmp placeholders
#define setjmp(env) 0

#else

// Include original POSIX headers when not targeting WASI
// #include <signal.h>
// #include <sys/resource.h>
// #include <unistd.h>
// #include <sys/types.h>
// #include <sys/socket.h>
// #include <netinet/in.h>
// #include <netinet/tcp.h>
// #include <arpa/inet.h>
// #include <sys/un.h>
// #include <setjmp.h>
// #include <errno.h>

#endif // __wasi__

#endif // WASI_COMPAT_H
