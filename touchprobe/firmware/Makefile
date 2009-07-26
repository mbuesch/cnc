ASM		?= avra
AVRDUDE		?= avrdude
AVRDUDE_ARCH	?= m8
AVRDUDE_SPEED	?= 1
PROGRAMMER	?= avrisp2
PROGPORT	?= usb

LFUSE	= 0xE0
HFUSE	= 0xD9


NAME	= touchprobe
HEX	= $(NAME).S.hex

all: $(HEX)

$(HEX): $(NAME).S m8def.inc
	$(ASM) $(NAME).S
	-srec_cat $(HEX) -Intel -Output $(NAME).S.bin -Binary
	@echo
	@echo "Successfully built the firmware"

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
	-rm -f *~ *.cof *.hex *.obj *.bin *.bak *.cache.* *.o
