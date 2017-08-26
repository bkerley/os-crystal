MAIN := kernel.elf
ISO := kernel.iso

LIBC_LINK_FLAGS=-Lext/newlib -lc -lg -lm -Lext/gcc -lgcc

LINKFLAGS := -nostdlib -m32 -Wl,-T,$(shell pwd)/ext/teensy-cores/teensy3/mk20dx256.ld,--build-id=none -lgcc $(LIBC_LINK_FLAGS)

$(MAIN): $(shell find src | grep .cr) Makefile src/link.ld src/arm-none-eabi/shim/shim.o
	@echo Creating $@...
	@crystal build src/main.cr --verbose --cross-compile --target=arm-none-eabi --mcpu cortex-m4 --mattr thumb-mode  --prelude=empty --link-flags "$(LINKFLAGS)" -o $@
	arm-none-eabi-gcc 'kernel.elf.o' ext/teensy-cores/teensy3/*.o ext/newlib/crt0.o ext/gcc/crt*.o src/arm-none-eabi/shim/shim.o -o 'kernel.elf' -nostdlib  -Wl,-T,/osc/mk20dx256.ld,--build-id=none    -L/usr/lib -L/usr/local/lib $(LIBC_LINK_FLAGS)

ext/teensy-cores/teensy3/main.elf:
	cd $(shell dirname $@); make NO_ARDUINO=1 main.elf; rm main.o

src/arm-none-eabi/shim/shim.o: src/arm-none-eabi/shim/shim.c
	arm-none-eabi-gcc -c $< -o $@

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
