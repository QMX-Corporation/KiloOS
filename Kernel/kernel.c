// SPDX-License-Identifier: GPL-2.0-Only 
/* 
   * The Main File.  
   *
   * Engineer: João <joaoanandalima@gmail.com>
   * Development under 0.1 Version: 2026-2028
   *
   * QMX Corporation
 */

#include <KiloOS/mm.h>
#include <KiloOS/scheduler.h>
#include <KiloOS/init-rs.h>
#include <KiloOS/slab.h>
#include <KiloOS/slub-h.h>
#include <KiloOS/idt.h>
#include <KiloOS/gdt.h>
#include <KiloOS/kernel.h>

typedef struct {
  const char *Signature = "JSFS/34/24/0/0/0";
  const char *Version = "0.1-rc";
  const char *License = "GPL-2.0-Only";
} pxeStructure;
extern __attribute__((used, aligned(4096), section("pxe"))) pxeStructure pxeSection;

vna_struct_t *vma;
/*  
   * Kernel Main 
   *
   * @param kinfo: Access hardware info.
   * 
   * A Exanple of commit: 'kmain: fix: framebuffer access (switch | to a secure access with optimized loop)'
   *
   * 
 */
void kmain(kernel_t *kinfo) 
{
   if (unlikely(!kinfo)) 
       return;

   int status;
   status = __init_paging(vma);
   if (status <= 0) 
       return;

   while (true) {
     
   }
}