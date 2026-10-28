// SPDX-License-Identifier: GPL-2.0-Only 
/* 
   This file is Kernel Header. 
   Development under 0.1 Version: 2026-2028, QMX Corporation.
   Enginner: João <joaoanandalima@gmail.com>
 */

#ifndef __SCHEDULER_H
#define __SCHEDULER_H

/* Libs */ 
#include <KiloOS/mm.h>

/* Macros */
#define __SCHED_ERROR_PAGE 0x000000000000200
#define __SCHED_ERROR_PROCESS 0x45670000000
#define __SCHED_SUCCESS 0


/* Basic Types */
typedef unsigned char u8; /* 8 Bits no signal */
typedef unsigned short u16; /* 16 Bi ts no signal */
typedef unsigned int u32; /* 32-bit no signal */
typedef unsigned long long u64; /* 64-bit no signal */

/* Area Types Structure */
enum __vm_area_type {
  HW_ACPI_TABLES, /* area_type = 0 */
  HW_MOTHERBOARD_AREA, /* area_type = 1 */
  HW_EFI_AREA, /* area_type = 2 */
  AREA_KERNEL_DATA, /* area_type = 3 */
  AREA_PROGRAM_DATA /* area_type = 4 */
};

/* Program State Structure */
enum __program_state {
  PROCESS_RUNNING, /* Running */
  PROCESS_IO_BLOCKED, /* Blocked, but run in a I/O Action */
  PROCESS_BLOCKED, /* Blocked */
  PROCESS_WAITING, /* Waiting */
  PROCESS_WAITING_EVENT /* Waiting to a Specific Events */
};


/* Tree Tables Memory Page */
typedef struct {
  u64 *pgd;
  u64 *p4d;
  u64 *pud;
  u64 *pmd;
  u64 *pte;
} __attribute__((aligned(4096), packed)) __memory_tree;

/* Atual Context Structure */
typedef struct {
  /* Register Files */
  u64 rax;
  u64 rbx;
  u64 rcx;
  u64 rdx;
  u64 rsi;
  u64 rdi;
  /* Stack */
  u64 rsp;
  /* Additional Registers */
  u64 r8;
  u64 r9;
  u64 r10;
  u64 r11;
  u64 r12;
  u64 r13;
  u64 r14;
  u64 r15;
  /* Instruction Pointer */
  u64 rip;
  /* Flags */
  u64 rflags;
  /* CR3 */
  u64 cr3;
} __attribute__((aligned(4096), packed)) atual_context;


/* Memory Program Structure */
typedef struct {
  u64 address_base_virtual;
  u64 address_base_physics;
  u32 area_type;
  u64 uuid_type[5];
  __memory_tree *tree_tables; /* Example: PTE */
  u64 *pt_pointer; /* Page Table (MMU) Pointer */
  atual_context *context;
} __attribute__((aligned(4096), packed)) memory_program;

/* Atual Current */
typedef struct {
  memory_program *mm;
  u64 time_slice; /* Restant Time Quantum */
  u32 priority; /* Priority */
} __attribute__((aligned(4096), packed)) current;

/* Next Current */
typedef struct {
  memory_program *mm;
  u64 time_slice; /* Restant Time Quantum */
  u32 priority; /* Priority */
} __attribute__((aligned(4096), packed)) next_current;


/* Switch all pages */
int switch_pages(current *atual);

/* Switch the selecioned page 
   Notes:
     In second argument, please uses 
     page divided per PAGE_SIZE (page / PAGE_SIZE) 
 */
int switch_page(current *atual, u64 page);

/* Switch the process */
int switch_current(
     current *atual,
     next_current *next,
  );




/* End */
#endif /* __SCHEDULER_H */