# GAS assembler macros for NaCl x86-32

.bundle_align_mode 5

.macro nacljmp reg
	.bundle_lock
	and $-32, \reg
	jmp *\reg
	.bundle_unlock
.endm

.macro naclcall reg
	.bundle_lock
	and $-32, \reg
	_nacl_call_wrapper call *\reg
	.bundle_unlock
	.p2align 5
.endm

.macro nacl_direct_call target
	_nacl_call_wrapper call \target
	.p2align 5
.endm

.macro nacl_indirect_call target:vararg
	movl \target, %ecx
	naclcall %ecx
.endm

.macro nacl_literal_call target
	_nacl_call_wrapper call \target
.endm

.macro _nacl_rounded_jmp reg
	add $31, \reg
	nacljmp \reg
.endm

.macro naclret reg=%ecx
	pop \reg
	_nacl_rounded_jmp \reg
.endm

.macro naclret_pop bytes, reg=%ecx
	pop \reg
	add \bytes, %esp
	_nacl_rounded_jmp \reg
.endm

.macro _nacl_define_call
	.macro call target
		.error "Unadorned call instruction used"
	.endm
.endm

.macro _nacl_call_wrapper insn:vararg
	.purgem call
	\insn
	_nacl_define_call
.endm

	_nacl_define_call

.macro ret
	.error "ret instruction cannot be used under Native Client"
.endm

# XXX get rid of this and its uses in newlib .S files
NACLENTRYALIGN = 5

.pushsection .note.NaCl.ABI.x86-32, "aG", %note, .note.NaCl.ABI.x86-32, comdat
	.int 1f - 0f, 3f - 2f, 1
	.balign 4
0:	.string "NaCl"
1:	.balign 4
2:	.string "x86-32"
3:	.balign 4
.popsection
