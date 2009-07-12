# The number of microsteps
STEPS		?= 25

ASM		?= avra
AVRDUDE		?= avrdude
AVRDUDE_ARCH	?= m8
AVRDUDE_SPEED	?= 1
PROGRAMMER	?= avrisp2
PROGPORT	?= usb
CC		?= gcc
CFLAGS		?= -O2 --std=c99 -Wall

LFUSE	= 0xE0
HFUSE	= 0xD9


NAME	= m8driver
HEX	= $(NAME).S.hex

all: $(HEX)

tabgen: tabgen.o
	$(CC) $(CFLAGS) -o tabgen tabgen.o $(LDFLAGS) -lm

tables.S: tabgen
	./tabgen $(STEPS) > tables.S

$(HEX): m8driver.S m8def.inc tables.S
	$(ASM) m8driver.S

install: all
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -U flash:w:$(HEX)

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
	-rm -f *~ *.cof *.hex *.obj *.bak *.cache.* *.o tabgen tables.S
