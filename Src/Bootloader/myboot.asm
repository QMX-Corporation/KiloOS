; SPDX-License-Identifier: GPL-2.0-only 


%INCLUDE% "myboot_header.asm"

[BITS 64]
default rel 
org 0x400000 

; Entry in .text 
align 0x1000 

; EFI Main 
efi_main:
  ; Shadow Space, Align 16 Bytes 
  sub rsp, 64 
  ; ImageHandle and System Table 
  mov rax, rcx ; Image Handle 
  mov [crucial_struct.image_handle], rax 
  mov rbx, rdx ; System Table 
  mov [crucial_struct.system_table], rbx

; Entry in .data 
align 0x2000 
; Structures 
crucial_struct:
  image_handle: dq 0
  system_table: dq 0