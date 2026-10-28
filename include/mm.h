// SPDX-License-Identifier: GPL-2.0-Only 
/* 
   This file is Kernel Header. 
   Development under 0.1 Version: 2026-2028, QMX Corporation.
   Enginner: João <joaoanandalima@gmail.com>
 */

#ifndef __MEMORY_H
#define __MEMORY_H

/* Libs */
#include <KiloOS/slab.h>
#include <KiloOS/slub-h.h>

/* Types under MMU */
#define PAGE_SIZE 4096 
#define PAGE_SUPERVISOR (0ULL << 2)
#define PAGE_USER (1ULL << 2)
#define PAGE_RW (1ULL << 1) 
#define PAGE_SIZE_4KB (0ULL << 7)
#define PAGE_PRESENT (1ULL << 0)
#define PAGE_SIZE_2MB (1ULL << 7)
#define PAGE_RW_PRESENT (PAGE_RW | PAGE_PRESENT)

/* Buddy Allocator */
#define MAX_BUDDY_ORDER 512
typedef struct buddy_node {
  struct buddy_node *next;
} __attribute__((packed)) buddy_node_t;
typedef struct {
  buddy_node_t *buddy[MAX_BUDDY_ORDER];
  u64 total_memory;
  u64 *allocated_memory;
} __attribute__((aligned(8), packed)) buddy_t;


/* 1 = true, 0 = false */
int is_paging; 

/* Basic Types */
typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

/* PLM4 Table */
typedef struct {
  u64 entries[512];
} __attribute__((aligned(4096), packed)) plm4_t;

/* PD Table */
typedef struct {
  u64 entries[512];
} __attribute__((aligned(4096), packed)) pd_t;

/* PT Table */
typedef struct {
  u64 entries[512];
} __attribute__((aligned(4096), packed)) pt_t;

/* PTE Table */
typedef struct {
  u64 entries[512];
} __attribute__((aligned(4096), packed)) pte_t;

/* PUD Table */
typedef struct {
  u64 entries[512];
} __attribute__((aligned(4096), packed)) pud_t;

/* PGD Table */
typedef struct {
  u64 entries[512];
} __attribute__((aligned(4096), packed)) pgd_t;

/* PMD Table */
typedef struct {
  u64 entries[512];
} __attribute__((aligned(4096), packed)) pmd_t;

/* PDPT Table */
typedef struct {
  u64 entries[512];
} __attribute__((aligned(4096), packed)) pdpt_t;


/* VMA Structure Table */
typedef struct {
  /* Virtual Base Address (VBA) */
  u64 virtual_address_initial;
  u64 virtual_address_final;
  /* Access Permission */
  u32 read; /* 1 = Is permited read 0 = no is permited read */
  u32 write; /* 1 = Is permited write 0 = no is permited write */
  u32 execution; /* 1 = Execution permited 0 = Execution no permited */
  u32 privilege_restrition; /* 1 = Privilege Restrition 0 = No Privilege Restrition */
  /* Type */
  u64 type; /* Example: Program Section, Kernel Area */
  /* --- Structures --- */
  pml4_t *plm4; 
  pd_t *pd;
  pt_t *pt;
  pte_t *pte;
  pud_t *pud;
  pgd_t *pgd;
  pmd_t *pmd;
  pdpt_t *pdpt;
} __attribute__((aligned(4096), packed)) vma_struct_t;


/* Initializer */
int __init_paging(vma_struct_t *vma);


/* Allocators */
int plm4_alloc(u64 address, u64 size, u64 *ptr);
int pd_alloc(u64 address, u64 size, u64 *ptr);
int pt_alloc(u64 address, u64 size, u64 *ptr);
int pte_alloc(u64 address, u64 size, u64 *ptr);
int pud_alloc(u64 address, u64 size, u64 *ptr);
int pgd_alloc(u64 address, u64 size, u64 *ptr);
int pmd_alloc(u64 address, u64 size, u64 *ptr);
int pdpt_alloc(u64 address, u64 size, u64 *ptr);
int kalloc(u64 size, u64 address);
int kcalloc_t(u64 size, u64 *table, u64 address);
int k_create_cache(u64 size, u64 align, u64 *ptr_return);
int k_create_buffer(u64 size, u64 align, u64 *ptr_return);

/* Free-Memory (I called this of Freers or 
   desallocator/desllocator) 
 */
int plm4_free(u64 address, u64 size, u64 *ptr);
int pd_free(u64 address, u64 size, u64 *ptr);
int pt_free(u64 address, u64 size, u64 *ptr);
int pte_free(u64 address, u64 size, u64 *ptr);
int pud_free(u64 address, u64 size, u64 *ptr);
int pgd_free(u64 address, u64 size, u64 *ptr);
int pmd_free(u64 address, u64 size, u64 *ptr);
int pdpt_free(u64 address, u64 size, u64 *ptr);
int kfree(u64 size, u64 address);
int kcfree_t(u64 size, u64 table, u64 address);

/* --- Handlers --- */
int m_handling_core();
int page_fault_handler();
int double_fault_handler();


#endif /* __MEMORY_H */