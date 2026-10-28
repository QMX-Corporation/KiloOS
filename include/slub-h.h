// SPDX-License-Identifier: GPL-2.0-Only 
/* 
   This file is Kernel Header. 
   Development under 0.1 Version: 2026-2028, QMX Corporation.
   Enginner: João <joaoanandalima@gmail.com>
 */

#ifndef __SLUB_CACHE_H_H
#define __SLUB_CACHE_H_H

#ifndef __SLAB_CACHE 
  #include <KiloOS/slab.h>
#endif

#ifndef __SLAB_FLAGS_
  #define __SLAB_ERROR -450 
  #define __SLAB_SUCCESS 0
#endif 

#ifndef __SLAB_MACROS_
  int err_slab = __SLAB_ERROR;
  int succ_slab = __SLAB_SUCCESS;
#endif






#endif