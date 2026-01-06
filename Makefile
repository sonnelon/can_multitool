CC      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

CPU     = cortex-m3
DEFS    = -DSTM32F103C8
CFLAGS  = -mcpu=$(CPU) -mthumb -O2 -Wall -Wextra -Wpedantic \
          -ffreestanding -nostdlib $(DEFS) -Iinclude

LDFLAGS = -T linker_script.ld -nostdlib

TARGET  = can_multitool
SRCS    = main.c 
OBJS    = $(SRCS:.c=.o)

all: $(TARGET).elf $(TARGET).hex

%.o: %.c
	$(CC) $(CFLAGS) clean -c $< -o $@

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

.PHONY: flash clean
flash:
	openocd -f interface/stlink-v2.cfg \
	        -f target/stm32f1x.cfg \
	        -c "program $(TARGET).elf verify reset exit"

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).hex
