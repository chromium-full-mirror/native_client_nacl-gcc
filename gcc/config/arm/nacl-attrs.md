;; Copyright 2012 Free Software Foundation, Inc.
;;
;; This file is part of GCC.
;;
;; GCC is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your
;; option) any later version.
;;
;; GCC is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GCC; see the file COPYING3.  If not see
;; <http://www.gnu.org/licenses/>.

;; This file defines attribute types used for instructions modified
;; by TARGET_SFI_NACL1.  That is, those with assembly templates
;; using the %*, %j, and %b prefixes.

;; All "length" attribute calculations give the worst case, i.e. the
;; longest byte-length that could result from the instruction sequence.
;; For bundle-locked sequences, the worst case is always that the
;; sequence starts late in a bundle, causeing nops to be inserted to pad
;; to the next bundle so the whole sequence lands inside one bundle.
;; This means the worst case for multi-instruction sequences is often
;; quite long, but in the actual length of any given instance of the
;; sequence will most often be shorter.

;; The "length" attribute for a "%*bx" instruction.  This is a
;; two-instruction bundle-locked sequence.  Hence the worst case is
;; that it starts at the last spot of a bundle so it's pushed to the
;; next bundle, making it three instructions.
(define_attr "length_sfi_bx" ""
  (if_then_else (match_test "TARGET_SFI_NACL1")
                (const_int 12)
                (const_int 4)))

;; Same, but for a sequence of three instructions where one of them is "%*bx".
(define_attr "length_sfi_bx_plus_2" ""
  (if_then_else (match_test "TARGET_SFI_NACL1")
                (const_int 20)          ; 12 + 8
                (const_int 12)))

;; The "length" attribute for a "%*bl" instruction.  This is two
;; instructions (not bundle-locked) followed by alignment to the end
;; of the bundle.  Hence the worst case is that it starts in the
;; last spot in a bundle, so it takes one instruction plus a whole
;; bundle (i.e. five instructions).
(define_attr "length_sfi_bl" ""
  (if_then_else (match_test "TARGET_SFI_NACL1")
                (const_int 20)
                (const_int 4)))

;; The "length" attribute for a "%*blx" instruction.  This is one
;; instruction, plus a two-instruction bundle-locked sequence,
;; followed by alignment to the end of the bundle.  Hence the worst
;; case is that it starts at the second-to-last (third) spot of a
;; bundle so the locked pair is pushed to the next bundle, making it
;; two instructions plus a whole bundle (i.e. six instructions).
(define_attr "length_sfi_blx" ""
  (if_then_else (match_test "TARGET_SFI_NACL1")
                (const_int 24)
                (const_int 4)))

;; Boolean meta-attribute that represents whether a "%j0"
;; instruction would actually use the "sfi_sp" prefix.
(define_attr "sfi_sp_op0" "no,yes"
  (if_then_else (and (match_test "TARGET_SFI_NACL1")
                     (match_test "REGNO (operands[0]) == SP_REGNUM"))
                (const_string "yes")
                (const_string "no")))

;; Boolean meta-attribute that represents whether a "%j1"
;; instruction would actually use the "sfi_sp" prefix.
(define_attr "sfi_sp_op1" "no,yes"
  (if_then_else (and (match_test "TARGET_SFI_NACL1")
                     (match_test "REGNO (operands[1]) == SP_REGNUM"))
                (const_string "yes")
                (const_string "no")))

;; The "length" attribute for a "%j0" instruction.  When %0 is
;; SP_REGNUM, this is a two-instruction bundle-locked sequence.
;; Hence the worst case is that it starts at the last spot of a
;; bundle so it's pushed to the next bundle, making it three
;; instructions.
(define_attr "length_sp_op0" ""
  (if_then_else (eq_attr "sfi_sp_op0" "yes")
                (const_int 12)
                (const_int 4)))

;; Same, but for "%j1".
(define_attr "length_sp_op1" ""
  (if_then_else (eq_attr "sfi_sp_op1" "yes")
                (const_int 12)
                (const_int 4)))

;; Same, but for a sequence of up to three instructions where each
;; one might be a "length_sp_op0" case by itself.
(define_attr "length_sp_op0_by_3" ""
  (if_then_else (eq_attr "sfi_sp_op0" "yes")
                (const_int 36)          ; 12 * 3
                (const_int 12)))

;; Same, but for a sequence of up to four instructions where each
;; one might be a "length_sp_op0" case by itself.
(define_attr "length_sp_op0_by_4" ""
  (if_then_else (eq_attr "sfi_sp_op0" "yes")
                (const_int 48)          ; 12 * 4
                (const_int 16)))

;; Same, but for a sequence of two instructions where one of them
;; might be a "length_sp_op0" case by itself.
(define_attr "length_sp_op0_plus_1" ""
  (if_then_else (eq_attr "sfi_sp_op0" "yes")
                (const_int 16)          ; 12 + 4
                (const_int 8)))

;; Same, but for a sequence of three instructions where one of them
;; might be a "length_sp_op0" case by itself.
(define_attr "length_sp_op0_plus_2" ""
  (if_then_else (eq_attr "sfi_sp_op0" "yes")
                (const_int 20)          ; 12 + 8
                (const_int 12)))

;; Same, but for a sequence of up to three instructions where each
;; of two of them might be a "length_sp_op0" case by itself.
(define_attr "length_sp_op0_by_2_plus_1" ""
  (if_then_else (eq_attr "sfi_sp_op0" "yes")
                (const_int 28)          ; (12 * 2) + 4
                (const_int 12)))

;; Boolean meta-attribute that represents whether a "%b0"
;; instruction would actually use the "sfi_breg" prefix.
(define_attr "sfi_breg_op0" "no,yes"
  (if_then_else (and (match_test "TARGET_SFI_NACL1")
                     (match_test "arm_sfi_breg_operand (operands[0]) != -1"))
                (const_string "yes")
                (const_string "no")))

;; Boolean meta-attribute that represents whether a "%b1"
;; instruction would actually use the "sfi_breg" prefix.
(define_attr "sfi_breg_op1" "no,yes"
  (if_then_else (and (match_test "TARGET_SFI_NACL1")
                     (match_test "arm_sfi_breg_operand (operands[1]) != -1"))
                (const_string "yes")
                (const_string "no")))

;; Boolean meta-attribute that represents whether a "%b3"
;; instruction would actually use the "sfi_breg" prefix.
(define_attr "sfi_breg_op3" "no,yes"
  (if_then_else (and (match_test "TARGET_SFI_NACL1")
                     (match_test "arm_sfi_breg_operand (operands[3]) != -1"))
                (const_string "yes")
                (const_string "no")))

;; Boolean meta-attribute that represents whether a "%b4"
;; instruction would actually use the "sfi_breg" prefix.
(define_attr "sfi_breg_op4" "no,yes"
  (if_then_else (and (match_test "TARGET_SFI_NACL1")
                     (match_test "arm_sfi_breg_operand (operands[4]) != -1"))
                (const_string "yes")
                (const_string "no")))

;; Boolean meta-attribute that represents whether a "%b5"
;; instruction would actually use the "sfi_breg" prefix.
(define_attr "sfi_breg_op5" "no,yes"
  (if_then_else (and (match_test "TARGET_SFI_NACL1")
                     (match_test "arm_sfi_breg_operand (operands[5]) != -1"))
                (const_string "yes")
                (const_string "no")))

;; The "length" attribute for a "%b0" instruction.  When %0 uses a
;; base register requiring sandboxing, this is a two-instruction
;; bundle-locked sequence.  Hence the worst case is that it starts
;; at the last spot of a bundle so it's pushed to the next bundle,
;; making it three instructions.
(define_attr "length_breg_op0" ""
  (if_then_else (eq_attr "sfi_breg_op0" "yes")
                (const_int 12)
                (const_int 4)))

;; Same, but for "%b1" rather than "%b0".
(define_attr "length_breg_op1" ""
  (if_then_else (eq_attr "sfi_breg_op1" "yes")
                (const_int 12)
                (const_int 4)))

;; Same, but for "%b3" rather than "%b0".
(define_attr "length_breg_op3" ""
  (if_then_else (eq_attr "sfi_breg_op3" "yes")
                (const_int 12)
                (const_int 4)))

;; Same, but for "%b4" rather than "%b0".
(define_attr "length_breg_op4" ""
  (if_then_else (eq_attr "sfi_breg_op4" "yes")
                (const_int 12)
                (const_int 4)))

;; Same, but for "%b5" rather than "%b0".
(define_attr "length_breg_op5" ""
  (if_then_else (eq_attr "sfi_breg_op5" "yes")
                (const_int 12)
                (const_int 4)))

;; Same, but for a sequence of two instructions where the second is a
;; "length_breg_op0" case by itself.
(define_attr "length_breg_op0_plus_1" ""
  (if_then_else (eq_attr "sfi_breg_op0" "yes")
                (const_int 16)          ; 12 + 4
                (const_int 8)))

;; Same, but for a sequence of two instructions where the second is a
;; "length_breg_op1" case by itself.
(define_attr "length_breg_op1_plus_1" ""
  (if_then_else (eq_attr "sfi_breg_op1" "yes")
                (const_int 16)          ; 12 + 4
                (const_int 8)))

;; Same, but for a sequence of three instructions where each of two
;; of them is a "length_breg_op0" case by itself.
(define_attr "length_breg_op0_by_2_plus_1" ""
  (if_then_else (eq_attr "sfi_breg_op0" "yes")
                (const_int 28)          ; (12 * 2) + 4
                (const_int 12)))

;; The "length" attribute to replace (set_attr "length" "2,4").
;; That is, in alternative 0 it's a short Thumb-2 instruction.
;; In alternative 1, it's a "length_breg_op0" case.
;;
;; Note that this is used in define_insn's where there are two
;; alternatives in the constraints, but no alternatives in the
;; output template.  GCC won't let us use (eq_attr "alternative" "1")
;; in such cases, so we have to resort to testing it in C.
(define_attr "length_breg_op0_alt1_or_t2" ""
  (if_then_else (match_test "which_alternative == 1")
                (attr "length_breg_op0")
                (const_int 2)))

;; Same, but for operand 1 instead of operand 0.
(define_attr "length_breg_op1_alt1_or_t2" ""
  (if_then_else (match_test "which_alternative == 1")
                (attr "length_breg_op1")
                (const_int 2)))

;; The "length" attribute for a "%j1%b0" instruction.  When %1 is
;; SP_REGNUM and %0 uses a base register requiring sandboxing, this
;; is a three-instruction bundle-locked sequence.  Hence the worst
;; case is that it starts at the second-to-last spot of a bundle so
;; it's pushed to the next bundle, making it five instructions.
(define_attr "length_breg_op0_sp_op1" ""
  (if_then_else (eq_attr "sfi_breg_op0" "yes")
                (if_then_else (eq_attr "sfi_sp_op1" "yes")
                              (const_int 20)
                              (attr "length_breg_op0"))
                (attr "length_sp_op1")))

;; Same, but for "%j0%b1".
(define_attr "length_breg_op1_sp_op0" ""
  (if_then_else (eq_attr "sfi_breg_op1" "yes")
                (if_then_else (eq_attr "sfi_sp_op0" "yes")
                              (const_int 20)
                              (attr "length_breg_op1"))
                (attr "length_sp_op0")))
