---
name: Bug Report
about: Create a report to help us improve KiloOS low-level components
title: '[BUG] '
labels: 'bug'
assignees: ''
---

<!-- SPDX-License-Identifier: GPL-2.0-only -->

## Description of the Bug
A clear and concise description of what the bug is (e.g., unexpected exception, register corruption, memory map failure during boot).

## Hardware & Environment Context
- **Firmware Environment:** UEFI Class 3 (No CSM/BIOS)
- **Architecture:** x86_64
- **Testing Method:** (e.g., QEMU / Real Hardware / Test Device model)
- **Build Tooling:** NASM inside Docker container

## Steps to Reproduce
1. Build the OS using `...`
2. Run on UEFI target using `...`
3. Observe error/behavior.

## Expected Behavior
What you expected to happen in pure Assembly execution.

## Logs / Assembly Snippets
If applicable, paste debug logs, serial output, or relevant lines from `myboot.asm` / `myboot_header.asm`.
