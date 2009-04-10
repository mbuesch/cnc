ARCH		?= atmega8
AVRDUDE_ARCH	?= m8
AVRDUDE		?= avrdude
AVRDUDE_SPEED	?= 1
PROGRAMMER	?= avrisp2
PROGPORT	?= usb

CC		= avr-gcc
OBJCOPY		= avr-objcopy
SIZE		= avr-size

CFLAGS		= -mmcu=$(ARCH) -std=gnu99 -g0 -O2 -Wall
CFLAGS		+= "-Dinline=inline __attribute__((__always_inline__))"


# The fuse bits
LFUSE	= 0xE0
HFUSE	= 0xD9

OBJECTS = main.o util.o valves.o sensor.o remote.o
NAME	= pressure_control

BIN	= $(NAME).bin
HEX	= $(NAME).hex
EEP	= $(NAME).eep.hex

all: $(HEX)

main.o: util.h calibration.h valves.h sensor.h remote.h main.h

util.o: util.h calibration.h

valves.o: util.h valves.h

sensor.o: util.h sensor.h

remote.o: util.h remote.h calibration.h main.h valves.h

%.s: %.c
	$(CC) $(CFLAGS) -S $*.c

$(BIN): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(BIN) $(OBJECTS) $(LDFLAGS)

$(HEX): $(BIN)
	$(OBJCOPY) -R.eeprom -O ihex $(BIN) $(HEX)
	$(OBJCOPY) -j.eeprom --set-section-flags=.eeprom="alloc,load" \
		   --change-section-lma .eeprom=0 -O ihex $(BIN) $(EEP)
	$(SIZE) $(BIN)

avrdude:
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -t

install_flash:
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -U flash:w:$(HEX)

install_eeprom:
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -U eeprom:w:$(EEP)

install: all install_flash install_eeprom

# Reset the microcontroller through avrdude
reset:
	$(AVRDUDE) -B $(AVRDUDE_SPEED) -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) \
	 -U signature:r:/dev/null:i -q -q

writefuse:
	$(AVRDUDE) -B 100 -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -q -q \
	 -U lfuse:w:$(LFUSE):m \
	 -U hfuse:w:$(HFUSE):m

clean:
	-rm -f *~ *.o $(BIN)

distclean: clean
	-rm -f *.s $(HEX) $(EEP)

help:
	@echo "Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all       - build the firmware (default target)"
	@echo "  clean     - remove object files"
	@echo "  distclean - remove object, binary and hex files"
	@echo ""
	@echo "Targets that operate on the device through avrdude:"
	@echo "  install   - flash the program code"
	@echo "  writefuse - write the fuse bits"
	@echo "  reset     - pull the external device reset pin"
	@echo "  avrdude   - run avrdude in interactive mode"
	@echo ""
	@echo "Generic targets:"
	@echo "  *.s       - create an assembly file from a *.c file"
