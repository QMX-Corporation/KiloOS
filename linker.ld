ENTRY(kmain)
SECTIONS 
{
   . = 0xFFFF8000000000;
   .pxe_header ALIGN(4K) : {
     *(.pxe)
   }
   .text ALIGN(4K) : {
      *(.text)
      *(.text.)
      *(.text.*)
   }
   .data ALIGN(4K) : {
     *(.data)
     *(.data.)
     *(.data.*)
   }
   .rodata ALIGN(4K) : {
     *(.rodata)
     *(.rodata.)
     *(.rodata.*)
   }
   .bss ALIGN(4K) : {
     *(.bss)
     *(.bss.)
     *(.bss.*)
   }
   
}