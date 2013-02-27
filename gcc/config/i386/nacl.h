/* Definitions for Intel 386 running Native Client.
   Copyright (C) 2012-2013 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3, or (at your option)
any later version.

GCC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

Under Section 7 of GPL version 3, you are granted additional
permissions described in the GCC Runtime Library Exception, version
3.1, as published by the Free Software Foundation.

You should have received a copy of the GNU General Public License and
a copy of the GCC Runtime Library Exception along with this program;
see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
<http://www.gnu.org/licenses/>.  */

/* Use %(subtarget_cpp_spec), which is set by config/nacl.h for common
   definitions across all NaCl targets.  */
#undef	SUBTARGET_EXTRA_SPECS
#define SUBTARGET_EXTRA_SPECS \
  { "subtarget_cpp_spec",	SUBTARGET_CPP_SPEC },

#undef  CPP_SPEC
#define CPP_SPEC "%(subtarget_cpp_spec)"

/* Instruction bundles have this size and at least this alignment.  */
#define NACL_X86_BUNDLE_ALIGN	32

#undef	FUNCTION_BOUNDARY
#define FUNCTION_BOUNDARY       (NACL_X86_BUNDLE_ALIGN * BITS_PER_UNIT)

/* Do NaCl-specific parts of TARGET_OPTION_OVERRIDE.  */
#undef SUBTARGET_OVERRIDE_OPTIONS
#define SUBTARGET_OVERRIDE_OPTIONS                                      \
  do {                                                                  \
    if (TARGET_64BIT)                                                   \
      error ("Native Client 64-bit code generation not yet supported"); \
    target_flags &= ~MASK_TLS_DIRECT_SEG_REFS;                          \
    target_flags |= MASK_SFI_CFLOW_NACL1;                               \
    target_flags |= MASK_ALIGN_DOUBLE;                                  \
    target_flags |= MASK_LONG_DOUBLE_64;                                \
    NACL_MIN_ALIGN (TARGET_SFI_CFLOW_NACL1, NACL_X86_BUNDLE_ALIGN);     \
  } while (0)

#undef  CRT_CALL_STATIC_FUNCTION
#define CRT_CALL_STATIC_FUNCTION(SECTION_OP, FUNC)              \
   asm (SECTION_OP "\n\t"                                       \
	"nacl_direct_call " CRT_MKSTR(__USER_LABEL_PREFIX__) #FUNC "\n" \
	TEXT_SECTION_ASM_OP);

#ifndef __PIC__
# undef CRT_GET_RFIB_DATA
# define CRT_GET_RFIB_DATA(BASE)                                        \
  __asm__ ("nacl_literal_call\t.LPR%=\n"                                \
	   ".LPR%=:\n\t"                                                \
	   "pop{l}\t%0\n\t"                                             \
	   /* Due to a GAS bug, this cannot use EAX.  That encodes      \
	      smaller than the traditional EBX, which results in the    \
	      offset being off by one.  */                              \
	   "add{l}\t{$_GLOBAL_OFFSET_TABLE_+[.-.LPR%=],%0"              \
		   "|%0,_GLOBAL_OFFSET_TABLE_+(.-.LPR%=)}"              \
	   : "=d"(BASE))
#endif

#define GNU_USER_LINK_EMULATION         "elf_i386_nacl"
#define GNU_USER_DYNAMIC_LINKER         "/lib/ld-nacl-x86-32.so.1"

/* We feed the file of standard assembler macros as an extra input file
   before the actual assembly code.  This file will be installed in some
   place like ${tool_prefix}/lib/.  */
#undef ASM_SPEC
#define ASM_SPEC        \
  ASM_SPEC_BASE " nacl-i386-macros.s%s"
#define ASM_SPEC_BASE \
  "--32 %{!mno-sse2avx:%{mavx:-msse2avx}} %{msse2avx:%{!mavx:-msse2avx}}"
