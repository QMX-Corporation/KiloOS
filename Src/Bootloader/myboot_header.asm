; SPDX-License-Identifier: GPL-2.0-only

%ifndef MYBOOT_HEADER_ASM 
%define MYBOOT_HEADER_ASM

[BITS 64]
default rel
org 0x400000

; DOS Header
db 'M','Z'
times 0x3a db 0 
dd pe_header 
times 58 db 0
; PE Header 
pe_header:
  db 'P','E',0
  ; Windows Specific Fields 
  dw 0x8664 ; Arch
  dw 2 ; .text, .data
  dd 0 ; TimeStamp
  dd 0 ; PointerToSymbolTable
  dd 0 ; NumberOfSymbols
  dw 0xF0 ; SizeOfOptionalHeader
  dw 0x0022 ; Valid Executable and 64-bit Support 
  ; Optional Header
  dw 0x20b ; MagicNumber
  db 0 ; MajorLinkerVersion 
  db 0 ; MinorLinkerVersion 
  dd 0 ; SizeOfCode
  dd 0 ; SizeOfInitializedData
  dd 0 ; SizeOfUniniatilizedData
  dd efi_main ; AddressOfEntryPoint 
  dd 0x1000 ; BaseOfCode
  dd 0 ; BaseOfData
  dq 0x400000 ; ImageBase
  dd 0x1000 ; SectionAlignment 
  dd 0x200 ; FileAlignment
  dw 0 ; MajorOperatingSystemVersion 
  dw 0 ; MinorOperatingSystemVersion 
  dw 10 ; MajorSubsystemVersion 
  dw 10 ; MinorSubsystemVersion 
  dd 0 ; Win32VersionValue (Reserved) 
  dd 0 ; SizeOfImage 
  dd 0x400 ; SizeOfHeaders 
  dd 0 ; CheckSum 
  dw 10 ; Subsystem 
  dw 0x0100 ; DllCharacteristics 
  dq 0x100000 ; SizeOfStackReserve 
  dq 0x100000 ; SizeOfStackCommit 
  dq 0 ; SizeOfHeapReserve 
  dq 0 ; SizeOfHeapCommit 
  dd 0 ; LoaderFlags (Reserved) 
  dd 16 ; NumberOfRvaAndSizes 
  ; Data Directories in Optional Header,
  ; is unnecessary 
  times 128 db 0



; --- Section Table --- 
  
; .text 
db '.text',0,0,0
dd 0x1000       ; VirtualSize 
dd 0x1000       ; VirtualAddress (0x1000)
dd 0x200        ; SizeOfRawData (tamanho no disco, alinhado ao FileAlignment)
dd 0x400        ; PointerToRawData (começa logo após os cabeçalhos, em 0x400)
dd 0            ; PointerToRelocations 
dd 0            ; PointerToLinenumbers 
dw 0            ; NumberOfRelocations 
dw 0            ; NumberOfLinenumbers 
dd 0x60000020   ; Characteristics
  
; .data 
db '.data',0,0,0
dd 0x1000       ; VirtualSize
dd 0x2000       ; VirtualAddress 
dd 0x200        ; SizeOfRawData
dd 0x600        ; PointerToRawData 
dd 0            ; PointerToRelocations 
dd 0            ; PointerToLinenumbers 
dw 0            ; NumberOfRelocations 
dw 0            ; NumberOfLinenumbers 
dd 0xC0000040   ; Characteristics (Initialized Data, Readable, Writable)

%endif