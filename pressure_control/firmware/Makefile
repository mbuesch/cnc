# The architecture configuration
ARCH		= atmega8
AVRDUDE_ARCH	= m8
AVRDUDE		= avrdude
AVRDUDE_SPEED	= 1
PROGRAMMER	= avrisp2
PROGPORT	= usb

# The toolchain definitions
CC		= avr-gcc
OBJCOPY		= avr-objcopy
SIZE		= avr-size
READELF		= avr-readelf
SPARSE		= sparse

V		= @		# Verbose build:  make V=1
C		= 0		# Sparsechecker build:  make C=1
Q		= $(V:1=)
QUIET_CC	= $(Q:@=@echo '     CC       '$@;)$(CC)
QUIET_DEPEND	= $(Q:@=@echo '     DEPEND   '$@;)$(CC)
QUIET_OBJCOPY	= $(Q:@=@echo '     OBJCOPY  '$@;)$(OBJCOPY)
QUIET_SIZE	= $(Q:@=@echo '     SIZE     '$@;)$(SIZE)
QUIET_READELF	= $(Q:@=@echo '     READELF  '$@;)$(READELF)
ifeq ($(C),1)
QUIET_SPARSE	= $(Q:@=@echo '     SPARSE   '$@;)$(SPARSE)
else
QUIET_SPARSE	= @/bin/true
endif

CFLAGS		= -mmcu=$(ARCH) -std=gnu99 -g0 -O2 -Wall \
		  "-Dinline=inline __attribute__((__always_inline__))"
SPARSEFLAGS	= $(CFLAGS) -I "/usr/lib/avr/include" -D__AVR_ARCH__=4 \
		  -D__AVR_ATmega8__=1 -D__ATTR_PROGMEM__="" -Dsignal=dllexport \
		  -Dexternally_visible=dllexport


SRCS	= main.c util.c valves.c sensor.c remote.c
NAME	= pressure_control

BIN	= $(NAME).bin
HEX	= $(NAME).hex
EEP	= $(NAME).eep.hex
FUSES	= $(NAME).fuses.bin

.SUFFIXES:
.PHONY: all avrdude install_flash install_eeprom install reset writefuse clean distclean
.DEFAULT_GOAL := all

DEPS = $(sort $(patsubst %.c,dep/%.d,$(1)))
OBJS = $(sort $(patsubst %.c,obj/%.o,$(1)))

# Generate dependencies
$(call DEPS,$(SRCS)): dep/%.d: %.c 
	@mkdir -p $(dir $@)
	$(QUIET_DEPEND) -o $@.tmp -MM -MG -MT "$@ $(patsubst dep/%.d,obj/%.o,$@)" $(CFLAGS) $< && mv -f $@.tmp $@

-include $(call DEPS,$(SRCS))

# Generate object files
$(call OBJS,$(SRCS)): obj/%.o:
	@mkdir -p $(dir $@)
	$(QUIET_SPARSE) $(SPARSEFLAGS) $<
	$(QUIET_CC) -o $@ -c $(CFLAGS) $<

all: $(HEX) $(FUSES)

%.s: %.c
	$(QUIET_CC) $(CFLAGS) -S $*.c

%.o: %.c
	$(QUIET_SPARSE) $(SPARSEFLAGS) $<
	$(QUIET_CC) -o $@ -c $(CFLAGS) $<

$(BIN): $(call OBJS,$(SRCS))
	$(QUIET_CC) $(CFLAGS) -o $(BIN) $(call OBJS,$(SRCS)) $(LDFLAGS)

$(HEX): $(BIN)
	$(QUIET_OBJCOPY) -R.eeprom -R.fuse -O ihex $(BIN) $(HEX)
	$(QUIET_OBJCOPY) -j.eeprom --set-section-flags=.eeprom="alloc,load" \
			 --change-section-lma .eeprom=0 -O ihex $(BIN) $(EEP)
	$(QUIET_SIZE) $(BIN)
	$(QUIET_READELF) -S $(BIN) | egrep '(Name|text|eeprom|data|bss)'

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

$(FUSES): $(BIN)
	$(QUIET_OBJCOPY) -j.fuse -O binary $(BIN) $(FUSES)

writefuses: $(FUSES)
	@echo Low fuse is:  $$(hexdump -e '1/1 "0x%02X "' $(FUSES) | cut -d ' ' -f 1)
	@echo High fuse is: $$(hexdump -e '1/1 "0x%02X "' $(FUSES) | cut -d ' ' -f 2)
	$(AVRDUDE) -B 100 -p $(AVRDUDE_ARCH) \
	 -c $(PROGRAMMER) -P $(PROGPORT) -q -q \
	 -U lfuse:w:$$(hexdump -e '1/1 "0x%02X "' $(FUSES) | cut -d ' ' -f 1):m \
	 -U hfuse:w:$$(hexdump -e '1/1 "0x%02X "' $(FUSES) | cut -d ' ' -f 2):m

clean:
	rm -Rf *~ *.o obj dep $(BIN)

distclean: clean
	rm -f *.s $(HEX) $(EEP) $(FUSES)

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
