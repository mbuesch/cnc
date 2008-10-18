#ifndef REMOTE_H_
#define REMOTE_H_

#include <stdint.h>

#include <avr/pgmspace.h>


enum remote_message_id {
	MSG_INVALID = 0, /* Discard me */
	MSG_ERROR,
	MSG_LOGMESSAGE,
	MSG_PING,
	MSG_PONG,
	MSG_GET_CURRENT_PRESSURE,
	MSG_CURRENT_PRESSURE,
	MSG_GET_DESIRED_PRESSURE,
	MSG_DESIRED_PRESSURE,
	MSG_SET_DESIRED_PRESSURE,
	MSG_GET_HYSTERESIS,
	MSG_HYSTERESIS,
	MSG_SET_HYSTERESIS,
	MSG_GET_CONFIG_FLAGS,
	MSG_CONFIG_FLAGS,
	MSG_SET_CONFIG_FLAGS,
};

enum remote_message_error {
	MSG_ERR_NONE = 0,
	MSG_ERR_CHKSUM,
};

enum remote_message_config_flags {
	CFG_FLAG_AUTOADJUST_ENABLE = 0,
};

struct remote_message {
	uint8_t id;
	uint8_t __padding0[3];

	union {
		struct {
			uint8_t code;
		} __attribute__((packed)) error;
		struct {
			char str[32];
		} __attribute__((packed)) logmessage;
		struct {
			uint16_t mbar;
		} __attribute__((packed)) pressure;
		struct {
			uint32_t flags;
		} __attribute__((packed)) config;

		uint8_t __padding1[32];
	} __attribute__((packed));

	uint16_t crc;
} __attribute__((packed));


void print_pgm(const prog_char *msg);
#define print(string_literal)	print_pgm(PSTR(string_literal))

void remote_work(void);
void remote_init(void);

#endif /* REMOTE_H_ */
