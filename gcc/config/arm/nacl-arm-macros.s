@ GAS assembler macros for NaCl ARM
@ NB: GCC emits code using only a few of these, noted below.
@ TODO(mcgrathr): not really clear if this should live with gcc or elsewhere

@ This turns on instruction bundling in the assembler, with 16-byte bundles.
.bundle_align_mode 4

.macro _sfi_cmask reg
	bic \reg, \reg, #0xC000000F
.endm

.macro _sfi_dmask reg
	bfc \reg, #30, #2
.endm

@ Used in place of bx (indirect jump), no difference but the mnemonic.
@ Note you don't want to use this for return (bx lr), since SFI is not required.
@ NB: GCC output uses this.
.macro sfi_bx reg
	.bundle_lock
	_sfi_cmask \reg
	bx \reg
	.bundle_unlock
.endm

.macro _sfi_bl label, target
	adr lr, \label
	b \target
	.p2align 4
\label\():
.endm

@ Used in place of bl (direct call), no difference but the mnemonic.
@ NB: GCC output uses this.
.macro sfi_bl target
	_sfi_bl .Lsfi.\@, \target
.endm

.macro _sfi_blx label, reg
	adr lr, \label
	.bundle_lock
	_sfi_cmask \reg
	bx \reg
	.bundle_unlock
	.p2align 4
\label\():
.endm

@ Used in place of blx (indirect call), no difference but the mnemonic.
@ NB: GCC output uses this.
.macro sfi_blx target
	_sfi_blx .Lsfi.\@, \target
.endm

@ Just "bx lr" as normal, but for parity we define an alias.
.macro sfi_ret
	bx lr
.endm

@ ldr/str syntax cheat sheet:
@ [Rn, offset] => *(Rn + offset)
@ [Rn, offset]! => *(Rn += offset)
@ [Rn], offset => *Rn, Rn += offset

@ sfi_mem* macros have the feature that they specify each parameter
@ only once.  They all have the form:
@	sfi_mem... opcode value-register, base-register [, ...]
@ opcode		is the normal mnemonic (ldr, str, ldrb, etc.)
@ value-register	is the destination for a load and source for a store
@ 			(i.e. the first operand in normal ARM syntax);
@ base-register		is the base register in the address computation;
@			this is what's touched by the SFI masking instruction

@ For simple register or register+offset cases, e.g.:
@	sfi_mem ldr r0, r1		@ ldr r0, [r1]
@	sfi_mem str r1, r2, #4		@ str r1, [r2, #4]
.macro sfi_mem op, dest, basereg, offset=#0
	.bundle_lock
	_sfi_dmask \basereg
	\op \dest, [\basereg, \offset]
	.bundle_unlock
.endm

@ For "increment before" cases, e.g.:
@	sfi_memib ldr r0, r1, #4	@ ldr r0, [r1, #4]!
.macro sfi_memib op, dest, basereg, offset
	.bundle_lock
	_sfi_dmask \basereg
	\op \dest, [\basereg, \offset]!
	.bundle_unlock
.endm

@ For "increment after" cases, e.g.:
@	sfi_memia ldr r0, r1, #4	@ ldr r0, [r1], #4
.macro sfi_memia op, dest, basereg, offset
	.bundle_lock
	_sfi_dmask \basereg
	\op \dest, [\basereg], \offset
	.bundle_unlock
.endm

@ For register pair cases (i.e. ldrd or strd), e.g.:
@	sfi_memd ldrd r2, r3, r0	@ ldrd r2, r3, [r0]
@ (Note we don't support the pre-indexed case.)
.macro sfi_memd op, dest, dest2, basereg, offset=#0
	.bundle_lock
	_sfi_dmask \basereg
	\op \dest,\dest2, [\basereg, \offset]
	.bundle_unlock
.endm

@ For "increment after" register pair cases (i.e. ldrd or strd), e.g.:
@	sfi_memdia ldrd r2, r3, r0, -r1	@ ldrd r2, r3, [r0], -r1
.macro sfi_memdia op, dest, dest2, basereg, offset
	.bundle_lock
	_sfi_dmask \basereg
	\op \dest,\dest2, [\basereg], \offset
	.bundle_unlock
.endm

@ For load/store multiple cases, e.g.:
@	sfi_memm ldm r0, {r1, r2, r3}	@ ldm r0, {r1, r2, r3}
@ Note you don't want to use this for sp, since SFI is not required.
.macro sfi_memm op basereg, reglist:vararg
	.bundle_lock
	_sfi_dmask \basereg
	\op \basereg, \reglist
	.bundle_unlock
.endm

@ For "increment after" load/store multiple cases, e.g.:
@	sfi_memm ldmia r0!, {r5-r8}	@ ldmia r0!, {r5-r8}
@ Note you don't want to use this for sp, since SFI is not required.
.macro sfi_memmia op basereg, reglist:vararg
	.bundle_lock
	_sfi_dmask \basereg
	\op \basereg!, \reglist
	.bundle_unlock
.endm


@ For popping multiple registers, including sp and lr.
@ Note you don't want to use this if sp and lr are not touched.
.macro sfi_popm reglist:vararg
	.bundle_lock
	pop \reglist
	_sfi_dmask sp
	_sfi_dmask lr
	.bundle_unlock
.endm


@ Alternative scheme with just one macro (macro name TBD).
@ This has the feature that most of the line is exactly the
@ usual ARM instruction syntax, unmodified.  It has the downside
@ that the base register appears twice, thus introducing the
@ possibility of errors where the base register in the first parameter
@ is not the actual base register used in the address mode syntax.
@ NB: GCC output uses this.
.macro sfi_breg basereg, insn:vararg
	.bundle_lock
	_sfi_dmask \basereg
	\insn
	.bundle_unlock
.endm

@ TODO(mcgrathr): examples don't belong here
.if 0
@ Example uses of all the macros (nops just to ease reading of disassembly)
	nop
Tbx:	sfi_bx r0
	nop
Tbl:	sfi_bl foobar
	nop
Tblx:	sfi_blx r1
	nop
Tret:	sfi_ret

	nop
Tloads: sfi_mem ldr r0, r1
	sfi_mem ldr r0, r1, #8
	sfi_mem str r0, r1, #8
	sfi_memib ldr r0, r1, #8
	sfi_memia ldr r0, r1, #8
	sfi_memm ldm r0, {r2, r3, r4}
	sfi_memmia ldmia r0, {r2, r3, r4}
	sfi_memm stm r0, {r2, r3, r4}
	sfi_memmia stmia r0, {r2, r3, r4}
	sfi_popm {r5, sp, lr}

Talternate:
	sfi_breg r1, ldr r0, [r1]
	sfi_breg r1, ldr r0, [r1, #8]
	sfi_breg r1, str r0, [r1, #8]
	sfi_breg r1, ldr r0, [r1, #8]!
	sfi_breg r1, ldr r0, [r1], #8
	sfi_breg r0, ldm r0, {r2, r3, r4}
	sfi_breg r0, ldmia r0!, {r2, r3, r4}
	sfi_breg r0, stm r0, {r2, r3, r4}
	sfi_breg r0, stmia r0!, {r2, r3, r4}
.endif
