#include <errno.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <sys/time.h>
#include "ns16550.h"

#ifndef __linux__

int read(int file, char *ptr, int len) {
  int todo;
  if(len == 0)
    return 0;
#ifdef CONSOLE_UART
  todo = 0;
  while (ns16550_rxready() && (todo < len)) {
    *ptr++ = ns16550_rxchar();
    todo++;
  }
#endif
  return todo;
}

int write(int file, char *ptr, int len) {
  int todo;

#ifdef CONSOLE_UART
  for (todo = 0; todo < len; todo++) {
    ns16550_txchar (*ptr++);
  }
#endif
  return len;
}

#define CLOCK_PERIOD  (100000000)

int gettimeofday(struct timeval *ptimeval, void *ptimezone)
{
    if (ptimeval)
    {
	long long tv;
#if __riscv_xlen == 64
	asm ("rdtime %0" : "=r" (tv));
#else
	unsigned int tvh;
	unsigned int tvl;
	asm ("rdtime %0;"
	    "rdtimeh %1 " : "=r" (tvl), "=r" (tvh));
	tv = ((long long)tvh) << 32 | tvl;
#endif
	ptimeval->tv_sec = tv / CLOCK_PERIOD;
	ptimeval->tv_usec = tv % CLOCK_PERIOD / (CLOCK_PERIOD / 1000000);
    }

    return 0;
}

unsigned int sleep(unsigned int seconds)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    seconds += tv.tv_sec;

    while (tv.tv_sec < seconds)
	gettimeofday(&tv, NULL);

    return 0;
}

// JES drafts:

void *
_sbrk (int nbytes)
{
  errno = ENOMEM;
  return  (void *) -1;
}

/*
int _write(
   int fd,
   const void *buffer,
   unsigned int count
	   )
{
  errno = ENOSPC;
  return -1;
}
*/

int _write(int file, char *ptr, int len) {
  int todo;

#ifdef CONSOLE_UART
  for (todo = 0; todo < len; todo++) {
    ns16550_txchar (*ptr++);
  }
#endif
  return len;
}

int _close(
   int fd
	   )
{
  errno = EBADF;
  return -1;
}

long _lseek(
    int fd,
    long offset,
    int origin
)
{
  errno = EBADF;
  return -1;
}

int _read(
   int fd,
   void *buffer,
   unsigned int count
)
{
  errno = EBADF;
  return -1;
}

int _fstat(
   int fd,
   struct _stat *buffer
)
{
  errno = EBADF;
  return -1;
}

int _isatty(
  int fd
)
{
  errno = EBADF;
  return 0;
}

int _kill(
  int pid,
  int sig
)
{
  errno = EBADF;
  return -1;
}

int _getpid(
  int n
)
{
  return 1;
}

#endif
