; SPDX-License-Identifier: GPL-2.0-only 


%include "myboot_header.asm"

[BITS 64]
default rel 
org 0x400000 

; Entry in .text 
align 0x1000 

; --- ACPI Finds ---
acpi_find:
  mov r12, [rcx + 0x68] ; SystemTable -> NumberOfTableEntries 
  mov rbx, [rcx + 0x70] ; SystemTable -> ConfigurationTable
  ; The GUID 
  mov rax, [rbx]  
  ; Jumps
  jmp .loop
  
; --- Local/Sub Routines of ACPI Finds ---
; Loop
.loop:
  ; Compare the First Part
  mov r10, [rbx] 
  mov r11, [rel guid_acpi] 
  cmp r11, r10 ; FirstPart 
  ; If yes
  je .second_part
  ; If no 
  jne .sub_con

; Second Part 
.second_part:
  mov r10, [rbx + 8] 
  mov r11, [rel guid_acpi + 8]
  cmp r10, r11
  je .continue 
  jne .sub_con
  
; Continue
.continue:
  ; Get RSDP 
  mov r8, [rbx + 16] ; RSDP Pointer 
  mov [acpi_tables.xsdt_pointer], r8 ; xsdtAddress 
  ; Return 
  mov rax, 0
  ret 

; Sub Continue
.sub_con:
  ; Decrement Counter 
  dec r12
  test r12, r12
  jz .zero_register
  ; Next Entrie 
  add rbx, 24 
  ; Repeat
  jmp .loop

; Zero Register 
.zero_register:
  mov rax, 0
  ret
  


  
; --- EFI Main --- 
efi_main:
  ; Shadow Space, Align 16 Bytes 
  sub rsp, 64 
  ; ImageHandle and System Table 
  mov rax, rcx ; Image Handle 
  mov [crucial_struct.image_handle], rax 
  mov rbx, rdx ; System Table 
  mov [crucial_struct.system_table], rbx
  ; 1. Clear Screen
  mov rax, [crucial_struct.system_table]
  mov rcx, [rax + 0x40] ; ConOut Table (ScreenManager) 
  call qword [rcx + 0x30] ; ClearScreen()
  ; 2. Print a message
  mov rax, [crucial_struct.system_table]
  mov rcx, [rax + 0x40] ; ConOut Table (Screen Manager)
  mov rdx, messages.hello_msg ; Message
  call qword [rcx + 0x08] ; OutputString()
  ; ---     3. Get the GOP     --- 
  ; 3.1. Call the GOP Function()
  mov rax, [crucial_struct.system_table]
  mov rcx, [rax + 0x60] ; BootServices
  mov rdx, guid_gop ; GUID GOP
  mov r8, tmp_framebuffer ; The UEFI finds the Framebuffer (Scanlines, Width, Height and Address)
  mov r9, 0 ; Is unnecessary 
  call qword [rcx + 0x140]
  ; 3.2. Padding and framebuffer_gop Structure 
  jmp .padding_gop 

; --- Locals/Sub Routines of EFI Main ---
.padding_gop:
  ; Structure Mode
  mov rdx, [tmp_framebuffer]
  mov r8, [rdx + 0x18] ; Entry in Structure Mode
  ; FramebufferBase
  mov rax, [r8 + 0x18] 
  mov [framebuffer_gop.address_base], rax
  ; Structure Info
  mov r8, [r8 + 0x08] ; Entry in Structure Info
  ; Width 
  mov eax, [r8 + 0x04]
  mov [framebuffer_gop.width], eax 
  ; Height
  mov eax, [r8 + 0x08] 
  mov [framebuffer_gop.height], eax 
  ; Scanlines Per Pixel
  mov eax, [r8 + 0x20]
  mov [framebuffer_gop.scanline_per_pixel], eax 

  
  ; --- Back to efi_main() ---
  ; 4. Get XSDT Pointer 
  mov rax, [crucial_struct.system_table] ; SystemTable 
  mov rcx, rax ; Brute Pointer of SystemTable 
  call acpi_find
  ; 5. GetMemoryMap() 
  mov rax, [crucial_struct.system_table] ; SystemTable 
  mov rcx, [rax + 0x60] ; BootServices 
  lea rdx, [memory_map.map_size] ; The MapSize  
  mov r8, 0 ; Null-Buffer for UEFI return MapSize and MapKey 
  lea r9, [memory_map.map_key] ; The MapKey
  ; Stack
  lea rax, [memory_map.descriptor_size] 
  mov [rsp + 32], rax ; DescriptorSize 
  lea rax, [memory_map.descriptor_version]  
  mov [rsp + 40], rax ; DescriptorVersion 
  ; GetMemoryMap() 
  call qword [rcx + 0x34] 
  ; 5.1. Alloc the Buffer
  mov rax, [crucial_struct.system_table] ; SystemTable 
  mov rcx, [rax + 0x60] ; BootServices
  mov rdx, 0 ; AllocateAnyPages
  mov r8, 2 ; LOADER_KERNEL_DATA_AREA
  ; Bits Shift per 12 using shr 
  ; (division for 4096) and 
  ; executes a adition per 16 (4 * 4)
  mov r12, [memory_map.map_size]
  shr r12, 12
  add r12, 4
  mov r9, r12 ; 4 Pages (16KB Total)
  ; Stack
  lea rax, memory_map.buffer_map
  mov [rsp + 32], rax ; InitialAddress of LOADER_KERNEL_DATA_AREA
  
  



  

  
; --- Entry in .data ---
align 0x2000 

; --- Pointers ---

; ACPI
ptr_acpi: db 0


; --- GUIDs ---

; ACPI 
guid_acpi:
  dd 0xEB9D8D30
  dw 0x2D88
  dw 0x11D3
  db 0x9A
  db 0x16
  db 0x00
  db 0x90
  db 0x27
  db 0x3F
  db 0xC1
  db 0x4D
  
; GOP
guid_gop:
  dd 0x9042A9DE
  dw 0x97DC
  dw 0x42AF
  db 0xB6
  db 0xFA 
  db 0x84 
  db 0xF5 
  db 0xDC
  db 0xE3 
  db 0x27 
  db 0x42

    
; --- Structures ---

; The Main Struct
crucial_struct:
  .image_handle: dq 0
  .system_table: dq 0
  dq framebuffer_gop
  dq acpi_tables
  dq memory_map

; Temporary Framebuffer 
tmp_framebuffer: dq 0 

; Framebuffer
framebuffer_gop:
  address_base: dq 0
  width: dd 0 
  height: dd 0
  scanline_per_pixel: dd 0

; ACPI
acpi_tables:
  xsdt_pointer: dq 0 

; Memory Map 
memory_map:
  buffer_map: dq 0 ; Buffer of Memory Map 
  map_size: dd 0 ; Memory Map Size 
  map_key: dd 0 ; Memory Map Key 
  descriptor_size: dd 0 ; Memory Map Descriptor Size 
  descriptor_version: dd 0; Memory Map Descriptor Version

; Kernel Parameter 
kernel_boot_info:
  dq crucial_struct

; Messages 
messages:
  ; Main Message
  hello_msg:
    dw 'L','O','A','D','I','N','G','.','.','.',0,0
  ; Error Message
  error_msg:
    dw 'E','R','R','O','R','!',0,0