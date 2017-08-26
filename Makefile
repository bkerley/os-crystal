MAIN := kernel.elf
BIN := kernel.bin
HEX := kernel.hex

LIBC_LINK_FLAGS=-Lext/newlib -lc -lg -lm -Lext/gcc -lgcc --specs=nano.specs

LINKFLAGS := -nostdlib  -Wl,-T,$(shell pwd)/ext/teensy-cores/teensy3/mk20dx256.ld,--build-id=none -lgcc $(LIBC_LINK_FLAGS)

$(MAIN): $(shell find src | grep .cr) Makefile src/link.ld src/arm-none-eabi/shim/shim.o ext/teensy-cores/teensy3/main.elf
	@echo Creating $@...
	@crystal build src/main.cr --verbose --cross-compile --target=arm-none-eabi --mcpu cortex-m4 --mattr thumb-mode  --prelude=empty --link-flags "$(LINKFLAGS)" -o $@
	arm-none-eabi-gcc 'kernel.elf.o' ext/teensy-cores/teensy3/*.o ext/newlib/crt0.o ext/gcc/crt*.o src/arm-none-eabi/shim/shim.o -o 'kernel.elf' -nostdlib  -Wl,-T,/osc/mk20dx256.ld,--build-id=none -s   -L/usr/lib -L/usr/local/lib $(LIBC_LINK_FLAGS)

$(BIN): $(MAIN)
	arm-none-eabi-objcopy -O binary -j .text -j .data $< $@

$(HEX): $(MAIN)
	arm-none-eabi-objcopy -O ihex -R .ARM.extab -R .comment $< $@

ext/teensy-cores/teensy3/main.elf:
	cd $(shell dirname $@); make NO_ARDUINO=1 main.elf; rm main.o

src/arm-none-eabi/shim/shim.o: src/arm-none-eabi/shim/shim.c
	arm-none-eabi-gcc -c $< -o $@

.PHONY: clean
clean:
	@rm -rf $(MAIN) $(ISO) iso
	cd ext/teensy-cores/teensy3; make clean
