ASM=nasm
CC=gcc
CC16=/usr/bin/watcom/bin1/wcc
LD16=/usr/bin/watcom/bin1/wlink

BUILD_DIR=build

FLOPPY_NAME = main_floppy
FLOPPY_IMG = $(BUILD_DIR)/$(FLOPPY_NAME).img

BOOTLOADER_DIR = NexOS-Bootloader
KERNEL_DIR = NexOS-Kernel
SUBDIRS = $(BOOTLOADER_DIR) $(KERNEL_DIR)

FIRST_STAGE_NAME = first_stage
FIRST_STAGE_BIN = $(BOOTLOADER_DIR)/$(BUILD_DIR)/$(FIRST_STAGE_NAME).bin

SECOND_STAGE_NAME = second_stage
SECOND_STAGE_BIN = $(BOOTLOADER_DIR)/$(BUILD_DIR)/$(SECOND_STAGE_NAME).bin

KERNEL_NAME = kernel
KERNEL_BIN = $(KERNEL_DIR)/$(BUILD_DIR)/$(KERNEL_NAME).bin

$(shell mkdir -p $(BUILD_DIR))

all: $(FLOPPY_IMG)

$(FLOPPY_IMG): $(SUBDIRS)
	@echo 'Creating floppy image...'
	dd if=/dev/zero of=$(FLOPPY_IMG) bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(FLOPPY_IMG)
	dd if=$(FIRST_STAGE_BIN) of=$(FLOPPY_IMG) conv=notrunc
	mcopy -i $(FLOPPY_IMG) $(SECOND_STAGE_BIN) "::second_stage.bin"
	mcopy -i $(FLOPPY_IMG) $(KERNEL_BIN) "::kernel.bin"

$(SUBDIRS):
	@echo "Building in directory $@"
	$(MAKE) -C $@

.PHONY: all $(FLOPPY_IMG) $(SUBDIRS) clean

clean:
	rm -rf $(BUILD_DIR)
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
