# SPDX-License-Identifier: GPL-2.0-only
# =========================================================================
# KiloOS Shared Makefile Definitions (Makefile.mk)
# Architecture: x86_64 (UEFI Class 3)
# =========================================================================

# Prevent direct execution of this shared rules file
ifeq ($(MAKEFILE_LIST),Makefile.mk)
$(error "Makefile.mk must be included by the main Makefile, not executed directly.")
endif

# Output and build directories
BUILD_DIR = build
SRC_DIR   = Src
KERN_DIR  = Kernel
INC_DIR   = include

# Common Assembler Flags for Binary
ASM_BIN_FLAGS = -f bin

# Common C Compiler Flags for Freestanding Environment
KERN_CFLAGS = -ffreestanding \
              -nostdlib \
              -fno-builtin \
              -fno-rtti \
              -fno-stack-protector \
              -Wall \
              -Wextra \
              -Werror \
              -mno-red-zone \
              -mno-mmx \
              -mno-sse \
              -mno-sse2 \
              -mcmodel=kernel \
              -I$(INC_DIR)

# Linker flags for LLVM lld
LDFLAGS = -nostdlib -T linker.ld
