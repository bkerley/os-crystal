MAIN := kernel.elf
ISO := kernel.iso

LIBC_LINK_FLAGS=-L/usr/lib/arm-none-eabi/newlib/armv7e-m -lc_nano

LINKFLAGS := -nostdlib -m32 -Wl,-T,$(shell pwd)/ext/teensy-cores/teensy3/mk20dx256.ld,--build-id=none -lgcc $(LIBC_LINK_FLAGS)

$(MAIN): $(shell find src | grep .cr) Makefile src/link.ld
	@echo Creating $@...
	@crystal build src/main.cr --verbose --cross-compile --target=arm-none-eabi --mcpu cortex-m4 --mattr thumb-mode  --prelude=empty --link-flags "$(LINKFLAGS)" -o $@
	arm-none-eabi-gcc 'kernel.elf.o' ext/teensy-cores/teensy3/*.o  -o 'kernel.elf' -nostdlib  -Wl,-T,/osc/ext/teensy-cores/teensy3/mk20dx256.ld,--build-id=none    -L/usr/lib -L/usr/local/lib $(LIBC_LINK_FLAGS)

ext/teensy-cores/teensy3/main.elf:
	cd $(shell dirname $@); make NO_ARDUINO=1 main.elf; rm main.o

src/arm-none-eabi/shim/shim.o: src/arm-none-eabi/shim/shim.c
	arm-none-eabi-gcc -c $< ext/teensy-cores/teensy3/*.o -o $@ -nostdlib  -Wl,-T,/osc/ext/teensy-cores/teensy3/mk20dx256.ld,--build-id=none    -L/usr/lib -L/usr/local/lib

.PHONY: clean
clean:
	@rm -rf $(MAIN) $(ISO) iso

.PHONY: run
run: $(MAIN)
	@$(QEMU) $(QEMUFLAGS) -kernel $(MAIN)

.PHONY: runiso
runiso: $(iso)
	@$(QEMU) $(QEMUFLAGS) -cdrom $(ISO)

.PHONY: iso
iso: $(ISO)

$(ISO): $(MAIN) Makefile
	@mkdir -p iso/boot/grub
	@cp $(MAIN) iso/boot/
	@echo "set timeout=0" > iso/boot/grub/grub.cfg
	@echo "menuentry \"crystal kernel\" {" >> iso/boot/grub/grub.cfg
	@echo "  multiboot /boot/$(MAIN)" >> iso/boot/grub/grub.cfg
	@echo "}" >> iso/boot/grub/grub.cfg
	@grub2-mkrescue iso -o $@
