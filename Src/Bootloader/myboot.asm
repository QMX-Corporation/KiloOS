; SPDX-License-Identifier: GPL-2.0-only 


%include "myboot_header.asm"

[BITS 64]
default rel 
org 0x400000 

; Entry in .text 
align 0x1000 

; ==============================================================================
; Macro: Parse and Open Path Sequentially in UEFI
; Inputs:
;   %1 - Current Directory Protocol Pointer (e.g., root_directory)
;   %2 - Pointer to Null-Terminated Path String (e.g., path_string)
;   %3 - Address of UEFI Boot Services Table
;   %4 - Destination Buffer to Store Final EFI_FILE_PROTOCOL*
; ==============================================================================
%macro PARSE_AND_OPEN_PATH 4
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    mov rsi, %2                 ; RSI points to our string path
    mov rdi, [%1]               ; RDI holds the starting directory handle (e.g., Root)
.path_loop:
    mov al, byte [rsi]
    test al, al                 ; Check if we reached the end of the string (null terminator)
    jz .path_done
    ; Search for next slash '/' or end of string
    mov rbx, rsi                ; RBX marks the start of the current token/folder name
.find_slash:
    mov al, byte [rbx]
    cmp al, 0
    je .process_token
    cmp al, '/'                 ; Did we find a path separator?
    je .found_slash
    inc rbx
    jmp .find_slash
.found_slash:
    mov byte [rbx], 0           ; Temporarily replace '/' with 0 to null-terminate the folder name string
.process_token:
    ; Prepare arguments for EFI_FILE_PROTOCOL->Open()
    ; RCX = Current Directory Handle
    ; RDX = Output New File Handle Address
    ; R8  = Null-terminated Unicode/ASCII path string pointer (Folder name)
    ; R9  = Open Mode (EFI_FILE_MODE_READ = 0x0000000000000001)
    ; [RSP+32] = Attributes (0 for normal folders)
    mov rcx, rdi                ; Current directory handle
    lea rdx, [%4]               ; Destination pointer for opened sub-handle
    mov r8, rsi                 ; Pointer to the current folder name string
    mov r9, 1                   ; EFI_FILE_MODE_READ
    mov qword [rsp + 32], 0     ; Attributes (None)
    ; Call Open() function located at offset 0x00 of EFI_FILE_PROTOCOL table
    mov rax, [rdi]              ; Get protocol interface pointer
    call qword [rax + 0x00]     ; EFI_FILE_PROTOCOL->Open()
    ; Check if Open was successful (RAX == 0 means EFI_SUCCESS)
    test rax, rax
    jnz .path_error             ; Handle error if path lookup fails
    ; Update current directory handle to the newly opened sub-handle
    mov rdi, [%4]
    ; Restore the slash if we replaced it, and advance pointer
    cmp byte [rbx], 0
    je .path_done
    mov byte [rbx], '/'         ; Restore original slash
    mov rsi, rbx                ; Move pointer past the processed token
    inc rsi                     ; Skip the slash
    jmp .path_loop

.path_done:
    ; Final directory handle successfully reached target!
    jmp .path_exit

.path_error:
    ; Error handling routine placeholder (e.g., trigger crash or error message)
    nop

.path_exit:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

; ==============================================================================
; Macro: Open Kernel File, Read Header, and Verify JSFS Signature
; Inputs:
;   %1 - Source Directory Handle Pointer (e.g., final_loader_dir_handle)
;   %2 - Pointer to File Name String (Unicode/UTF-16, e.g., name_loader_kernel)
;   %3 - Destination Buffer Pointer for File Handle (e.g., loader_kernel_file)
;   %4 - Destination Buffer Pointer for Header Data (e.g., header_buffer)
;   %5 - Bytes to Read (e.g., 1024)
; ==============================================================================
%macro OPEN_AND_READ_KERNEL 5
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    push rsi
    ; Step 1: Open the file using EFI_FILE_PROTOCOL->Open()
    mov rbx, [%1]               ; RBX holds the parent directory handle
    mov rcx, rbx                ; RCX = Parent directory handle
    lea rdx, [%3]               ; RDX = Pointer to output file handle variable
    mov r8, %2                  ; R8 = Pointer to file name string (UTF-16)
    mov r9, 1                   ; R9 = EFI_FILE_MODE_READ (1)
    mov qword [rsp + 32], 0     ; Attributes = 0 (Normal file)
    mov rax, [rbx]              ; Get protocol interface pointer from directory handle
    call qword [rax + 0x00]     ; Call Open() function (offset 0x00)
    test rax, rax               ; Check if return status is EFI_SUCCESS (0)
    jnz .error_handler
    ; Step 2: Read the file header using EFI_FILE_PROTOCOL->Read()
    mov rbx, [%3]               ; RBX holds the opened file handle
    mov rcx, rbx                ; RCX = File handle
    lea rdx, [%5]               ; RDX = Pointer to variable holding bytes to read (Input/Output size)
    lea r8, [%4]                ; R8 = Destination buffer pointer where header will be stored
    mov rax, [rbx]              ; Get file protocol interface pointer
    call qword [rax + 0x08]     ; Call Read() function (offset 0x08)
    test rax, rax               ; Check if return status is EFI_SUCCESS (0)
    jnz .error_handler
    ; Step 3: Verify Exact JSFS Signature Bytes ('J', 'S', 'F', 'S', 34, 24, 0, 0, 0)
    lea rsi, [%4]               ; RSI points to our header buffer
    ; Check 'J', 'S', 'F', 'S' (4 bytes: 0x4A534653)
    mov eax, dword [rsi]
    mov edx, 0x5346534A         ; Little-endian representation of 'JSFS' ('J'=4A, 'S'=53, 'F'=46, 'S'=53 -> 0x5346534A)
    cmp eax, edx
    jne .error_handler
    ; Check next bytes: 34, 24, 0, 0 (4 bytes: 0x00001822 -> 34=0x22, 24=0x18)
    mov eax, dword [rsi + 4]
    mov edx, 0x00001822
    cmp eax, edx
    jne .error_handler
    jmp .kernel_success
.error_handler:
    ; Handle signature verification failure or file read/open errors
    ; You can trigger an infinite loop or point to error_msg here
    cli
    hlt
.kernel_success:
    pop rsi
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

; ==============================================================================
; Macro: Get File Info, Read Full Kernel Binary, and Resolve Entry Point
; Inputs:
;   %1 - File Handle Pointer (e.g., loader_kernel_file)
;   %2 - Destination Memory Buffer Pointer (e.g., memory_map.buffer_map)
;   %3 - Header Buffer Pointer containing the offset (e.g., header_buffer)
;   %4 - Variable to Store/Update Kernel File Size (e.g., kernel_file_size)
;   %5 - File Info Buffer Pointer (e.g., file_info_buffer)
;   %6 - File Info Buffer Size Pointer (e.g., file_info_size)
; ==============================================================================
%macro READ_KERNEL_AND_PREPARE_JUMP 6
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    push rsi
    ; Step 1: Call GetInfo() (offset 0x38) to query exact file size dynamically
    mov rbx, [%1]               ; RBX holds the opened kernel file handle
    mov rcx, rbx                ; RCX = File handle
    lea rdx, [rel info_f_guid]  ; RDX = EFI_FILE_INFO GUID pointer
    lea r8, [%6]                ; R8 = Pointer to size of info buffer
    lea r9, [%5]                ; R9 = Destination buffer pointer for file info
    mov rax, [rbx]              ; Get file protocol interface pointer
    call qword [rax + 0x38]     ; Call GetInfo() function (offset 0x38)
    test rax, rax
    jnz .jump_error
    ; Step 2: Extract FileSize from EFI_FILE_INFO structure (offset +8)
    lea rsi, [%5]               ; RSI points to file_info_buffer
    mov rax, qword [rsi + 8]    ; FileSize is at offset 8 of EFI_FILE_INFO
    mov [%4], rax               ; Update kernel_file_size with the exact size in bytes
    ; Step 3: Read the full kernel binary into the allocated memory buffer
    mov rcx, rbx                ; RCX = File handle
    lea rdx, [%4]               ; RDX points to the updated kernel_file_size variable
    mov r8, [%2]                ; R8 = Destination buffer pointer (allocated by AllocatePages)
    mov rax, [rbx]              ; Get file protocol interface pointer
    call qword [rax + 0x08]     ; Call Read() function (offset 0x08)
    test rax, rax               ; Check if EFI_SUCCESS (0)
    jnz .jump_error
    ; Step 4: Extract the Main Function Offset/Pointer from header buffer (offset 0x209)
    lea rsi, [%3]               ; RSI points to header_buffer
    mov r10, qword [rsi + 0x209] ; Load the main function pointer/offset into R10
    ; Step 5: Calculate absolute entry address (Allocated Buffer Base + Function Offset)
    mov rax, [%2]               ; Get base address of allocated pages
    add rax, r10                ; Add function offset
    mov [final_kernel_entry], rax ; Store final absolute jump/execution address
    jmp .jump_success
.jump_error:
    cli
    hlt
.jump_success:
    pop rsi
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro


    
    


; --- Loader Kernel ---
load_kernel:
  ; 1. SystemTable 
  mov rax, [rcx + 0x08] 
  ; 2. BootServices 
  mov rbx, [rax + 0x60]
  mov [rsp + 32], rbx
  ; 3. Call EFI_SIMPLE_FILE_SYSTEM_PROTOCOL
  mov rcx, [rcx + 0x00]; ImageHandle  
  lea rdx, [rel guid_fs] ; File System GUID 
  lea r8, [struct_fs.address] ; Address for store 
  call qword [rbx + 0x100] ; HandleProtocol(image_handle, guid, address)
  ; 4. Call OpenVolume 
  mov rcx, [struct_fs.address] ; The Address
  lea rdx, [rel root_directory] ; Root Directory 
  call qword [rbx + 0x00] ; OpenVolume(FileSysProtocol, &RootDirectory)
  ; 5. Entry in /sys/kernel/__boot/loader/
  PARSE_AND_OPEN_PATH root_directory, path_to_loader, rbx, final_loader_dir_handle
  ; 6. Open File and verify Signature 
  OPEN_AND_READ_KERNEL final_loader_dir_handle, name_loader_kernel, loader_kernel_file, header_buffer, 1024 
  ; 7. Load the Kernel in Allocated Memory of AllocatePages()
  READ_KERNEL_AND_PREPARE_JUMP loader_kernel_file, memory_map.buffer_map, header_buffer, kernel_file_size, file_info_buffer, file_info_size

  



  
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
  ; AllocPages() 
  call qword [rcx + 0x28]
  ; 6. Load kiloos-krnl.pxe 
  lea rcx, [rel crucial_struct] ; Crucial Struct 
  call load_kernel ; load_kernel(kmain_boot_info *crucialStruct)
  ; 7. ExitBootServices with Retry Loop
  jmp .exit_boot_services 
.exit_boot_services:
  mov rcx, [crucial_struct.image_handle] ; ImageHandle 
  mov rdx, [memory_map.map_key] ; MapKey 
  call qword [rbx + 0x148] ; ExitBootServices
  ; Test if 0 or no 
  test rax, rax 
  jnz .retry 
  jmp .call_kernel 
  
.retry:
  ; Try GetMemoryMap 
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
  ; Jump to .exit_boot_services
  jmp .exit_boot_services
  
.call_kernel:
  ; Show all informations to 
  ; Kernel 
  lea rcx, [rel kernel_boot_info] 
  ; Jump to kernel function
  call qword [final_kernel_entry]
  



  

  
; --- Entry in .data ---
align 0x2000 

; --- Pointers ---

; ACPI
ptr_acpi: db 0

; --- Variables ---
; File System Protocol 
root_directory: dq 0 
; The Path of Loader 
path_to_loader: db "sys/kernel/__boot/loader", 0
; The Final Directory Opened 
final_loader_dir_handle: dq 0
; Destinatary-Final Variable of Loader Kernel Opened 
loader_kernel_file: dq 0
; Name of Loader Kernel 
name_loader_kernel:
  dw 'k', 'i', 'l', 'o', 'o', 's', '-', 'k', 'r', 'n', 'l', '.', 'p', 'x', 'e',0,0
; Header Buffer 
header_buffer: times 1024 db 0
; Kernel EntryPoint
final_kernel_entry: dq 0
; Kernel File Size
kernel_file_size: dq 16384
; File Info Buffer & Size
file_info_buffer: times 512 db 0
file_info_size:   dq 512

  



  


  

  
; --- GUIDs ---
; FileInfo 
info_f_guid:
  dd 0x09576E92
  dw 0x6D3F
  dw 0x11D2
  db 0x8E, 0x39, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B
; File System Protocol 
guid_fs:
  dd 0x0964EB5B
  dw 0x43FE
  dw 0x11D3
  db 0x83, 0xEE, 0x00, 0xC0, 0x4F, 0xD4, 0x30, 0x1B
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
; A Small Structure for store the Interface Protocol 
struct_fs:
  address: dq 0 
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