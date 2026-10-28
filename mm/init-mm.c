// SPDX-License-Identifier: GPL-2.0-Only 
/* 
  Memory Initializer.
  Engineer: João <joaoanandalima@gmail.com>
  Development in 0.1 version: 2026-2028 
  QMX Corporation 
 */

#include <KiloOS/mm.h>
buddy_t kernel_buddy;


/* 
   * Main Allocator 
   *
   * @param size: The Size 
   * @param address: Address
   *
   * A Commit Example: 'alloc: kernel: I fix in init-mm.c a typo - existance to existence'
   *
   *
 */
int kalloc(u64 size, u64 address) 
{
  if (unlikely(!size) || unlikely(!address)) 
    return -102;
  

  /* Paging desactived */
  if (is_paging == 0) {
    static u64 next_free_addr = 0x100000;
    u64 *out_ptr = (u64 *)address;
    *out_ptr = next_free_addr;
    next_free_addr += PAGE_SIZE;
    return 0;
  }

  /* Paging actived */
  if (is_paging == 1) {
    u64 pages = (size + PAGE_SIZE - 1) >> 12;
    if (pages == 0) pages = 1; 
    int order = 63 - __builtin_clzll(pages);
    if ((pages & (pages - 1)) != 0)
        order++;
    u64 curr_order = order;
    while (curr_order < MAX_BUDDY_ORDER && kernel_buddy.buddy[curr_order] == NULL) {
      curr_order++;
    }
    if (curr_order < MAX_BUDDY_ORDER && kernel_buddy.buddy[curr_order] != NULL) {
      u64 block_current = (PAGE_SIZE << curr_order);
      u64 block_addr = (u64)kernel_buddy.buddy[curr_order];
      u64 buddy_address = block_addr ^ block_current;
      kernel_buddy.buddy[curr_order] = kernel_buddy.buddy[curr_order]->next;
      while (curr_order > order) {
        curr_order--;
        u64 atual_block_current = block_current;
        u64 div = atual_block_current / 2;
        block_current = div;
        buddy_address = block_addr ^ block_current;
        buddy_node_t *buddy_node = (buddy_node_t *)buddy_address;
        buddy_node->next = kernel_buddy.buddy[curr_order];
        kernel_buddy.buddy[curr_order] = buddy_node;
      }
      u64 *out = (u64 *)address;
      *out = block_addr;
      return (int)out;
    }
  }
}

/* 
  * Table Allocator
  * 
  * @param size: Size 
  * @param *table: To alloc table 
  * @param address: The initial address of table 
  *
  * Commit Example: 'kalloc: table: remove casts and switch int to u64'
 */
int kcalloc_t(u64 size, u64 *table, u64 address) 
{
  if (unlikely(!size) || unlikely(!table) || unlikely(!address)) 
    return -102;

  // Allocate raw memory block using the buddy allocator
  u64 phys_addr = 0;
  int status = kalloc(size, (u64)&phys_addr);
  if (status < 0)
    return status;

  // Zero-initialize the newly allocated table structure to clear all descriptors
  u64 *table_ptr = (u64 *)phys_addr;
  u64 entries_count = size / sizeof(u64);
  for (u64 i = 0; i < entries_count; i++) {
    table_ptr[i] = 0;
  }

  // Return the pointer of the structure through the output parameter
  *table = phys_addr;
  
  return (int)phys_addr;
}


/* 
  * PDPT Allocator 
  *
  * @param address: Address.
  * @param size: Size.
  * @param *ptr: To return.
  *
  * Commit example: 'pdpt: remove casts and switch int to u64'
  *
  *
 */
int pdpt_alloc(u64 address, u64 size, u64 *ptr) 
{
  if (unlikely(!address) || unlikely(!size) || unlikely(!ptr))
      return -102;

  int *pdpt = kcalloc_t(size, ptr, address);
  if ((int)pdpt < 0) 
      return (int)pdpt;

  return (int)pdpt;
}

/* 
  * PD Allocator 
  * 
  * @param address: Address.
  * @param size: Size.
  * @param *ptr: To return.
  *
  * Commit Example: 'pd: remove truncs, removing the casts and switch int to u64 in function type'
  *
  *
 */
int pd_alloc(u64 address, u64 size, u64 *ptr) 
{
  if (unlikely(!address) || unlikely(!size) || unlikely(!ptr)) 
      return -102;

  int *pd = kcalloc_t(size, ptr, address);
  if ((int)pd < 0) 
      return (int)pd;

  return (int)pd;
}

/* 
  * PT Allocator
  * 
  * @param address: Address.
  * @param size: Size.
  * @param *ptr: To return.
  * 
  * Commit Example: 'pt: remove truncs, removing the casts and switch int to u64 in function type'
  *
  *
 */
int pt_alloc(u64 address, u64 size, u64 *ptr) 
{
  if (unlikely(!address) || unlikely(!size) || unlikely(!ptr)) 
      return -102;

  int *pt = kcalloc_t(size, ptr, address);
  if ((int)pt < 0) 
      return (int)pt;

  return (int)pt;
}

/* 
  * Initializing Paging under Kernel 
  * 
  * @param *vma: To mapping Virtual Addresses 
  *
  * Commit Example: 'paging: add higher-half mapping in __init_paging using Assembly Inline and Optimized Loop'
  *
  *
 */
int __init_paging(vma_struct_t *vma) 
{
  if (unlikely(!vma)) 
     return -102;

  
  for (u64 i = vma->virtual_address_initial; i <= vma->virtual_address_final; i += PAGE_SIZE) {
       u64 plm4_index = (i >> 39) & 0x1FF;
       u64 pdpt_index = (i >> 30) & 0x1FF;
       u64 pd_index = (i >> 21) & 0x1FF;
       u64 pt_index = (i >> 12) & 0x1FF;
       u64 page_offset = (i >> 0) & 0xFFF;
       /* PLM4 Exists */
       if ((vma->plm4->entries[plm4_index] & PAGE_PRESENT) == 0) {
         u64 pdpt_addr; 
         pdpt_alloc(0xFFFF800000ULL, PAGE_SIZE, &pdpt_addr);
         vma->plm4->entries[plm4_index] = pdpt_addr | PAGE_RW_PRESENT | PAGE_SUPERVISOR;
       } else {   
         vma->plm4->entries[plm4_index] = PAGE_RW_PRESENT | PAGE_SUPERVISOR;
       }
    
       /* PDPT Exists */  
       if ((vma->pdpt->entries[pdpt_index] & PAGE_PRESENT) == 0) {
          u64 pd_addr; 
          pd_alloc(0xFFFF800000ULL, PAGE_SIZE, &pd_addr);
          vma->pdpt->entries[pdpt_index] = pd_addr | PAGE_RW_PRESENT | PAGE_SUPERVISOR;
       } else {
          vma->pdpt->entries[pdpt_index] = PAGE_RW_PRESENT | PAGE_SUPERVISOR;
       }
    
      /* PD Exists */ 
      if ((vma->pd->entries[pd_index] & PAGE_PRESENT) == 0) {
        u64 pt_addr;
        pt_alloc(0xFFFF800000ULL, PAGE_SIZE, &pt_addr);
        vma->pd->entries[pd_index] = pt_addr | PAGE_RW_PRESENT | PAGE_SUPERVISOR;
      } else {  
        vma->pd->entries[pd_index] = PAGE_RW_PRESENT | PAGE_SUPERVISOR;
      }
    
      /* PT Exists */  
      if ((vma->pt->entries[pt_index] & PAGE_PRESENT) == 0) {
        u64 phys_page_addr;
        kalloc(PAGE_SIZE, &phys_page_addr);
        vma->pt->entries[pt_index] = phys_page_addr | PAGE_RW_PRESENT | PAGE_SUPERVISOR;
     } else {
        vma->pt->entries[pt_index] = PAGE_RW_PRESENT | PAGE_SUPERVISOR;
     }
   }

  __asm__ __volatile__("mov %0, %%cr3"  
            : : "r"(vma->plm4) : "memory");

  is_paging = 1;
  return 0;
}