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
	MSG_SET_VALVE,
	MSG_RESTARTED,
	MSG_SHUTDOWN,
	MSG_TURNON,
	MSG_GET_MAXIMA,
	MSG_MAXIMA,

	MSG_ID_MASK		= 0x3F,
	MSG_FLAG_QOVERFLOW	= 0x40, /* TX queue overflow */
	MSG_FLAG_REQ_ERRCODE	= 0x80, /* Error code is requested */
};

enum remote_message_error {
	MSG_ERR_NONE = 0,	/* No error */
	MSG_ERR_CHKSUM,		/* Checksum error */
	MSG_ERR_NOCMD,		/* Unknown command */
	MSG_ERR_BUSY,		/* Busy */
	MSG_ERR_INVAL,		/* Invalid argument */
};

enum remote_message_config_flags {
	CFG_FLAG_AUTOADJUST_ENABLE = 0,
};

struct remote_message {
	uint8_t id;

	union {
		struct {
			uint8_t code;
		} __attribute__((packed)) error;
		struct {
			char str[4];
		} __attribute__((packed)) logmessage;
		struct {
			uint16_t mbar[2];
		} __attribute__((packed)) pressure;
		struct {
			uint8_t island;	/* Valve island */
			uint16_t mbar;
		} __attribute__((packed)) setpressure;
		struct {
			uint8_t flags[2];
		} __attribute__((packed)) config;
		struct {
			uint8_t island;	/* Valve island */
			uint8_t flags;
		} __attribute__((packed)) setconfig;
		struct {
			uint8_t island;	/* Valve island */
			uint8_t nr;	/* Valve ID in the island */
			uint8_t state;
		} __attribute__((packed)) valve;
		struct {
			uint8_t island; /* Valve island */
		} __attribute__((packed)) getmaxima;
		struct {
			uint16_t pressure;
			uint16_t hysteresis;
		} __attribute__((packed)) maxima;

		uint8_t __padding[4];
	} __attribute__((packed));

	uint8_t crc;
} __attribute__((packed));


void print_sram(const char *msg);
void print_pgm(const char __flash *msg);
#define print(string_literal)	print_pgm(PSTR(string_literal))
void print_dec(uint16_t number);
void print_dec_signed(int16_t number);
void print_hex(uint8_t number);

void remote_pressure_change_notification(uint16_t xy_mbar, uint16_t z_mbar);
void remote_notify_restart(void);

void remote_work(void);
void remote_init(void);

#endif /* REMOTE_H_ */
