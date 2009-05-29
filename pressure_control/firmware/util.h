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

/* Convert a number (0-F) to a hexadecimal ASCII digit */
uint8_t hexdigit_to_ascii(uint8_t digit);

#define NUM16_NR_DIGITS		5
/* Convert a number to ascii.
 * buf must be at least (NUM16_NR_DIGITS + 1) long */
void num16_to_ascii(uint8_t *buf, uint16_t v);

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


uint16_t crc16_block_update(uint16_t crc, const void *data, uint16_t size);

/* Convenient casting macros. */
#define U8(value)		((uint8_t)(value))
#define U16(value)		((uint16_t)(value))
#define U32(value)		((uint32_t)(value))
#define U64(value)		((uint64_t)(value))


/* Convert a bit-number to a bit-mask.
 * Only valid for bitnr<=7.
 */
extern const prog_uint8_t bit2mask_lt[];
#undef BITMASK8
#define BITMASK8(bitnr)					\
	(__builtin_constant_p(bitnr) ? (1<<(bitnr)) :	\
	 pgm_read_byte(&bit2mask_lt[(bitnr)]))


#endif /* UTIL_H_ */
