
#include <stdint.h>
#include "ns16550.h"


#define DEFAULT_BAUDRATE  (9600)


struct __attribute__ ((aligned (8))) ns16550_pio
{
  // 0x000
  union __attribute__ ((aligned (8))) {
    const volatile uint8_t rbr;
    volatile uint8_t thr;
    volatile uint8_t dll;
  };

  // 0x008
  union __attribute__ ((aligned (8))) {
    volatile uint8_t dlm;
    volatile enum ier_t ier;
  };

  // 0x010
  union __attribute__ ((aligned (8))) {
    const volatile enum iir_t iir;
    volatile enum fcr_t fcr;
  };

  // 0x018
  volatile enum lcr_t lcr __attribute__ ((aligned (8)));

  // 0x020
  volatile enum mcr_t mcr __attribute__ ((aligned (8)));

  // 0x028
  volatile enum lsr_t lsr __attribute__ ((aligned (8)));

  // 0x030
  volatile uint8_t msr __attribute__ ((aligned (8)));

  // 0x038
  volatile uint8_t scr __attribute__ ((aligned (8)));
};


static struct ns16550_pio * pio = (void*)NS16550_BASE;

#ifdef CONSOLE_UART
__attribute__ ((constructor))
static int ns16550_init(void)
{
  uint32_t divisor;

  pio->ier = 0;

  divisor = NS16550_CLOCK_RATE / (16 * DEFAULT_BAUDRATE);
  pio->lcr |= LCR_DLAB;
  pio->dll = divisor & 0xff;
  pio->dlm = (divisor >> 8) & 0xff;
  pio->lcr &= ~LCR_DLAB;

  pio->lcr = LCR_WLS8;
  pio->fcr = FCR_FE;
  pio->mcr = MCR_RTS;

  return 0;
}
#endif


int ns16550_rxready(void)
{
  return ((pio->lsr & LSR_DR) != 0);
}


int ns16550_rxchar(void)
{
  while ((pio->lsr & LSR_DR) == 0)
    ;  // nothing

  return pio->rbr;
}


int ns16550_txchar(int c)
{
  while ((pio->lsr & LSR_THRE) == 0)
    ;  // nothing

  pio->thr = c;

  return c;
}


void ns16550_flush(void)
{
  while ((pio->lsr & LSR_TEMT) == 0)
    ;  // nothing
}
