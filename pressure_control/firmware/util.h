#ifndef UTIL_H_
#define UTIL_H_

#include <stdint.h>
#include <avr/eeprom.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>

/* Some of these macros are derived from the Linux Kernel sources. */

#define likely(x)		__builtin_expect(!!(x), 1)
#define unlikely(x)		__builtin_expect(!!(x), 0)

#undef offsetof
#define offsetof(type, member)	((size_t)&((type *)0)->member)

#define min(a, b)		((a) < (b) ? (a) : (b))
#define max(a, b)		((a) > (b) ? (a) : (b))

#define abs(x)	({			\
	__typeof__(x) __x = (x);	\
	(__x < 0) ? -__x : __x;		\
		})

#define lo8(x)			((uint8_t)(x))
#define hi8(x)			((uint8_t)((x) >> 8))

#define ARRAY_SIZE(x)		(sizeof(x) / sizeof((x)[0]))

/* Memory barrier.
 * The CPU doesn't have runtime reordering, so we just
 * need a compiler memory clobber. */
#define mb()			__asm__ __volatile__("" : : : "memory")

/* Convert something indirectly to a string */
#define __stringify(x)		#x
#define stringify(x)		__stringify(x)

/* Assertions */
void panic(const prog_char *msg) __attribute__((noreturn));
#define BUILD_BUG_ON(x)		((void)sizeof(char[1 - 2 * !!(x)]))
#define BUG_ON(x)					\
	do {						\
		if (unlikely(x))			\
			panic(PSTR(__FILE__		\
			      stringify(__LINE__)));	\
	} while (0)

void infinite_sleep(void) __attribute__((noreturn));

/* Delay */
void mdelay(uint16_t msecs);
void udelay(uint16_t usecs);

typedef _Bool		bool;

/* IRQ handling.
 * We use a macro for irq_disable_save(), because stupid gcc is not
 * able to properly optimize an inline function that returns a value.
 */
#define irq_disable_save()	({	\
	uint8_t sreg_flags = SREG;	\
	cli();				\
	sreg_flags;			\
				})

static inline void irq_restore(uint8_t sreg_flags)
{
	mb();
	SREG = sreg_flags;
}

#define irqs_disabled()		(!(SREG & (1 << SREG_I)))

#endif /* UTIL_H_ */
