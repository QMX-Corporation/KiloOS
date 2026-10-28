// SPDX-License-Identifier: GPL-2.0-Only 
/* 
  Development under 0.1 Version: 2026-2028, QMX Corporation
 */

/* Libs */
#include <KiloOS/slab.h>
#include <KiloOS/slub-h.h>

#define PAGE_SIZE_SLAB 4096


/* 
   * A Helper Function to read caches slab 
   *
   * @param *cache: Access the Kernel Memory Cache 
   * @param *page_address: The Address of Page
   * 
   * A example of commit: 'reader: slab-cache: fix mutex lock and switch the loops for optimized loops and Assembly Inline'
   *
   *
 */
int read_slab_cache(kmem_cache *cache, void *page_address) 
{
  if (unlikely(!cache) || unlikely(!page_address))
     return err_slab;

  u32 obj_size = cache->list->size_object;

  /* 1. Executes a calcle */
  int objects_in_page = PAGE_SIZE_SLAB / obj_size;

  u64 *current;
  u64 *next;
  
  /* 2. Forces syncronize */
  for (int i = 0; i < objects_in_page - 1; i++) {
      current = (u64 *)((u64)page_address + 
                         (i * obj_size));
      next = (u64 *)((u64)page_address + 
                      ((i + 1) * obj_size));

      *current = (u64)next;
  }

  current = (u64 *)((u64)page_address + 
                     ((objects_in_page - 1) * 
                      obj_size));
  *current = 0;

  /* Define the heap to free list start */
  cache->list->heap = (u64 *)page_address;
  
  /* 3. Return */
  return succ_slab; 
}


/* 
   * Allocator to slab 
   *
   * @param size: To alloc size 
   * @param *cache: To access the Kernel Memory Cache 
   *
   * A Example of commit: 'alloc: slab-cache: add alloc new physics page and call read_slab_cache()'
   *
   *
 */
void *kslab_allocator(u64 size, kmem_cache *cache)
{
  if (unlikely(!size) || unlikely(!cache))
     return;

  if (!unlikely(!cache->list->heap))  
     /* Future:  
       alloc new physics page and call 
       read_slab_cache() 
     */
     return (void *)err_slab;

  u64 *allocated_block = cache->list->heap;

  cache->list->heap = (u64 *)(*allocated_block);

  return (void *)allocated_block;
}


/* 
  * Freer/Desallocator
  *
  * @param size: To free size 
  * @param *cache: To access the Kernel Memory Cache 
  * @param *address: The address 
  *
  * A Commit Example: 'free: slab-cache: remove security risks (mailling the Page Faults and Overcommits)'
  *
  *
 */
int kslab_free(u64 size, kmem_cache *cache, u64 *address) 
{
  if (unlikely(!size) || unlikely(!cache))  
    return PAGE_SIZE_SLAB;

  if (size == cache->list->size_object) 
    *address = (u64)cache->list->heap;
    
  else 
    return err_slab;

  return (int)cache->list->heap;
}