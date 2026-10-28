// SPDX-License-Identifier: GPL-2.0-Only 
/* 
   This file is Kernel Header. 
   Development under 0.1 Version: 2026-2028, QMX Corporation.
   Enginner: João <joaoanandalima@gmail.com>
 */

#ifndef __SLAB_CACHE
#define __SLAB_CACHE

/* Basic Types */
typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

/* Free List */
enum __FREE_LIST_FLAGS_ALIGN {
  K_ALIGN_CACHE,
  K_SUCCESS_FLAG,
  K_ERROR_FLAG
};
typedef struct {
  u64 size_object;
  u64 *heap;
  int success;
  int error;
  u64 align;
} __attribute__((aligned(4096), packed)) main_free_list;


/* Kernel Memory Cache Structure */
typedef struct {
  main_free_list *list;
} __attribute__((aligned(4096), packed)) kmem_cache;

/* Kernel Slab Allocator */
void *kslab_allocator(u64 size, kmem_cache *cache);

/* Kernel Slab Free */
int kslab_free(u64 size, kmem_cache *cache, u64 *address);



#endif /* __SLAB_CACHE */