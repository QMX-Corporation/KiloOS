<!-- SPDX-License-Identifier: GPL-2.0-only -->

## Description
Provide a clear and concise description of the low-level changes introduced in this Pull Request.

## Type of Change
- [ ] Bug fix (low-level correction in Assembly code)
- [ ] New feature (e.g., bootloader module, UEFI service interaction)
- [ ] Documentation / Infrastructure update

## Engineering Checklist (KiloOS Standards)
- [ ] **Pure Assembly Only:** No C, C++, or high-level wrappers are introduced. NASM Intel syntax is strictly followed.
- [ ] **UEFI Class 3 Compliance:** No legacy BIOS dependencies, CSM, or real-mode interrupts (`int 10h`, etc.).
- [ ] **Code Styling & Formatting:** Indentation uses tabs for `.asm` files, POSIX-compliant `LF` line endings.
- [ ] **SPDX Header:** All modified or new files include the correct `SPDX-License-Identifier: GPL-2.0-only` header.
- [ ] **CI/CD Pipeline:** Changes build successfully inside the Docker/NASM container environment.

## Additional Context
Add any relevant hardware context, UEFI firmware logs, or architectural decisions.
