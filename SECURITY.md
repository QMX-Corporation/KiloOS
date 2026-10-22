<!-- SPDX-License-Identifier: GPL-2.0-only -->

# Security Policy

Because KiloOS is a bare-metal, pure Assembly operating system running on UEFI Class 3 firmware with zero abstraction layers, security and memory safety at the lowest level are critical.

## Reporting a Vulnerability

If you discover a security vulnerability, buffer overflow, or low-level flaw in KiloOS, please **do not** open a public GitHub issue. 

Instead, report it directly:
* **Primary Contact:** João (The BDFL)
* **Email:** `<joaoanandalima@gmail.com>`

### What to Include in the Report:
1. Detailed description of the vulnerability (e.g., in the bootloader's memory map parsing, UEFI capsule loader, or paging structures).
2. Architecture context (x86_64, UEFI Class 3 environment).
3. Steps or proof-of-concept to reproduce the issue.

We appreciate responsible disclosure to keep KiloOS secure right down to the bare metal.
