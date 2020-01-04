# The number of microsteps
STEPS		= 25

ASM		= avra
ASMFLAGS	= -I /usr/share/avra
AVRDUDE		= avrdude
AVRDUDE_ARCH	= m8
AVRDUDE_SPEED	= 1
PROGRAMMER	= avrisp2
PROGPORT	= usb
CC		= gcc
CFLAGS		= -O2 --std=c99 -Wall -Wextra

DEBUG		= 0

# Fuses: Ext clock; 4ms SUT; BOD 4V; WDT always-on
LFUSE	= 0x10
HFUSE	= 0x99


NAME	= m8driver
HEX	= $(NAME).S.hex

ifneq ($(DEBUG),0)
ASMFLAGS += --define DEBUG
endif

all: $(HEX)

tabgen: tabgen.o
	$(CC) $(CFLAGS) -o tabgen tabgen.o $(LDFLAGS) -lm

tables.S: tabgen
	./tabgen $(STEPS) > tables.S

$(HEX): m8driver.S tables.S
	$(ASM) $(ASMFLAGS) --listfile $(NAME).S.lst --listmac $(NAME).S
	-srec_cat $(HEX) -Intel -Output $(NAME).S.bin -Binary
	@echo
	@echo "Successfully built the firmware"

install: all
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -U flash:w:$(HEX)

dumphex:
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -U flash:r:$(HEX).dump:i

dumpbin:
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -U flash:r:$(NAME).S.bin.dump:r

avrdude:
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -t

reset:
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) \
	 -U signature:r:/dev/null:i -q -q

writefuse:
	$(AVRDUDE) -B 10 -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -q -q \
	 -U lfuse:w:$(LFUSE):m \
	 -U hfuse:w:$(HFUSE):m

clean:
	-rm -f *~ *.cof *.hex *.obj *.bin *.lst *.bak *.cache.* *.o *.dump tabgen tables.S
