// SPDX-License-Identifier: GPL-2.0-Only 
/* 
   This file is Kernel Header. 
   Development under 0.1 Version: 2026-2028, QMX Corporation.
   Enginner: João <joaoanandalima@gmail.com>
 */

#ifndef __KERNEL__HEADER_
#define __KERNEL__HEADER_

/* Libs */
#include <KiloOS/init-rs.h>
#include <KiloOS/mm.h>
#include <KiloOS/scheduler.h>
#include <KiloOS/slab.h>
#include <KiloOS/slub-h.h>

/* Basic Types */
typedef unsigned char u8; /* 8 Bits no signal */
typedef unsigned short u16; /* 16 Bits no signal */
typedef unsigned int u32; /* 32-bit no signal */
typedef unsigned long long u64; /* 64-bit no signal */
u64 *__kernel_type;


/* Framebuffer */
typedef struct {
  u64 address;
  u32 width;
  u32 height;
  u32 scanline;
} __attribute__((aligned(4096), packed)) __framebuffer;


/* ACPI Table */
typedef struct {
  u64 xsdt;
} __attribute__((aligned(4096), packed)) __acpi_tables;


/* Memory map */
typedef struct {
  u64 buffer_map;
  u32 map_size;
  u32 map_key;
  u32 descriptor_size;
  u32 descriptor_version;
} __attribute__((aligned(4096), packed)) __memory_map;


/* Kernel Boot Info Structure */
typedef struct {
  u64 image_handle; /* Is ignored */
  u64 system_table; /* Is ignored */
  __framebuffer *framebuffer;
  __acpi_tables *xsdtAddress;
  __memory_map  *memory_map;
} __attribute__((aligned(4096), packed)) kernel_struct;

/* Kernel Table */
typedef struct {
  kernel_struct *kinfo;
} __attribute__((aligned(4096), packed)) kernel_t;

/* Allocator dedicated to 
   alloc pages for Kernel 
 */
int kalloc_kernel(
  vma_struct_t *vma, 
  u64 address, 
  u64 size
);

/* Kernel Main */
void kmain(kernel_t *kinfo);


#endif