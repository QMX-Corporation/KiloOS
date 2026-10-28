# SPDX-License-Identifier: GPL-2.0-only
# =========================================================================
# KiloOS Main Makefile
# Architecture: x86_64 (UEFI Class 3)
# =========================================================================

# Include shared rules and global definitions
include Makefile.mk

.PHONY: all kernel bootloader secundary clean binary 


# --- 1. Compile to Objects (.o) 
all: kernel bootloader secundary binary 

# Assembly

bootloader:
	# The bootloader is direct
	$(ASM) $(ASM_BIN_FLAGS) Src/Bootloader/myboot.asm -o $(BUILD_DIR)/myboot.efi

sec_loader:
	$(ASM) $(ASM_BIN_FLAGS) Src/Loader-Init/main.asm -o $(BUILD_DIR)/main.o

# C
kernel:
	$(CC) $(KERN_CFLAGS) -c Kernel/kernel.c \
	-o $(BUILD_DIR)/kernel.o 

# --- 2. Compile to PXE Format ---

binary:
	# Loader
	ld $(LDFLAGS) -o $(BUILD_DIR)/main.o  
	# Kernel 
	

# --- 3. Clear artefacts ---
clean:
	rm -rf $(BUILD_DIR)/*.o 
