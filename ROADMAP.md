<!-- SPDX-License-Identifier: GPL-2.0-only -->

# KiloOS Roadmap

This document outlines the development phases of **KiloOS**, a bare-metal operating system written **exclusively in Assembly** targeting UEFI Class 3 environments.

## Phase 1: Bootloader Foundation (Current Focus)
* [ ] Structure the PE32+ headers for x86_64 UEFI execution.
* [ ] Implement **`myboot_header.asm`** to handle entry points, image handles, and system table structures.
* [ ] Implement **`myboot.asm`** for core bootloader logic and UEFI communication.
* [ ] Set up memory map retrieval (`GetMemoryMap`) using UEFI Boot Services.

## Phase 2: Handover & ExitBootServices
* [ ] Implement the robust Retry Loop to handle dynamic memory map updates during `ExitBootServices`.
* [ ] Finalize the firmware transition and clear UEFI runtime dependencies from boot memory.
* [ ] Prepare raw system parameters for the pure 64-bit environment.

## Phase 3: Firmware & Drivers Interface
* [ ] Integrate UEFI Capsule Update handlers (`capsule.asm`, `capsule-loader.asm`) for direct ROM/flash management.
* [ ] Establish low-level graphics output protocol (`gop.asm`) for basic frame-buffer manipulation without BIOS.

## Phase 4: Kernel Core & Architecture
* [ ] Initialize the pure Assembly x86_64 kernel.
* [ ] Set up IDT (Interrupt Descriptor Tables), exception handlers, and basic hardware communication.

---
*Maintained by the BDFL (João / dev12124).*
