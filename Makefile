MAIN := kernel.elf
ISO := kernel.iso

LINKFLAGS := -nostdlib -m32 -Wl,-T,$(shell pwd)/ext/teensy-cores/teensy3/mk20dx256.ld,--build-id=none
QEMU := qemu-system-i386
QEMUFLAGS := -no-reboot -no-shutdown -m 4096

$(MAIN): $(shell find src | grep .cr) Makefile src/link.ld teensy3.o
	@echo Creating $@...
	@crystal build src/main.cr --verbose --cross-compile --target=arm-none-eabi --prelude=empty --link-flags "$(LINKFLAGS)" -o $@
	arm-none-eabi-gcc 'kernel.elf.o' teensy3.o -o 'kernel.elf' -nostdlib  -Wl,-T,/osc/ext/teensy-cores/teensy3/mk20dx256.ld,--build-id=none    -L/usr/lib -L/usr/local/lib

teensy3.o:
	arm-none-eabi-gcc -c -o teensy3.o ext/teensy-cores/teensy3/usb_serial.c ext/teensy-cores/teensy3/usb_dev.c -I ext/teensy-cores/teensy3 -I ext/teensy-cores/usb_ -D __MK20DX256__ -D F_CPU=72000000 -D USB_SERIAL

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
