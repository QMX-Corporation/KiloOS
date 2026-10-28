// SPDX-License-Identifier: GPL-2.0-Only
/* 
   Scheduler under KiloOS 
   Engineer: João <joaoanandalima@gmail.com>
   Development of 0.1 Version: 2026-2028
   QMX Corporation 
 */

#include <KiloOS/scheduler.h>
#include <KiloOS/mm.h>

/* 
   * Switch all pages 
   * 
   * @param *atual: Current Process.
   * 
   * Commit Example: 'sched: pages: fix the page lock for no system lock im RTOS Mode'
   *
   *
 */
int switch_pages(current *atual) 
{
  if (unlikely(!atual)) 
      return __SCHEDULER_ERROR_PAGE;

  
}


/* 
   * Switch the selecioned page
   * Notes:
   *  In second argument, please uses 
   *  page divided per PAGE_SIZE (page / PAGE_SIZE)
   * 
   * @param *atual: Current Process.
   * @param page: The Page to Switch.
   *
   * Example Commit: 'sched: pages: add a optimized loop using Assembly Inline for RTOS Mode'
   *
   *
 */
int switch_page(current *atual, u64 page) 
{
  if (unlikely(!atual) || unlikely(!page)) 
      return __SCHEDULER_ERROR_PAGE;

  
}

/* 
   * Switch the process 
   * 
   * @param *atual: Current Process.
   * @param *next: Next Process.
   *
   * Commit Example: 'sched: current: add a pause in switch_current for no walk the CPU'
   *
   *
 */
int switch_current(current *atual, next_current *next) 
{
  if (unlikely(!atual) || unlikely(!next)) 
      return __SCHEDULER_ERROR_PROCESS;

  
}