
NASM = nasm
QEMU = qemu-system-x86_64

all: os.img

install:
	@echo "Installing dependencies..."
	@echo "NASM and QEMU should be available via Nix"
	@which nasm || echo "NASM not found"
	@which qemu-system-x86_64 || echo "QEMU not found"

boot.bin: boot.asm
	$(NASM) -f bin boot.asm -o boot.bin

kernel.bin: kernel.asm
	$(NASM) -f bin kernel.asm -o kernel.bin

os.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > os.img
	# Pad to 1.44MB floppy size
	truncate -s 1440K os.img

run: os.img
	$(QEMU) -fda os.img -boot a -display gtk

clean:
	rm -f *.bin *.img

.PHONY: all run clean install
