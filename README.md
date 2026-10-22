KiloOS
======

KiloOS is a bare-metal, 64-bit operating system written exclusively in Assembly targeting UEFI Class 3 environments. It emphasizes architectural purity, high-performance engineering, and zero high-level language abstractions.

Quick Start
-----------

* Report a bug: See `SECURITY.md` or `.github/ISSUE_TEMPLATE/bug_report.md`
* Organization: QMX Corporation (`https://github.com/QMX-Corporation/KiloOS`)
* Build Environment: See `.devcontainer/Dockerfile` and `ci.yml`

Essential Documentation
-----------------------

All developers and contributors should be familiar with:

* Building requirements: See `ROADMAP.md`
* Code of Conduct: See `CODE_OF_CONDUCT.md`
* Contributing Guidelines: See `CONTRIBUTING.md`
* Contributors & Maintainers: See `CONTRIBUTORS.md`
* License: See `LICENSE`

Repository Layout
-----------------

The KiloOS source tree is structured as follows:

```text
KiloOS/
├── .devcontainer/
│   ├── devcontainer.json
│   └── Dockerfile
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── workflows/
│       ├── check_memory_leak.yml
│       ├── check_merge_ability.yml
│       └── ci.yml
├── IntelEmulator/
├── Src/
│   ├── Bootloader/
│   │   ├── myboot.asm
│   │   └── myboot_header.asm
│   └── Drivers/
│       └── Firmware/
│           └── Efi/
│               └── Services/
│                   ├── capsule.asm
│                   ├── capsule-loader.asm
│                   ├── efi.asm
│                   ├── gop.asm
│                   └── table.asm
├── .dockerignore
├── .editorconfig
├── .gitattributes
├── .gitignore
├── .gitmodules
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── CONTRIBUTORS.md
├── GOVERNANCE.md
├── LICENSE
├── README.md
├── ROADMAP.md
├── SECURITY.md
├── SPDX-Identifier
└── SUPPORT.md
```

Who Are You?
-------------
Find your role below:
Core Assembly Developer: Writing low-level UEFI bootloader modules and firmware interfaces.
Systems Architect: Managing memory maps, CPU initialization, and bare-metal execution flow.
Security Expert: Auditing code for memory safety, buffer boundaries, and robust validation.
Maintainer: Reviewing pull requests under the strict BDFL governance model.

Governance 
-----------
KiloOS operates under a strict BDFL (Benevolent Dictator For Life) governance model led by João (dev12124). All architectural changes, design choices, and maintainer promotions require direct alignment with project leadership as outlined in GOVERNANCE.md.

Contributors
-------------
We thank all the brilliant minds contributing to the bare-metal evolution of KiloOS!

<a href="https://github.com/QMX-Corporation/KiloOS/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=QMX-Corporation/KiloOS" />
</a>

License 
--------
KiloOS is free software distributed under the terms of the GNU General Public License v2.0 only. See LICENSE for details.