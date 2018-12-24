//
// JIT opcode definitions
//

class RegType {
}

def NONE: RegType;
def IREG: RegType;
def FREG: RegType;
def LREG: RegType;
def VREG: RegType;
def XREG: RegType;

class OpcodeGeneral<string label, RegType dreg = NONE, RegType sreg1 = NONE, RegType sreg2 = NONE, RegType sreg3 = NONE> {
  // If this is empty, its set from the opcode name, i.e. OP_ADD_IMM -> add_imm
  string label = label;
  RegType dreg = dreg;
  RegType sreg1 = sreg1;
  RegType sreg2 = sreg2;
  RegType sreg3 = sreg3;
  // Empty, or a comma-separated list of arches i.e. "X86,AMD64"
  string arch = "";
}

// For opcodes with auto-generated labels
class Opcode<RegType dreg = NONE, RegType sreg1 = NONE, RegType sreg2 = NONE> : OpcodeGeneral<"", dreg, sreg1, sreg2, NONE> {
}

// 3 sreg opcodes
class Opcode3<RegType dreg = NONE, RegType sreg1 = NONE, RegType sreg2 = NONE, RegType sreg3 = NONE> : OpcodeGeneral<"", dreg, sreg1, sreg2, sreg3> {
}

// Have to come first
def OP_LOAD : Opcode<NONE, NONE, NONE>;
def OP_LDADDR : Opcode<IREG, NONE, NONE>;
// Unused
def OP_STORE :	Opcode<NONE, NONE, NONE>;
def OP_NOP :  	Opcode<NONE, NONE, NONE>;
def OP_HARD_NOP : Opcode<NONE, NONE, NONE>;
def OP_RELAXED_NOP : Opcode<NONE, NONE, NONE>;
def OP_PHI : 	   Opcode<IREG, NONE, NONE>;
def OP_FPHI : 	   Opcode<FREG, NONE, NONE>;
def OP_VPHI : 	   Opcode<VREG, NONE, NONE>;
def OP_COMPARE :   Opcode<NONE, IREG, IREG>;
def OP_COMPARE_IMM : Opcode<NONE, IREG, NONE>;
def OP_FCOMPARE :  Opcode<NONE, FREG, FREG>;
def OP_RCOMPARE :  Opcode<NONE, FREG, FREG>;
def OP_LCOMPARE :  Opcode<NONE, LREG, LREG>;
def OP_ICOMPARE :  Opcode<NONE, IREG, IREG>;
def OP_ICOMPARE_IMM : Opcode<NONE, IREG, NONE>;
def OP_LCOMPARE_IMM : Opcode<NONE, LREG, NONE>;
/* inst_imm contains the local index */
def OP_GSHAREDVT_LOCAL : Opcode<NONE, NONE, NONE>;
def OP_GSHAREDVT_ARG_REGOFFSET : Opcode<NONE, NONE, NONE>;

/*
 * Represents passing a valuetype argument which has not been decomposed yet.
 * inst_p0 points to the call.
 */
def OP_OUTARG_VT : Opcode<NONE, VREG, NONE>;
def OP_OUTARG_VTRETADDR : Opcode<IREG, NONE, NONE>;
def OP_SETRET : Opcode<NONE, IREG, NONE>;
def OP_SETFRET : Opcode<FREG, FREG, NONE>;
def OP_SETLRET : Opcode<NONE, IREG, IREG>;
def OP_LOCALLOC : Opcode<IREG, IREG, NONE>;
def OP_LOCALLOC_IMM : Opcode<IREG, NONE, NONE>;
def OP_CHECK_THIS : OpcodeGeneral<"checkthis", NONE, IREG, NONE>;
def OP_SEQ_POINT : Opcode<NONE, NONE, NONE>;
def OP_IL_SEQ_POINT : Opcode<NONE, NONE, NONE>;
def OP_IMPLICIT_EXCEPTION : Opcode<NONE, NONE, NONE>;

/* write barrier */
def OP_CARD_TABLE_WBARRIER : Opcode<NONE, IREG, IREG>;

def OP_LOAD_GOTADDR : Opcode<IREG, NONE, NONE>;
def OP_DUMMY_USE : Opcode<NONE, IREG, NONE>;
def OP_NOT_REACHED : Opcode<NONE, NONE, NONE>;
def OP_NOT_NULL : Opcode<NONE, IREG, NONE>;
/* Same as OUTARG_VT, but has a dreg */
def OP_LLVM_OUTARG_VT : Opcode<IREG, VREG, NONE>;

def OP_OBJC_GET_SELECTOR : Opcode<IREG, NONE, NONE>;

def OP_GET_SP : Opcode<IREG, NONE, NONE>;
def OP_SET_SP : Opcode<NONE, IREG, NONE>;

def OP_GET_LAST_ERROR : Opcode<IREG, NONE, NONE>;

/*
 * Fill out a MonoContext contained in a MonoProfilerCallContext. This only
 * stores the stack pointer, frame pointer, and callee-saved registers. This
 * should be enough to locate arguments and variables.
 */
def OP_FILL_PROF_CALL_CTX : Opcode<NONE, IREG, NONE>;

/* Front-end opcodes */
def OP_BOX : Opcode<IREG, IREG, NONE>;
/* A box of the int value in inst_c0 */
def OP_BOX_ICONST : Opcode<IREG, NONE, NONE>;
/* Same as OP_MOVE, ins->dreg is an objref of type ins->klass */
def OP_TYPED_OBJREF : Opcode<IREG, IREG, NONE>;
/* to optimize strings */
def OP_STRLEN : Opcode<IREG, IREG, NONE>;
def OP_NEWARR : Opcode<IREG, IREG, NONE>;
/* Load a readonly length field from [sreg1+inst_imm] */
def OP_LDLEN : Opcode<IREG, IREG, NONE>;
def OP_BOUNDS_CHECK : Opcode<NONE, IREG, IREG>;
/* type checks */
def OP_ISINST : Opcode<IREG, IREG, NONE>;
def OP_CASTCLASS : Opcode<IREG, IREG, NONE>;
/* get adress of element in a 2D array */
def OP_LDELEMA2D : OpcodeGeneral<"ldelema2d", NONE, NONE, NONE>;
/* inlined small memcpy with constant length */
def OP_MEMCPY : Opcode<NONE, NONE, NONE>;
/* inlined small memset with constant length */
def OP_MEMSET : Opcode<NONE, NONE, NONE>;
def OP_SAVE_LMF : Opcode<NONE, NONE, NONE>;
def OP_RESTORE_LMF : Opcode<NONE, NONE, NONE>;

/* Opcodes used for variables */
def OP_LOCAL : 		Opcode<NONE, NONE, NONE>;
def OP_ARG : 		Opcode<NONE, NONE, NONE>;

/* CALL opcodes need to stay together, see MONO_IS_CALL macro */
def OP_VOIDCALL : Opcode<NONE, NONE, NONE>;
def OP_VOIDCALL_REG : Opcode<NONE, IREG, NONE>;
def OP_VOIDCALL_MEMBASE : Opcode<NONE, IREG, NONE>;
def OP_CALL        : Opcode<IREG, NONE, NONE>;
def OP_CALL_REG : Opcode<IREG, IREG, NONE>;
def OP_CALL_MEMBASE : Opcode<IREG, IREG, NONE>;
def OP_FCALL : Opcode<FREG, NONE, NONE>;
def OP_FCALL_REG : Opcode<FREG, IREG, NONE>;
def OP_FCALL_MEMBASE : Opcode<FREG, IREG, NONE>;
def OP_RCALL : Opcode<FREG, NONE, NONE>;
def OP_RCALL_REG : Opcode<FREG, IREG, NONE>;
def OP_RCALL_MEMBASE : Opcode<FREG, IREG, NONE>;
def OP_LCALL : Opcode<LREG, NONE, NONE>;
def OP_LCALL_REG : Opcode<LREG, IREG, NONE>;
def OP_LCALL_MEMBASE : Opcode<LREG, IREG, NONE>;
def OP_VCALL  : Opcode<VREG, NONE, NONE>;
def OP_VCALL_REG : Opcode<VREG, IREG, NONE>;
def OP_VCALL_MEMBASE : Opcode<VREG, IREG, NONE>;
/* Represents the decomposed vcall which doesn't return a vtype no more */
def OP_VCALL2  : Opcode<NONE, NONE, NONE>;
def OP_VCALL2_REG : Opcode<NONE, IREG, NONE>;
def OP_VCALL2_MEMBASE : Opcode<NONE, IREG, NONE>;
def OP_DYN_CALL : Opcode<NONE, IREG, IREG>;

def OP_ICONST : Opcode<IREG, NONE, NONE>;
def OP_I8CONST : Opcode<LREG, NONE, NONE>;
def OP_R4CONST : Opcode<FREG, NONE, NONE>;
def OP_R8CONST : Opcode<FREG, NONE, NONE>;
def OP_VZERO   : Opcode<VREG, NONE, NONE>;
def OP_DUMMY_ICONST : Opcode<IREG, NONE, NONE>;
def OP_DUMMY_I8CONST : Opcode<LREG, NONE, NONE>;
def OP_DUMMY_R8CONST : Opcode<FREG, NONE, NONE>;
def OP_DUMMY_R4CONST : Opcode<FREG, NONE, NONE>;
def OP_DUMMY_VZERO : Opcode<VREG, NONE, NONE>;
def OP_REGVAR : Opcode<NONE, NONE, NONE>;
def OP_REGOFFSET : Opcode<NONE, NONE, NONE>;
def OP_VTARG_ADDR : Opcode<NONE, NONE, NONE>;
def OP_LABEL : Opcode<NONE, NONE, NONE>;
def OP_SWITCH  : Opcode<NONE, IREG, NONE>;

/* EH related opcodes */
def OP_THROW : Opcode<NONE, IREG, NONE>;
def OP_RETHROW : Opcode<NONE, IREG, NONE>;
def OP_CALL_HANDLER   : Opcode<NONE, NONE, NONE>;
def OP_START_HANDLER   : Opcode<NONE, NONE, NONE>;
def OP_ENDFILTER  : Opcode<NONE, IREG, NONE>;
def OP_ENDFINALLY  : Opcode<NONE, NONE, NONE>;
/*
 * Returns the exception object passed to catch clauses in
 * by the EH code in a register.
 */
def OP_GET_EX_OBJ : Opcode<IREG, NONE, NONE>;

/*
 * Vararg calls are implemented as follows:
 * - the caller emits a hidden argument just before the varargs argument. this
 *   'signature cookie' argument contains the signature describing the the call.
 * - all implicit arguments are passed in memory right after the signature cookie, i.e.
 *   the stack will look like this:
 *   <argn>
 *   ..
 *   <arg1>
 *   <sig cookie>
 * - the OP_ARGLIST opcode in the callee computes the address of the sig cookie argument
 *   on the stack and saves it into its sreg1.
 * - mono_ArgIterator_Setup receives this value and uses it to find the signature and
 *   the arguments.
 */
def OP_ARGLIST : OpcodeGeneral<"oparglist", NONE, IREG, NONE>;

/* MONO_IS_STORE_MEMBASE depends on the order here */
def OP_STORE_MEMBASE_REG : Opcode<IREG, IREG, NONE>;
def OP_STOREI1_MEMBASE_REG : Opcode<IREG, IREG, NONE>;
def OP_STOREI2_MEMBASE_REG : Opcode<IREG, IREG, NONE>;
def OP_STOREI4_MEMBASE_REG : Opcode<IREG, IREG, NONE>;
def OP_STOREI8_MEMBASE_REG : Opcode<IREG, LREG, NONE>;
def OP_STORER4_MEMBASE_REG : Opcode<IREG, FREG, NONE>;
def OP_STORER8_MEMBASE_REG : Opcode<IREG, FREG, NONE>;

let arch = "X86,AMD64" in {
def OP_STOREX_MEMBASE_REG : Opcode<IREG, XREG, NONE>;
def OP_STOREX_ALIGNED_MEMBASE_REG     : Opcode<IREG, XREG, NONE>;
def OP_STOREX_NTA_MEMBASE_REG     : Opcode<IREG, XREG, NONE>;
}

def OP_STORE_MEMBASE_IMM : Opcode<IREG, NONE, NONE>;
def OP_STOREI1_MEMBASE_IMM : Opcode<IREG, NONE, NONE>;
def OP_STOREI2_MEMBASE_IMM : Opcode<IREG, NONE, NONE>;
def OP_STOREI4_MEMBASE_IMM : Opcode<IREG, NONE, NONE>;
def OP_STOREI8_MEMBASE_IMM : Opcode<IREG, NONE, NONE>;
def OP_STOREX_MEMBASE       : Opcode<IREG, XREG, NONE>;
def OP_STOREV_MEMBASE      : Opcode<IREG, VREG, NONE>;

/* MONO_IS_LOAD_MEMBASE depends on the order here */
def OP_LOAD_MEMBASE : Opcode<IREG, IREG, NONE>;
def OP_LOADI1_MEMBASE : Opcode<IREG, IREG, NONE>;
def OP_LOADU1_MEMBASE : Opcode<IREG, IREG, NONE>;
def OP_LOADI2_MEMBASE : Opcode<IREG, IREG, NONE>;
def OP_LOADU2_MEMBASE : Opcode<IREG, IREG, NONE>;
def OP_LOADI4_MEMBASE : Opcode<IREG, IREG, NONE>;
def OP_LOADU4_MEMBASE : Opcode<IREG, IREG, NONE>;
def OP_LOADI8_MEMBASE : Opcode<LREG, IREG, NONE>;
def OP_LOADR4_MEMBASE : Opcode<FREG, IREG, NONE>;
def OP_LOADR8_MEMBASE : Opcode<FREG, IREG, NONE>;

def OP_LOADX_MEMBASE 		 : Opcode<XREG, IREG, NONE>;

let arch="X86,AMD64" in {
def OP_LOADX_ALIGNED_MEMBASE  : Opcode<XREG, IREG, NONE>;
}

def OP_LOADV_MEMBASE   : Opcode<VREG, IREG, NONE>;

/* indexed loads: dreg = load at (sreg1 + sreg2>;*/
def OP_LOAD_MEMINDEX  : Opcode<IREG, IREG, IREG>;
def OP_LOADI1_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_LOADU1_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_LOADI2_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_LOADU2_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_LOADI4_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_LOADU4_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_LOADI8_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_LOADR4_MEMINDEX : Opcode<FREG, IREG, IREG>;
def OP_LOADR8_MEMINDEX : Opcode<FREG, IREG, IREG>;
/* indexed stores: store sreg1 at (destbasereg + sreg2>; */
/* MONO_IS_STORE_MEMINDEX depends on the order here */
def OP_STORE_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_STOREI1_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_STOREI2_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_STOREI4_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_STOREI8_MEMINDEX : Opcode<IREG, IREG, IREG>;
def OP_STORER4_MEMINDEX : Opcode<IREG, FREG, IREG>;
def OP_STORER8_MEMINDEX : Opcode<IREG, FREG, IREG>;

def OP_LOAD_MEM : Opcode<IREG, NONE, NONE>;
def OP_LOADU1_MEM : Opcode<IREG, NONE, NONE>;
def OP_LOADU2_MEM : Opcode<IREG, NONE, NONE>;
def OP_LOADI4_MEM : Opcode<IREG, NONE, NONE>;
def OP_LOADU4_MEM : Opcode<IREG, NONE, NONE>;
def OP_LOADI8_MEM : Opcode<IREG, NONE, NONE>;
def OP_STORE_MEM_IMM : Opcode<NONE, NONE, NONE>;

def OP_MOVE : Opcode<IREG, IREG, NONE>;
def OP_LMOVE : Opcode<LREG, LREG, NONE>;
def OP_FMOVE : Opcode<FREG, FREG, NONE>;
def OP_VMOVE   : Opcode<VREG, VREG, NONE>;
def OP_RMOVE : Opcode<FREG, FREG, NONE>;

/*
 * All 4 of these are only available when soft float isn't active. They
 * perform no conversions; they simply move values back and forth.
 */
def OP_MOVE_F_TO_I4 : Opcode<IREG, FREG, NONE>;
def OP_MOVE_I4_TO_F : Opcode<FREG, IREG, NONE>;
/* These 2 are only available on 64-bit targets. */
def OP_MOVE_F_TO_I8 : Opcode<IREG, FREG, NONE>;
def OP_MOVE_I8_TO_F : Opcode<FREG, IREG, NONE>;

def OP_ADD_IMM    : Opcode<IREG, IREG, NONE>;
def OP_SUB_IMM    : Opcode<IREG, IREG, NONE>;
def OP_MUL_IMM    : Opcode<IREG, IREG, NONE>;
def OP_DIV_IMM    : Opcode<IREG, IREG, NONE>;
def OP_DIV_UN_IMM : Opcode<IREG, IREG, NONE>;
def OP_REM_IMM    : Opcode<IREG, IREG, NONE>;
def OP_REM_UN_IMM : Opcode<IREG, IREG, NONE>;
def OP_AND_IMM    : Opcode<IREG, IREG, NONE>;
def OP_OR_IMM     : Opcode<IREG, IREG, NONE>;
def OP_XOR_IMM    : Opcode<IREG, IREG, NONE>;
def OP_SHL_IMM    : Opcode<IREG, IREG, NONE>;
def OP_SHR_IMM    : Opcode<IREG, IREG, NONE>;
def OP_SHR_UN_IMM : Opcode<IREG, IREG, NONE>;

def OP_BR         : Opcode<NONE, NONE, NONE>;
/* Similar to old OP_JMP, but the passing of arguments is done similarly to calls */
def OP_TAILCALL   : Opcode<NONE, NONE, NONE>;
def OP_TAILCALL_PARAMETER : Opcode<NONE, NONE, NONE>; // no code, just size
def OP_TAILCALL_REG : Opcode<NONE, IREG, NONE>;
def OP_TAILCALL_MEMBASE : Opcode<NONE, IREG, NONE>;
def OP_BREAK      : Opcode<NONE, NONE, NONE>;

def OP_CEQ   : Opcode<IREG, NONE, NONE>;
def OP_CGT   : Opcode<IREG, NONE, NONE>;
def OP_CGT_UN : OpcodeGeneral<"cgt.un", IREG, NONE, NONE>;
def OP_CLT   : Opcode<IREG, NONE, NONE>;
def OP_CLT_UN : OpcodeGeneral<"clt.un", IREG, NONE, NONE>;

/* exceptions: must be in the same order as the matching CEE_ branch opcodes */
def OP_COND_EXC_EQ : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_GE : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_GT : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_LE : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_LT : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_NE_UN : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_GE_UN : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_GT_UN : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_LE_UN : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_LT_UN : Opcode<NONE, NONE, NONE>;

def OP_COND_EXC_OV : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_NO : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_C : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_NC : Opcode<NONE, NONE, NONE>;

def OP_COND_EXC_IEQ : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_IGE : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_IGT : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_ILE : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_ILT : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_INE_UN : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_IGE_UN : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_IGT_UN : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_ILE_UN : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_ILT_UN : Opcode<NONE, NONE, NONE>;

def OP_COND_EXC_IOV : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_INO : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_IC : Opcode<NONE, NONE, NONE>;
def OP_COND_EXC_INC : Opcode<NONE, NONE, NONE>;

/* 64 bit opcodes: must be in the same order as the matching CEE_ opcodes: binops_op_map */
def OP_LADD    : OpcodeGeneral<"long_add", LREG, LREG, LREG>;
def OP_LSUB    : OpcodeGeneral<"long_sub", LREG, LREG, LREG>;
def OP_LMUL    : OpcodeGeneral<"long_mul", LREG, LREG, LREG>;
def OP_LDIV    : OpcodeGeneral<"long_div", LREG, LREG, LREG>;
def OP_LDIV_UN : OpcodeGeneral<"long_div_un", LREG, LREG, LREG>;
def OP_LREM    : OpcodeGeneral<"long_rem", LREG, LREG, LREG>;
def OP_LREM_UN : OpcodeGeneral<"long_rem_un", LREG, LREG, LREG>;
def OP_LAND    : OpcodeGeneral<"long_and", LREG, LREG, LREG>;
def OP_LOR     : OpcodeGeneral<"long_or", LREG, LREG, LREG>;
def OP_LXOR    : OpcodeGeneral<"long_xor", LREG, LREG, LREG>;
def OP_LSHL    : OpcodeGeneral<"long_shl", LREG, LREG, IREG>;
def OP_LSHR    : OpcodeGeneral<"long_shr", LREG, LREG, IREG>;
def OP_LSHR_UN : OpcodeGeneral<"long_shr_un", LREG, LREG, IREG>;

/* 64 bit opcodes: must be in the same order as the matching CEE_ opcodes: unops_op_map */
def OP_LNEG       : OpcodeGeneral<"long_neg", LREG, LREG, NONE>;
def OP_LNOT       : OpcodeGeneral<"long_not", LREG, LREG, NONE>;
def OP_LCONV_TO_I1 : OpcodeGeneral<"long_conv_to_i1", IREG, LREG, NONE>;
def OP_LCONV_TO_I2 : OpcodeGeneral<"long_conv_to_i2", IREG, LREG, NONE>;
def OP_LCONV_TO_I4 : OpcodeGeneral<"long_conv_to_i4", IREG, LREG, NONE>;
def OP_LCONV_TO_I8 : OpcodeGeneral<"long_conv_to_i8", LREG, LREG, NONE>;
def OP_LCONV_TO_R4 : OpcodeGeneral<"long_conv_to_r4", FREG, LREG, NONE>;
def OP_LCONV_TO_R8 : OpcodeGeneral<"long_conv_to_r8", FREG, LREG, NONE>;
def OP_LCONV_TO_U4 : OpcodeGeneral<"long_conv_to_u4", IREG, LREG, NONE>;
def OP_LCONV_TO_U8 : OpcodeGeneral<"long_conv_to_u8", LREG, LREG, NONE>;

def OP_LCONV_TO_U2   : OpcodeGeneral<"long_conv_to_u2", IREG, LREG, NONE>;
def OP_LCONV_TO_U1   : OpcodeGeneral<"long_conv_to_u1", IREG, LREG, NONE>;
def OP_LCONV_TO_I    : OpcodeGeneral<"long_conv_to_i", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_I : OpcodeGeneral<"long_conv_to_ovf_i", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U : OpcodeGeneral<"long_conv_to_ovf_u", LREG, LREG, NONE>;

def OP_LADD_OVF      : OpcodeGeneral<"long_add_ovf", LREG, LREG, LREG>;
def OP_LADD_OVF_UN   : OpcodeGeneral<"long_add_ovf_un", LREG, LREG, LREG>;
def OP_LMUL_OVF      : OpcodeGeneral<"long_mul_ovf", LREG, LREG, LREG>;
def OP_LMUL_OVF_UN   : OpcodeGeneral<"long_mul_ovf_un", LREG, LREG, LREG>;
def OP_LSUB_OVF      : OpcodeGeneral<"long_sub_ovf", LREG, LREG, LREG>;
def OP_LSUB_OVF_UN   : OpcodeGeneral<"long_sub_ovf_un", LREG, LREG, LREG>;

def OP_LCONV_TO_OVF_I1_UN : OpcodeGeneral<"long_conv_to_ovf_i1_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_I2_UN : OpcodeGeneral<"long_conv_to_ovf_i2_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_I4_UN : OpcodeGeneral<"long_conv_to_ovf_i4_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_I8_UN : OpcodeGeneral<"long_conv_to_ovf_i8_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U1_UN : OpcodeGeneral<"long_conv_to_ovf_u1_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U2_UN : OpcodeGeneral<"long_conv_to_ovf_u2_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U4_UN : OpcodeGeneral<"long_conv_to_ovf_u4_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U8_UN : OpcodeGeneral<"long_conv_to_ovf_u8_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_I_UN : OpcodeGeneral<"long_conv_to_ovf_i_un", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U_UN : OpcodeGeneral<"long_conv_to_ovf_u_un", LREG, LREG, NONE>;

def OP_LCONV_TO_OVF_I1 : OpcodeGeneral<"long_conv_to_ovf_i1", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U1 : OpcodeGeneral<"long_conv_to_ovf_u1", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_I2 : OpcodeGeneral<"long_conv_to_ovf_i2", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U2 : OpcodeGeneral<"long_conv_to_ovf_u2", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_I4 : OpcodeGeneral<"long_conv_to_ovf_i4", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U4 : OpcodeGeneral<"long_conv_to_ovf_u4", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_I8 : OpcodeGeneral<"long_conv_to_ovf_i8", LREG, LREG, NONE>;
def OP_LCONV_TO_OVF_U8 : OpcodeGeneral<"long_conv_to_ovf_u8", LREG, LREG, NONE>;

/* mono_decompose_long_opts (>; depends on the order here */
def OP_LCEQ   : OpcodeGeneral<"long_ceq", IREG, NONE, NONE>;
def OP_LCGT   : OpcodeGeneral<"long_cgt", IREG, NONE, NONE>;
def OP_LCGT_UN : OpcodeGeneral<"long_cgt_un", IREG, NONE, NONE>;
def OP_LCLT   : OpcodeGeneral<"long_clt", IREG, NONE, NONE>;
def OP_LCLT_UN : OpcodeGeneral<"long_clt_un", IREG, NONE, NONE>;

def OP_LCONV_TO_R_UN : OpcodeGeneral<"long_conv_to_r_un", FREG, LREG, NONE>;
def OP_LCONV_TO_U   : OpcodeGeneral<"long_conv_to_u", IREG, LREG, NONE>;

def OP_LADD_IMM    : OpcodeGeneral<"long_add_imm", LREG, LREG, NONE>;
def OP_LSUB_IMM    : OpcodeGeneral<"long_sub_imm", LREG, LREG, NONE>;
def OP_LMUL_IMM    : OpcodeGeneral<"long_mul_imm", LREG, LREG, NONE>;
def OP_LAND_IMM    : OpcodeGeneral<"long_and_imm", LREG, LREG, NONE>;
def OP_LOR_IMM     : OpcodeGeneral<"long_or_imm", LREG, LREG, NONE>;
def OP_LXOR_IMM    : OpcodeGeneral<"long_xor_imm", LREG, LREG, NONE>;
def OP_LSHL_IMM    : OpcodeGeneral<"long_shl_imm", LREG, LREG, NONE>;
def OP_LSHR_IMM    : OpcodeGeneral<"long_shr_imm", LREG, LREG, NONE>;
def OP_LSHR_UN_IMM : OpcodeGeneral<"long_shr_un_imm", LREG, LREG, NONE>;
def OP_LDIV_IMM    : OpcodeGeneral<"long_div_imm", LREG, LREG, NONE>;
def OP_LDIV_UN_IMM : OpcodeGeneral<"long_div_un_imm", LREG, LREG, NONE>;
def OP_LREM_IMM    : OpcodeGeneral<"long_rem_imm", LREG, LREG, NONE>;
def OP_LREM_UN_IMM : OpcodeGeneral<"long_rem_un_imm", LREG, LREG, NONE>;

/* mono_decompose_long_opts (>; depends on the order here */
def OP_LBEQ    : OpcodeGeneral<"long_beq", NONE, NONE, NONE>;
def OP_LBGE    : OpcodeGeneral<"long_bge", NONE, NONE, NONE>;
def OP_LBGT    : OpcodeGeneral<"long_bgt", NONE, NONE, NONE>;
def OP_LBLE    : OpcodeGeneral<"long_ble", NONE, NONE, NONE>;
def OP_LBLT    : OpcodeGeneral<"long_blt", NONE, NONE, NONE>;
def OP_LBNE_UN : OpcodeGeneral<"long_bne_un", NONE, NONE, NONE>;
def OP_LBGE_UN : OpcodeGeneral<"long_bge_un", NONE, NONE, NONE>;
def OP_LBGT_UN : OpcodeGeneral<"long_bgt_un", NONE, NONE, NONE>;
def OP_LBLE_UN : OpcodeGeneral<"long_ble_un", NONE, NONE, NONE>;
def OP_LBLT_UN : OpcodeGeneral<"long_blt_un", NONE, NONE, NONE>;

/* Variants of the original opcodes which take the two parts of the long as two arguments */
def OP_LCONV_TO_R8_2 : OpcodeGeneral<"long_conv_to_r8_2", FREG, IREG, IREG>;
def OP_LCONV_TO_R4_2 : OpcodeGeneral<"long_conv_to_r4_2", FREG, IREG, IREG>;
def OP_LCONV_TO_R_UN_2 : OpcodeGeneral<"long_conv_to_r_un_2", FREG, IREG, IREG>;
def OP_LCONV_TO_OVF_I4_2 : OpcodeGeneral<"long_conv_to_ovf_i4_2", IREG, IREG, IREG>;

/* 32 bit opcodes: must be in the same order as the matching CEE_ opcodes: binops_op_map */
def OP_IADD    : OpcodeGeneral<"int_add", IREG, IREG, IREG>;
def OP_ISUB    : OpcodeGeneral<"int_sub", IREG, IREG, IREG>;
def OP_IMUL    : OpcodeGeneral<"int_mul", IREG, IREG, IREG>;
def OP_IDIV    : OpcodeGeneral<"int_div", IREG, IREG, IREG>;
def OP_IDIV_UN : OpcodeGeneral<"int_div_un", IREG, IREG, IREG>;
def OP_IREM    : OpcodeGeneral<"int_rem", IREG, IREG, IREG>;
def OP_IREM_UN : OpcodeGeneral<"int_rem_un", IREG, IREG, IREG>;
def OP_IAND    : OpcodeGeneral<"int_and", IREG, IREG, IREG>;
def OP_IOR     : OpcodeGeneral<"int_or", IREG, IREG, IREG>;
def OP_IXOR    : OpcodeGeneral<"int_xor", IREG, IREG, IREG>;
def OP_ISHL    : OpcodeGeneral<"int_shl", IREG, IREG, IREG>;
def OP_ISHR    : OpcodeGeneral<"int_shr", IREG, IREG, IREG>;
def OP_ISHR_UN : OpcodeGeneral<"int_shr_un", IREG, IREG, IREG>;

/* 32 bit opcodes: must be in the same order as the matching CEE_ opcodes: unops_op_map */
def OP_INEG       : OpcodeGeneral<"int_neg", IREG, IREG, NONE>;
def OP_INOT       : OpcodeGeneral<"int_not", IREG, IREG, NONE>;
def OP_ICONV_TO_I1 : OpcodeGeneral<"int_conv_to_i1", IREG, IREG, NONE>;
def OP_ICONV_TO_I2 : OpcodeGeneral<"int_conv_to_i2", IREG, IREG, NONE>;
def OP_ICONV_TO_I4 : OpcodeGeneral<"int_conv_to_i4", IREG, IREG, NONE>;
def OP_ICONV_TO_I8 : OpcodeGeneral<"int_conv_to_i8", LREG, IREG, NONE>;
def OP_ICONV_TO_R4 : OpcodeGeneral<"int_conv_to_r4", FREG, IREG, NONE>;
def OP_ICONV_TO_R8 : OpcodeGeneral<"int_conv_to_r8", FREG, IREG, NONE>;
def OP_ICONV_TO_U4 : OpcodeGeneral<"int_conv_to_u4", IREG, IREG, NONE>;
def OP_ICONV_TO_U8 : OpcodeGeneral<"int_conv_to_u8", LREG, IREG, NONE>;

def OP_ICONV_TO_R_UN : OpcodeGeneral<"int_conv_to_r_un", FREG, IREG, NONE>;
def OP_ICONV_TO_U   : OpcodeGeneral<"int_conv_to_u", IREG, IREG, NONE>;

/* 32 bit opcodes: must be in the same order as the matching CEE_ opcodes: ovfops_op_map */
def OP_ICONV_TO_U2   : OpcodeGeneral<"int_conv_to_u2", IREG, IREG, NONE>;
def OP_ICONV_TO_U1   : OpcodeGeneral<"int_conv_to_u1", IREG, IREG, NONE>;
def OP_ICONV_TO_I    : OpcodeGeneral<"int_conv_to_i", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_I : OpcodeGeneral<"int_conv_to_ovf_i", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U : OpcodeGeneral<"int_conv_to_ovf_u", IREG, IREG, NONE>;
def OP_IADD_OVF      : OpcodeGeneral<"int_add_ovf", IREG, IREG, IREG>;
def OP_IADD_OVF_UN   : OpcodeGeneral<"int_add_ovf_un", IREG, IREG, IREG>;
def OP_IMUL_OVF      : OpcodeGeneral<"int_mul_ovf", IREG, IREG, IREG>;
def OP_IMUL_OVF_UN   : OpcodeGeneral<"int_mul_ovf_un", IREG, IREG, IREG>;
def OP_ISUB_OVF      : OpcodeGeneral<"int_sub_ovf", IREG, IREG, IREG>;
def OP_ISUB_OVF_UN   : OpcodeGeneral<"int_sub_ovf_un", IREG, IREG, IREG>;

/* 32 bit opcodes: must be in the same order as the matching CEE_ opcodes: ovf2ops_op_map */
def OP_ICONV_TO_OVF_I1_UN : OpcodeGeneral<"int_conv_to_ovf_i1_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_I2_UN : OpcodeGeneral<"int_conv_to_ovf_i2_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_I4_UN : OpcodeGeneral<"int_conv_to_ovf_i4_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_I8_UN : OpcodeGeneral<"int_conv_to_ovf_i8_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U1_UN : OpcodeGeneral<"int_conv_to_ovf_u1_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U2_UN : OpcodeGeneral<"int_conv_to_ovf_u2_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U4_UN : OpcodeGeneral<"int_conv_to_ovf_u4_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U8_UN : OpcodeGeneral<"int_conv_to_ovf_u8_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_I_UN : OpcodeGeneral<"int_conv_to_ovf_i_un", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U_UN : OpcodeGeneral<"int_conv_to_ovf_u_un", IREG, IREG, NONE>;

/* 32 bit opcodes: must be in the same order as the matching CEE_ opcodes: ovf3ops_op_map */
def OP_ICONV_TO_OVF_I1 : OpcodeGeneral<"int_conv_to_ovf_i1", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U1 : OpcodeGeneral<"int_conv_to_ovf_u1", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_I2 : OpcodeGeneral<"int_conv_to_ovf_i2", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U2 : OpcodeGeneral<"int_conv_to_ovf_u2", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_I4 : OpcodeGeneral<"int_conv_to_ovf_i4", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U4 : OpcodeGeneral<"int_conv_to_ovf_u4", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_I8 : OpcodeGeneral<"int_conv_to_ovf_i8", IREG, IREG, NONE>;
def OP_ICONV_TO_OVF_U8 : OpcodeGeneral<"int_conv_to_ovf_u8", IREG, IREG, NONE>;

def OP_IADC     : OpcodeGeneral<"int_adc", IREG, IREG, IREG>;
def OP_IADC_IMM : OpcodeGeneral<"int_adc_imm", IREG, IREG, NONE>;
def OP_ISBB     : OpcodeGeneral<"int_sbb", IREG, IREG, IREG>;
def OP_ISBB_IMM : OpcodeGeneral<"int_sbb_imm", IREG, IREG, NONE>;
def OP_IADDCC   : OpcodeGeneral<"int_addcc", IREG, IREG, IREG>;
def OP_ISUBCC   : OpcodeGeneral<"int_subcc", IREG, IREG, IREG>;

def OP_IADD_IMM    : OpcodeGeneral<"int_add_imm", IREG, IREG, NONE>;
def OP_ISUB_IMM    : OpcodeGeneral<"int_sub_imm", IREG, IREG, NONE>;
def OP_IMUL_IMM    : OpcodeGeneral<"int_mul_imm", IREG, IREG, NONE>;
def OP_IDIV_IMM    : OpcodeGeneral<"int_div_imm", IREG, IREG, NONE>;
def OP_IDIV_UN_IMM : OpcodeGeneral<"int_div_un_imm", IREG, IREG, NONE>;
def OP_IREM_IMM    : OpcodeGeneral<"int_rem_imm", IREG, IREG, NONE>;
def OP_IREM_UN_IMM : OpcodeGeneral<"int_rem_un_imm", IREG, IREG, NONE>;
def OP_IAND_IMM    : OpcodeGeneral<"int_and_imm", IREG, IREG, NONE>;
def OP_IOR_IMM     : OpcodeGeneral<"int_or_imm", IREG, IREG, NONE>;
def OP_IXOR_IMM    : OpcodeGeneral<"int_xor_imm", IREG, IREG, NONE>;
def OP_ISHL_IMM    : OpcodeGeneral<"int_shl_imm", IREG, IREG, NONE>;
def OP_ISHR_IMM    : OpcodeGeneral<"int_shr_imm", IREG, IREG, NONE>;
def OP_ISHR_UN_IMM : OpcodeGeneral<"int_shr_un_imm", IREG, IREG, NONE>;

def OP_ICEQ   : OpcodeGeneral<"int_ceq", IREG, NONE, NONE>;
def OP_ICGT   : OpcodeGeneral<"int_cgt", IREG, NONE, NONE>;
def OP_ICGT_UN : OpcodeGeneral<"int_cgt_un", IREG, NONE, NONE>;
def OP_ICLT   : OpcodeGeneral<"int_clt", IREG, NONE, NONE>;
def OP_ICLT_UN : OpcodeGeneral<"int_clt_un", IREG, NONE, NONE>;

def OP_ICNEQ  : OpcodeGeneral<"int_cneq", IREG, NONE, NONE>;
def OP_ICGE   : OpcodeGeneral<"int_cge", IREG, NONE, NONE>;
def OP_ICLE   : OpcodeGeneral<"int_cle", IREG, NONE, NONE>;
def OP_ICGE_UN : OpcodeGeneral<"int_cge_un", IREG, NONE, NONE>;
def OP_ICLE_UN : OpcodeGeneral<"int_cle_un", IREG, NONE, NONE>;

def OP_IBEQ    : OpcodeGeneral<"int_beq", NONE, NONE, NONE>;
def OP_IBGE    : OpcodeGeneral<"int_bge", NONE, NONE, NONE>;
def OP_IBGT    : OpcodeGeneral<"int_bgt", NONE, NONE, NONE>;
def OP_IBLE    : OpcodeGeneral<"int_ble", NONE, NONE, NONE>;
def OP_IBLT    : OpcodeGeneral<"int_blt", NONE, NONE, NONE>;
def OP_IBNE_UN : OpcodeGeneral<"int_bne_un", NONE, NONE, NONE>;
def OP_IBGE_UN : OpcodeGeneral<"int_bge_un", NONE, NONE, NONE>;
def OP_IBGT_UN : OpcodeGeneral<"int_bgt_un", NONE, NONE, NONE>;
def OP_IBLE_UN : OpcodeGeneral<"int_ble_un", NONE, NONE, NONE>;
def OP_IBLT_UN : OpcodeGeneral<"int_blt_un", NONE, NONE, NONE>;

def OP_FBEQ    : OpcodeGeneral<"float_beq", NONE, NONE, NONE>;
def OP_FBGE    : OpcodeGeneral<"float_bge", NONE, NONE, NONE>;
def OP_FBGT    : OpcodeGeneral<"float_bgt", NONE, NONE, NONE>;
def OP_FBLE    : OpcodeGeneral<"float_ble", NONE, NONE, NONE>;
def OP_FBLT    : OpcodeGeneral<"float_blt", NONE, NONE, NONE>;
def OP_FBNE_UN : OpcodeGeneral<"float_bne_un", NONE, NONE, NONE>;
def OP_FBGE_UN : OpcodeGeneral<"float_bge_un", NONE, NONE, NONE>;
def OP_FBGT_UN : OpcodeGeneral<"float_bgt_un", NONE, NONE, NONE>;
def OP_FBLE_UN : OpcodeGeneral<"float_ble_un", NONE, NONE, NONE>;
def OP_FBLT_UN : OpcodeGeneral<"float_blt_un", NONE, NONE, NONE>;

def OP_RBEQ    : OpcodeGeneral<"r4_beq", NONE, NONE, NONE>;
def OP_RBGE    : OpcodeGeneral<"r4_bge", NONE, NONE, NONE>;
def OP_RBGT    : OpcodeGeneral<"r4_bgt", NONE, NONE, NONE>;
def OP_RBLE    : OpcodeGeneral<"r4_ble", NONE, NONE, NONE>;
def OP_RBLT    : OpcodeGeneral<"r4_blt", NONE, NONE, NONE>;
def OP_RBNE_UN : OpcodeGeneral<"r4_bne_un", NONE, NONE, NONE>;
def OP_RBGE_UN : OpcodeGeneral<"r4_bge_un", NONE, NONE, NONE>;
def OP_RBGT_UN : OpcodeGeneral<"r4_bgt_un", NONE, NONE, NONE>;
def OP_RBLE_UN : OpcodeGeneral<"r4_ble_un", NONE, NONE, NONE>;
def OP_RBLT_UN : OpcodeGeneral<"r4_blt_un", NONE, NONE, NONE>;

/* float opcodes: must be in the same order as the matching CEE_ opcodes: binops_op_map */
def OP_FADD   : OpcodeGeneral<"float_add", FREG, FREG, FREG>;
def OP_FSUB   : OpcodeGeneral<"float_sub", FREG, FREG, FREG>;
def OP_FMUL   : OpcodeGeneral<"float_mul", FREG, FREG, FREG>;
def OP_FDIV   : OpcodeGeneral<"float_div", FREG, FREG, FREG>;
def OP_FDIV_UN : OpcodeGeneral<"float_div_un", FREG, FREG, FREG>;
def OP_FREM   : OpcodeGeneral<"float_rem", FREG, FREG, FREG>;
def OP_FREM_UN : OpcodeGeneral<"float_rem_un", FREG, FREG, FREG>;

/* r4 opcodes: must be in the same order as the matching CEE_ opcodes: binops_op_map */
def OP_RADD   : OpcodeGeneral<"r4_add", FREG, FREG, FREG>;
def OP_RSUB   : OpcodeGeneral<"r4_sub", FREG, FREG, FREG>;
def OP_RMUL   : OpcodeGeneral<"r4_mul", FREG, FREG, FREG>;
def OP_RDIV   : OpcodeGeneral<"r4_div", FREG, FREG, FREG>;
def OP_RDIV_UN : OpcodeGeneral<"r4_div_un", FREG, FREG, FREG>;
def OP_RREM   : OpcodeGeneral<"r4_rem", FREG, FREG, FREG>;
def OP_RREM_UN : OpcodeGeneral<"r4_rem_un", FREG, FREG, FREG>;

/* float opcodes: must be in the same order as the matching CEE_ opcodes: unops_op_map */
def OP_FNEG       : OpcodeGeneral<"float_neg", FREG, FREG, NONE>;
def OP_FNOT       : OpcodeGeneral<"float_not", FREG, FREG, NONE>;
def OP_FCONV_TO_I1 : OpcodeGeneral<"float_conv_to_i1", IREG, FREG, NONE>;
def OP_FCONV_TO_I2 : OpcodeGeneral<"float_conv_to_i2", IREG, FREG, NONE>;
def OP_FCONV_TO_I4 : OpcodeGeneral<"float_conv_to_i4", IREG, FREG, NONE>;
def OP_FCONV_TO_I8 : OpcodeGeneral<"float_conv_to_i8", LREG, FREG, NONE>;
def OP_FCONV_TO_R4 : OpcodeGeneral<"float_conv_to_r4", FREG, FREG, NONE>;
def OP_FCONV_TO_R8 : OpcodeGeneral<"float_conv_to_r8", FREG, FREG, NONE>;
def OP_FCONV_TO_U4 : OpcodeGeneral<"float_conv_to_u4", IREG, FREG, NONE>;
def OP_FCONV_TO_U8 : OpcodeGeneral<"float_conv_to_u8", LREG, FREG, NONE>;

def OP_RNEG       : OpcodeGeneral<"r4_neg", FREG, FREG, NONE>;
def OP_RNOT       : OpcodeGeneral<"r4_not", FREG, FREG, NONE>;
def OP_RCONV_TO_I1 : OpcodeGeneral<"r4_conv_to_i1", IREG, FREG, NONE>;
def OP_RCONV_TO_I2 : OpcodeGeneral<"r4_conv_to_i2", IREG, FREG, NONE>;
def OP_RCONV_TO_I4 : OpcodeGeneral<"r4_conv_to_i4", IREG, FREG, NONE>;
def OP_RCONV_TO_I8 : OpcodeGeneral<"r4_conv_to_i8", LREG, FREG, NONE>;
def OP_RCONV_TO_R4 : OpcodeGeneral<"r4_conv_to_r4", FREG, FREG, NONE>;
def OP_RCONV_TO_R8 : OpcodeGeneral<"r4_conv_to_r8", FREG, FREG, NONE>;
def OP_RCONV_TO_U4 : OpcodeGeneral<"r4_conv_to_u4", IREG, FREG, NONE>;
def OP_RCONV_TO_U8 : OpcodeGeneral<"r4_conv_to_u8", LREG, FREG, NONE>;

/* float opcodes: must be in the same order as the matching CEE_ opcodes: ovfops_op_map */
def OP_FCONV_TO_U2   : OpcodeGeneral<"float_conv_to_u2", IREG, FREG, NONE>;
def OP_FCONV_TO_U1   : OpcodeGeneral<"float_conv_to_u1", IREG, FREG, NONE>;
def OP_FCONV_TO_I    : OpcodeGeneral<"float_conv_to_i", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_I : OpcodeGeneral<"float_conv_to_ovf_i", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U : OpcodeGeneral<"float_conv_to_ovd_u", IREG, FREG, NONE>;

/* float opcodes: must be in the same order as the matching CEE_ opcodes: ovfops_op_map */
def OP_FADD_OVF      : OpcodeGeneral<"float_add_ovf", FREG, FREG, FREG>;
def OP_FADD_OVF_UN   : OpcodeGeneral<"float_add_ovf_un", FREG, FREG, FREG>;
def OP_FMUL_OVF      : OpcodeGeneral<"float_mul_ovf", FREG, FREG, FREG>;
def OP_FMUL_OVF_UN   : OpcodeGeneral<"float_mul_ovf_un", FREG, FREG, FREG>;
def OP_FSUB_OVF      : OpcodeGeneral<"float_sub_ovf", FREG, FREG, FREG>;
def OP_FSUB_OVF_UN   : OpcodeGeneral<"float_sub_ovf_un", FREG, FREG, FREG>;

def OP_FCONV_TO_OVF_I1_UN : OpcodeGeneral<"float_conv_to_ovf_i1_un", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_I2_UN : OpcodeGeneral<"float_conv_to_ovf_i2_un", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_I4_UN : OpcodeGeneral<"float_conv_to_ovf_i4_un", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_I8_UN : OpcodeGeneral<"float_conv_to_ovf_i8_un", LREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U1_UN : OpcodeGeneral<"float_conv_to_ovf_u1_un", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U2_UN : OpcodeGeneral<"float_conv_to_ovf_u2_un", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U4_UN : OpcodeGeneral<"float_conv_to_ovf_u4_un", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U8_UN : OpcodeGeneral<"float_conv_to_ovf_u8_un", LREG, FREG, NONE>;
def OP_FCONV_TO_OVF_I_UN : OpcodeGeneral<"float_conv_to_ovf_i_un", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U_UN : OpcodeGeneral<"float_conv_to_ovf_u_un", IREG, FREG, NONE>;

def OP_FCONV_TO_OVF_I1 : OpcodeGeneral<"float_conv_to_ovf_i1", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U1 : OpcodeGeneral<"float_conv_to_ovf_u1", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_I2 : OpcodeGeneral<"float_conv_to_ovf_i2", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U2 : OpcodeGeneral<"float_conv_to_ovf_u2", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_I4 : OpcodeGeneral<"float_conv_to_ovf_i4", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U4 : OpcodeGeneral<"float_conv_to_ovf_u4", IREG, FREG, NONE>;
def OP_FCONV_TO_OVF_I8 : OpcodeGeneral<"float_conv_to_ovf_i8", LREG, FREG, NONE>;
def OP_FCONV_TO_OVF_U8 : OpcodeGeneral<"float_conv_to_ovf_u8", LREG, FREG, NONE>;

/* These do the comparison too */
def OP_FCEQ   : OpcodeGeneral<"float_ceq", IREG, FREG, FREG>;
def OP_FCGT   : OpcodeGeneral<"float_cgt", IREG, FREG, FREG>;
def OP_FCGT_UN : OpcodeGeneral<"float_cgt_un", IREG, FREG, FREG>;
def OP_FCLT   : OpcodeGeneral<"float_clt", IREG, FREG, FREG>;
def OP_FCLT_UN : OpcodeGeneral<"float_clt_un", IREG, FREG, FREG>;

def OP_FCNEQ  : OpcodeGeneral<"float_cneq", IREG, FREG, FREG>;
def OP_FCGE   : OpcodeGeneral<"float_cge", IREG, FREG, FREG>;
def OP_FCLE   : OpcodeGeneral<"float_cle", IREG, FREG, FREG>;

def OP_FCEQ_MEMBASE   : OpcodeGeneral<"float_ceq_membase", IREG, FREG, IREG>;
def OP_FCGT_MEMBASE   : OpcodeGeneral<"float_cgt_membase", IREG, FREG, IREG>;
def OP_FCGT_UN_MEMBASE : OpcodeGeneral<"float_cgt_un_membase", IREG, FREG, IREG>;
def OP_FCLT_MEMBASE   : OpcodeGeneral<"float_clt_membase", IREG, FREG, IREG>;
def OP_FCLT_UN_MEMBASE : OpcodeGeneral<"float_clt_un_membase", IREG, FREG, IREG>;

def OP_FCONV_TO_U : OpcodeGeneral<"float_conv_to_u", IREG, FREG, NONE>;
def OP_CKFINITE : Opcode<FREG, FREG, NONE>;

/* r4 opcodes: must be in the same order as the matching CEE_ opcodes: ovfops_op_map */
def OP_RCONV_TO_U2   : OpcodeGeneral<"r4_conv_to_u2", IREG, FREG, NONE>;
def OP_RCONV_TO_U1   : OpcodeGeneral<"r4_conv_to_u1", IREG, FREG, NONE>;
def OP_RCONV_TO_I    : OpcodeGeneral<"r4_conv_to_i", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_I : OpcodeGeneral<"r4_conv_to_ovf_i", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U : OpcodeGeneral<"r4_conv_to_ovd_u", IREG, FREG, NONE>;

/* r4 opcodes: must be in the same order as the matching CEE_ opcodes: ovfops_op_map */
def OP_RADD_OVF      : OpcodeGeneral<"r4_add_ovf", FREG, FREG, FREG>;
def OP_RADD_OVF_UN   : OpcodeGeneral<"r4_add_ovf_un", FREG, FREG, FREG>;
def OP_RMUL_OVF      : OpcodeGeneral<"r4_mul_ovf", FREG, FREG, FREG>;
def OP_RMUL_OVF_UN   : OpcodeGeneral<"r4_mul_ovf_un", FREG, FREG, FREG>;
def OP_RSUB_OVF      : OpcodeGeneral<"r4_sub_ovf", FREG, FREG, FREG>;
def OP_RSUB_OVF_UN   : OpcodeGeneral<"r4_sub_ovf_un", FREG, FREG, FREG>;

def OP_RCONV_TO_OVF_I1_UN : OpcodeGeneral<"r4_conv_to_ovf_i1_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_I2_UN : OpcodeGeneral<"r4_conv_to_ovf_i2_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_I4_UN : OpcodeGeneral<"r4_conv_to_ovf_i4_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_I8_UN : OpcodeGeneral<"r4_conv_to_ovf_i8_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U1_UN : OpcodeGeneral<"r4_conv_to_ovf_u1_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U2_UN : OpcodeGeneral<"r4_conv_to_ovf_u2_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U4_UN : OpcodeGeneral<"r4_conv_to_ovf_u4_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U8_UN : OpcodeGeneral<"r4_conv_to_ovf_u8_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_I_UN : OpcodeGeneral<"r4_conv_to_ovf_i_un", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U_UN : OpcodeGeneral<"r4_conv_to_ovf_u_un", IREG, FREG, NONE>;

def OP_RCONV_TO_OVF_I1 : OpcodeGeneral<"r4_conv_to_ovf_i1", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U1 : OpcodeGeneral<"r4_conv_to_ovf_u1", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_I2 : OpcodeGeneral<"r4_conv_to_ovf_i2", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U2 : OpcodeGeneral<"r4_conv_to_ovf_u2", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_I4 : OpcodeGeneral<"r4_conv_to_ovf_i4", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U4 : OpcodeGeneral<"r4_conv_to_ovf_u4", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_I8 : OpcodeGeneral<"r4_conv_to_ovf_i8", IREG, FREG, NONE>;
def OP_RCONV_TO_OVF_U8 : OpcodeGeneral<"r4_conv_to_ovf_u8", IREG, FREG, NONE>;

/* r4 opcodes: must be in the same order as the matching CEE_ opcodes: ceqops_op_map */
def OP_RCEQ   : OpcodeGeneral<"r4_ceq", IREG, FREG, FREG>;
def OP_RCGT   : OpcodeGeneral<"r4_cgt", IREG, FREG, FREG>;
def OP_RCGT_UN : OpcodeGeneral<"r4_cgt_un", IREG, FREG, FREG>;
def OP_RCLT   : OpcodeGeneral<"r4_clt", IREG, FREG, FREG>;
def OP_RCLT_UN : OpcodeGeneral<"r4_clt_un", IREG, FREG, FREG>;

def OP_RCNEQ  : OpcodeGeneral<"r4_cneq", IREG, FREG, FREG>;
def OP_RCGE   : OpcodeGeneral<"r4_cge", IREG, FREG, FREG>;
def OP_RCLE   : OpcodeGeneral<"r4_cle", IREG, FREG, FREG>;

/* Return the low 32 bits of a double vreg */
def OP_FGETLOW32 : OpcodeGeneral<"float_getlow32", IREG, FREG, NONE>;
/* Return the high 32 bits of a double vreg */
def OP_FGETHIGH32 : OpcodeGeneral<"float_gethigh32", IREG, FREG, NONE>;

def OP_JUMP_TABLE : Opcode<IREG, NONE, NONE>;

/* aot compiler */
def OP_AOTCONST : Opcode<IREG, NONE, NONE>;
def OP_PATCH_INFO : Opcode<NONE, NONE, NONE>;
def OP_GOT_ENTRY : Opcode<IREG, IREG, NONE>;

/* inline (long>;int * (long>;int */
def OP_BIGMUL : Opcode<LREG, IREG, IREG>;
def OP_BIGMUL_UN : Opcode<LREG, IREG, IREG>;
def OP_IMIN_UN : OpcodeGeneral<"int_min_un", IREG, IREG, IREG>;
def OP_IMAX_UN : OpcodeGeneral<"int_max_un", IREG, IREG, IREG>;
def OP_LMIN_UN : OpcodeGeneral<"long_min_un", LREG, LREG, LREG>;
def OP_LMAX_UN : OpcodeGeneral<"long_max_un", LREG, LREG, LREG>;

def OP_MIN : Opcode<IREG, IREG, IREG>;
def OP_MAX : Opcode<IREG, IREG, IREG>;

def OP_IMIN : OpcodeGeneral<"int_min", IREG, IREG, IREG>;
def OP_IMAX : OpcodeGeneral<"int_max", IREG, IREG, IREG>;
def OP_LMIN : OpcodeGeneral<"long_min", LREG, LREG, LREG>;
def OP_LMAX : OpcodeGeneral<"long_max", LREG, LREG, LREG>;
def OP_RMAX     : Opcode<FREG, FREG, FREG>;
def OP_RPOW     : Opcode<FREG, FREG, FREG>;

/* opcodes most architecture have */
def OP_ADC     : Opcode<IREG, IREG, IREG>;
def OP_ADC_IMM : Opcode<IREG, IREG, NONE>;
def OP_SBB     : Opcode<IREG, IREG, IREG>;
def OP_SBB_IMM : Opcode<IREG, IREG, NONE>;
def OP_ADDCC   : Opcode<IREG, IREG, IREG>;
def OP_ADDCC_IMM   : Opcode<IREG, IREG, NONE>;
def OP_SUBCC   : Opcode<IREG, IREG, IREG>;
def OP_SUBCC_IMM   : Opcode<IREG, IREG, NONE>;
def OP_BR_REG  : Opcode<NONE, IREG, NONE>;
def OP_SEXT_I1  : Opcode<IREG, IREG, NONE>;
def OP_SEXT_I2  : Opcode<IREG, IREG, NONE>;
def OP_SEXT_I4  : Opcode<LREG, IREG, NONE>;
def OP_ZEXT_I1  : Opcode<IREG, IREG, NONE>;
def OP_ZEXT_I2  : Opcode<IREG, IREG, NONE>;
def OP_ZEXT_I4  : Opcode<LREG, IREG, NONE>;
def OP_CNE      : Opcode<NONE, NONE, NONE>;
def OP_TRUNC_I4 : Opcode<IREG, LREG, NONE>;
/* to implement the upper half of long32 add and sub */
def OP_ADD_OVF_CARRY   : Opcode<IREG, IREG, IREG>;
def OP_SUB_OVF_CARRY   : Opcode<IREG, IREG, IREG>;
def OP_ADD_OVF_UN_CARRY   : Opcode<IREG, IREG, IREG>;
def OP_SUB_OVF_UN_CARRY   : Opcode<IREG, IREG, IREG>;

/* instructions with explicit long arguments to deal with 64-bit ilp32 machines */
def OP_LADDCC   : Opcode<LREG, LREG, LREG>;
def OP_LSUBCC   : Opcode<LREG, LREG, LREG>;

/* FP functions usually done by the CPU */
def OP_SIN     : Opcode<FREG, FREG, NONE>;
def OP_COS     : Opcode<FREG, FREG, NONE>;
def OP_ABS     : Opcode<FREG, FREG, NONE>;
def OP_TAN     : Opcode<FREG, FREG, NONE>;
def OP_ATAN    : Opcode<FREG, FREG, NONE>;
def OP_SQRT    : Opcode<FREG, FREG, NONE>;
def OP_ROUND   : Opcode<FREG, FREG, NONE>;
def OP_SINF     : Opcode<FREG, FREG, NONE>;
def OP_COSF     : Opcode<FREG, FREG, NONE>;
def OP_ABSF     : Opcode<FREG, FREG, NONE>;
def OP_SQRTF    : Opcode<FREG, FREG, NONE>;

/* arch-dep tls access */
def OP_TLS_GET            : Opcode<IREG, NONE, NONE>;
def OP_TLS_GET_REG        : Opcode<IREG, IREG, NONE>;
/* inst_offset contains the TLS offset */
def OP_TLS_SET            : Opcode<NONE, IREG, NONE>;
def OP_TLS_SET_REG        : Opcode<NONE, IREG, IREG>;

/* SIMD opcodes. */

let arch="X86,AMD64" in {

def OP_ADDPS : Opcode<XREG, XREG, XREG>;
def OP_DIVPS : Opcode<XREG, XREG, XREG>;
def OP_MULPS : Opcode<XREG, XREG, XREG>;
def OP_SUBPS : Opcode<XREG, XREG, XREG>;
def OP_MAXPS : Opcode<XREG, XREG, XREG>;
def OP_MINPS : Opcode<XREG, XREG, XREG>;
def OP_COMPPS : Opcode<XREG, XREG, XREG>;
def OP_ANDPS : Opcode<XREG, XREG, XREG>;
def OP_ANDNPS : Opcode<XREG, XREG, XREG>;
def OP_ORPS : Opcode<XREG, XREG, XREG>;
def OP_XORPS : Opcode<XREG, XREG, XREG>;
def OP_HADDPS : Opcode<XREG, XREG, XREG>;
def OP_HSUBPS : Opcode<XREG, XREG, XREG>;
def OP_ADDSUBPS : Opcode<XREG, XREG, XREG>;
def OP_DUPPS_LOW : Opcode<XREG, XREG, NONE>;
def OP_DUPPS_HIGH : Opcode<XREG, XREG, NONE>;

def OP_RSQRTPS : Opcode<XREG, XREG, NONE>;
def OP_SQRTPS : Opcode<XREG, XREG, NONE>;
def OP_RCPPS : Opcode<XREG, XREG, NONE>;

def OP_PSHUFLEW_HIGH : OpcodeGeneral<"pshufflew_high", XREG, XREG, NONE>;
def OP_PSHUFLEW_LOW : OpcodeGeneral<"pshufflew_low", XREG, XREG, NONE>;
def OP_PSHUFLED : OpcodeGeneral<"pshuffled", XREG, XREG, NONE>;
def OP_SHUFPS : Opcode<XREG, XREG, XREG>;
def OP_SHUFPD : Opcode<XREG, XREG, XREG>;

def OP_ADDPD : Opcode<XREG, XREG, XREG>;
def OP_DIVPD : Opcode<XREG, XREG, XREG>;
def OP_MULPD : Opcode<XREG, XREG, XREG>;
def OP_SUBPD : Opcode<XREG, XREG, XREG>;
def OP_MAXPD : Opcode<XREG, XREG, XREG>;
def OP_MINPD : Opcode<XREG, XREG, XREG>;
def OP_COMPPD : Opcode<XREG, XREG, XREG>;
def OP_ANDPD : Opcode<XREG, XREG, XREG>;
def OP_ANDNPD : Opcode<XREG, XREG, XREG>;
def OP_ORPD : Opcode<XREG, XREG, XREG>;
def OP_XORPD : Opcode<XREG, XREG, XREG>;
def OP_HADDPD : Opcode<XREG, XREG, XREG>;
def OP_HSUBPD : Opcode<XREG, XREG, XREG>;
def OP_ADDSUBPD : Opcode<XREG, XREG, XREG>;
def OP_DUPPD : Opcode<XREG, XREG, NONE>;

def OP_SQRTPD : Opcode<XREG, XREG, NONE>;

def OP_EXTRACT_MASK : Opcode<IREG, XREG, NONE>;

def OP_PAND : Opcode<XREG, XREG, XREG>;
def OP_POR : Opcode<XREG, XREG, XREG>;
def OP_PXOR : Opcode<XREG, XREG, XREG>;

def OP_PADDB : Opcode<XREG, XREG, XREG>;
def OP_PADDW : Opcode<XREG, XREG, XREG>;
def OP_PADDD : Opcode<XREG, XREG, XREG>;
def OP_PADDQ : Opcode<XREG, XREG, XREG>;

def OP_PSUBB : Opcode<XREG, XREG, XREG>;
def OP_PSUBW : Opcode<XREG, XREG, XREG>;
def OP_PSUBD : Opcode<XREG, XREG, XREG>;
def OP_PSUBQ : Opcode<XREG, XREG, XREG>;

def OP_PMAXB_UN : Opcode<XREG, XREG, XREG>;
def OP_PMAXW_UN : Opcode<XREG, XREG, XREG>;
def OP_PMAXD_UN : Opcode<XREG, XREG, XREG>;

def OP_PMAXB : Opcode<XREG, XREG, XREG>;
def OP_PMAXW : Opcode<XREG, XREG, XREG>;
def OP_PMAXD : Opcode<XREG, XREG, XREG>;

def OP_PAVGB_UN : Opcode<XREG, XREG, XREG>;
def OP_PAVGW_UN : Opcode<XREG, XREG, XREG>;

def OP_PMINB_UN : Opcode<XREG, XREG, XREG>;
def OP_PMINW_UN : Opcode<XREG, XREG, XREG>;
def OP_PMIND_UN : Opcode<XREG, XREG, XREG>;

def OP_PMINB : Opcode<XREG, XREG, XREG>;
def OP_PMINW : Opcode<XREG, XREG, XREG>;
def OP_PMIND : Opcode<XREG, XREG, XREG>;

def OP_PCMPEQB : Opcode<XREG, XREG, XREG>;
def OP_PCMPEQW : Opcode<XREG, XREG, XREG>;
def OP_PCMPEQD : Opcode<XREG, XREG, XREG>;
def OP_PCMPEQQ : Opcode<XREG, XREG, XREG>;

def OP_PCMPGTB : Opcode<XREG, XREG, XREG>;
def OP_PCMPGTW : Opcode<XREG, XREG, XREG>;
def OP_PCMPGTD : Opcode<XREG, XREG, XREG>;
def OP_PCMPGTQ : Opcode<XREG, XREG, XREG>;

def OP_PSUM_ABS_DIFF : OpcodeGeneral<"psumabsdiff", XREG, XREG, XREG>;

def OP_UNPACK_LOWB : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_LOWW : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_LOWD : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_LOWQ : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_LOWPS : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_LOWPD : Opcode<XREG, XREG, XREG>;

def OP_UNPACK_HIGHB : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_HIGHW : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_HIGHD : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_HIGHQ : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_HIGHPS : Opcode<XREG, XREG, XREG>;
def OP_UNPACK_HIGHPD : Opcode<XREG, XREG, XREG>;

def OP_PACKW : Opcode<XREG, XREG, XREG>;
def OP_PACKD : Opcode<XREG, XREG, XREG>;

def OP_PACKW_UN : Opcode<XREG, XREG, XREG>;
def OP_PACKD_UN : Opcode<XREG, XREG, XREG>;

def OP_PADDB_SAT : Opcode<XREG, XREG, XREG>;
def OP_PADDB_SAT_UN : Opcode<XREG, XREG, XREG>;

def OP_PADDW_SAT : Opcode<XREG, XREG, XREG>;
def OP_PADDW_SAT_UN : Opcode<XREG, XREG, XREG>;

def OP_PSUBB_SAT : Opcode<XREG, XREG, XREG>;
def OP_PSUBB_SAT_UN : Opcode<XREG, XREG, XREG>;

def OP_PSUBW_SAT : Opcode<XREG, XREG, XREG>;
def OP_PSUBW_SAT_UN : Opcode<XREG, XREG, XREG>;

def OP_PMULW : Opcode<XREG, XREG, XREG>;
def OP_PMULD : Opcode<XREG, XREG, XREG>;
/* Multiplies two 32 bit numbers into a 64 bit one */
def OP_PMULQ : Opcode<XREG, XREG, XREG>;

def OP_PMULW_HIGH_UN : OpcodeGeneral<"pmul_high_un", XREG, XREG, XREG>;
def OP_PMULW_HIGH : OpcodeGeneral<"pmul_high", XREG, XREG, XREG>;

/*SSE2 Shift ops must have the _reg version right after as code depends on this ordering.*/ 
def OP_PSHRW : Opcode<XREG, XREG, NONE>;
def OP_PSHRW_REG : Opcode<XREG, XREG, XREG>;

def OP_PSARW : Opcode<XREG, XREG, NONE>;
def OP_PSARW_REG : Opcode<XREG, XREG, XREG>;

def OP_PSHLW : Opcode<XREG, XREG, NONE>;
def OP_PSHLW_REG : Opcode<XREG, XREG, XREG>;

def OP_PSHRD : Opcode<XREG, XREG, NONE>;
def OP_PSHRD_REG : Opcode<XREG, XREG, XREG>;

def OP_PSHRQ : Opcode<XREG, XREG, NONE>;
def OP_PSHRQ_REG : Opcode<XREG, XREG, XREG>;

def OP_PSARD : Opcode<XREG, XREG, NONE>;
def OP_PSARD_REG : Opcode<XREG, XREG, XREG>;

def OP_PSHLD : Opcode<XREG, XREG, NONE>;
def OP_PSHLD_REG : Opcode<XREG, XREG, XREG>;

def OP_PSHLQ : Opcode<XREG, XREG, NONE>;
def OP_PSHLQ_REG : Opcode<XREG, XREG, XREG>;

def OP_EXTRACT_I4 : Opcode<IREG, XREG, NONE>;
def OP_ICONV_TO_R4_RAW : Opcode<FREG, IREG, NONE>;

def OP_EXTRACT_I2 : Opcode<IREG, XREG, NONE>;
def OP_EXTRACT_U2 : Opcode<IREG, XREG, NONE>;
def OP_EXTRACT_I1 : Opcode<IREG, XREG, NONE>;
def OP_EXTRACT_U1 : Opcode<IREG, XREG, NONE>;
def OP_EXTRACT_R8 : Opcode<FREG, XREG, NONE>;
def OP_EXTRACT_I8 : Opcode<LREG, XREG, NONE>;

/* Used by LLVM */
def OP_INSERT_I1 : Opcode<XREG, XREG, IREG>;
def OP_INSERT_I4 : Opcode<XREG, XREG, IREG>;
def OP_INSERT_I8 : Opcode<XREG, XREG, LREG>;
def OP_INSERT_R4 : Opcode<XREG, XREG, FREG>;
def OP_INSERT_R8 : Opcode<XREG, XREG, FREG>;

def OP_INSERT_I2 : Opcode<XREG, XREG, IREG>;

def OP_EXTRACTX_U2 : Opcode<IREG, XREG, NONE>;

/*these slow ops are modeled around the availability of a fast 2 bytes insert op*/
/*insertx_u1_slow takes old value and new value as source regs */
def OP_INSERTX_U1_SLOW : Opcode<XREG, IREG, IREG>;
/*insertx_i4_slow takes target xreg and new value as source regs */
def OP_INSERTX_I4_SLOW : Opcode<XREG, XREG, IREG>;

def OP_INSERTX_R4_SLOW : Opcode<XREG, XREG, FREG>;
def OP_INSERTX_R8_SLOW : Opcode<XREG, XREG, FREG>;
def OP_INSERTX_I8_SLOW : Opcode<XREG, XREG, LREG>;

def OP_FCONV_TO_R8_X : Opcode<XREG, FREG, NONE>;
def OP_XCONV_R8_TO_I4 : Opcode<IREG, XREG, NONE>;
def OP_ICONV_TO_X : Opcode<XREG, IREG, NONE>;

def OP_EXPAND_I1 : Opcode<XREG, IREG, NONE>;
def OP_EXPAND_I2 : Opcode<XREG, IREG, NONE>;
def OP_EXPAND_I4 : Opcode<XREG, IREG, NONE>;
def OP_EXPAND_R4 : Opcode<XREG, FREG, NONE>;
def OP_EXPAND_I8 : Opcode<XREG, IREG, NONE>;
def OP_EXPAND_R8 : Opcode<XREG, FREG, NONE>;

def OP_PREFETCH_MEMBASE : Opcode<NONE, IREG, NONE>;

def OP_CVTDQ2PD : Opcode<XREG, XREG, NONE>;
def OP_CVTDQ2PS : Opcode<XREG, XREG, NONE>;
def OP_CVTPD2DQ : Opcode<XREG, XREG, NONE>;
def OP_CVTPD2PS : Opcode<XREG, XREG, NONE>;
def OP_CVTPS2DQ : Opcode<XREG, XREG, NONE>;
def OP_CVTPS2PD : Opcode<XREG, XREG, NONE>;
def OP_CVTTPD2DQ : Opcode<XREG, XREG, NONE>;
def OP_CVTTPS2DQ : Opcode<XREG, XREG, NONE>;

/* r4 dot product */
/* multiply all 4 single precision float elements, add them together, and store the result to the lowest element */
def OP_DPPS : Opcode<XREG, XREG, XREG>;

/* sse 4.1 */

/* inst_c0 is the rounding mode: 0 = round, 1 = floor, 2 = ceiling */
def OP_SSE41_ROUNDPD : OpcodeGeneral<"roundpd", XREG, XREG, NONE>;

}

def OP_XMOVE   : Opcode<XREG, XREG, NONE>;
def OP_XZERO   : Opcode<XREG, NONE, NONE>;
def OP_XONES   : Opcode<XREG, NONE, NONE>;
def OP_XPHI : Opcode<XREG, NONE, NONE>;

/*
 * These are used for efficient implementation of the
 * atomic methods on Interlocked, Volatile, and Thread.
 * This is done only on architectures that support it,
 * as per mono_arch_opcode_supported (>;.
 *
 * Note that while the 32-bit variants are used on
 * both 32-bit and 64-bit systems, the 64-bit variants
 * are only used if the system is 64-bit. If that is
 * not the case, the fallback code in the runtime is
 * used instead. This is done because decomposing the
 * 64-bit variants to instructions operating on 32-bit
 * registers is very complicated on some architectures.
 *
 * For memory_barrier and load/store instructions, the
 * inst.backend.memory_barrier_kind field indicates
 * which semantics to use.
 *
 * Where relevant, all of these return the new value at
 * the given memory location after performing the
 * operation.
 */

def OP_MEMORY_BARRIER : Opcode<NONE, NONE, NONE>;

def OP_ATOMIC_LOAD_I1 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_LOAD_I2 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_LOAD_I4 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_LOAD_I8 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_LOAD_U1 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_LOAD_U2 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_LOAD_U4 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_LOAD_U8 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_LOAD_R4 : Opcode<FREG, IREG, NONE>;
def OP_ATOMIC_LOAD_R8 : Opcode<FREG, IREG, NONE>;

def OP_ATOMIC_STORE_I1 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_STORE_I2 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_STORE_I4 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_STORE_I8 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_STORE_U1 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_STORE_U2 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_STORE_U4 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_STORE_U8 : Opcode<IREG, IREG, NONE>;
def OP_ATOMIC_STORE_R4 : Opcode<IREG, FREG, NONE>;
def OP_ATOMIC_STORE_R8 : Opcode<IREG, FREG, NONE>;

def OP_ATOMIC_ADD_I4 : Opcode<IREG, IREG, IREG>;
def OP_ATOMIC_ADD_I8 : Opcode<IREG, IREG, IREG>;

def OP_ATOMIC_EXCHANGE_I4 : Opcode<IREG, IREG, IREG>;
def OP_ATOMIC_EXCHANGE_I8 : Opcode<IREG, IREG, IREG>;

def OP_ATOMIC_CAS_I4 : Opcode3<IREG, IREG, IREG, IREG>;
def OP_ATOMIC_CAS_I8 : Opcode3<IREG, IREG, IREG, IREG>;

/* Conditional move opcodes.
 * Must be in the same order as the matching CEE_B... opcodes
 * sreg2 will be assigned to dreg if the condition is true.
 * sreg1 should be equal to dreg and models the fact the instruction doesn't necessary
 * modify dreg. The sreg1==dreg condition could be violated by SSA, so the local
 * register allocator or the code generator should generate a mov dreg, sreg1 before
 * the cmov in those cases.
 * These opcodes operate on pointer sized values.
 */
def OP_CMOV_IEQ    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_IGE    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_IGT    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_ILE    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_ILT    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_INE_UN : Opcode<IREG, IREG, IREG>;
def OP_CMOV_IGE_UN : Opcode<IREG, IREG, IREG>;
def OP_CMOV_IGT_UN : Opcode<IREG, IREG, IREG>;
def OP_CMOV_ILE_UN : Opcode<IREG, IREG, IREG>;
def OP_CMOV_ILT_UN : Opcode<IREG, IREG, IREG>;

def OP_CMOV_LEQ    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LGE    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LGT    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LLE    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LLT    : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LNE_UN : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LGE_UN : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LGT_UN : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LLE_UN : Opcode<IREG, IREG, IREG>;
def OP_CMOV_LLT_UN : Opcode<IREG, IREG, IREG>;

/* Debugging support */
/* 
 * Marks the start of the live range of the variable in inst_c0, that is the
 * first instruction where the variable has a value.
 */
def OP_LIVERANGE_START : Opcode<NONE, NONE, NONE>;
/* 
 * Marks the end of the live range of the variable in inst_c0, that is the
 * first instruction where the variable no longer has a value.
 */
def OP_LIVERANGE_END : Opcode<NONE, NONE, NONE>;

/* GC support */
/*
 * mono_arch_output_basic_block (>; will set the backend.pc_offset field to the current pc
 * offset.
 */
def OP_GC_LIVENESS_DEF : Opcode<NONE, NONE, NONE>;
def OP_GC_LIVENESS_USE : Opcode<NONE, NONE, NONE>;

/*
 * This marks the location inside a basic block where a GC tracked spill slot has been
 * defined. The spill slot is assumed to be alive until the end of the bblock.
 */
def OP_GC_SPILL_SLOT_LIVENESS_DEF : Opcode<NONE, NONE, NONE>;

/*
 * This marks the location inside a basic block where a GC tracked param area slot has
 * been defined. The slot is assumed to be alive until the next call.
 */
def OP_GC_PARAM_SLOT_LIVENESS_DEF : Opcode<NONE, NONE, NONE>;

def OP_GC_SAFE_POINT : Opcode<NONE, IREG, NONE>;

/*
 * Check if the class given by sreg1 was inited, if not, call
 * mono_generic_class_init_trampoline (>; though a trampoline.
 * Since the trampoline saves all registers, this doesn't clobber
 * any registers.
 */
def OP_GENERIC_CLASS_INIT : Opcode<NONE, IREG, NONE>;

/* Arch specific opcodes */
let arch="X86,AMD64" in {
def OP_X86_TEST_NULL          : Opcode<NONE, IREG, NONE>;
def OP_X86_COMPARE_MEMBASE_REG : Opcode<NONE, IREG, IREG>;
def OP_X86_COMPARE_MEMBASE_IMM : Opcode<NONE, IREG, NONE>;
def OP_X86_COMPARE_MEM_IMM    : Opcode<NONE, NONE, NONE>;
def OP_X86_COMPARE_MEMBASE8_IMM : Opcode<NONE, IREG, NONE>;
def OP_X86_COMPARE_REG_MEMBASE : Opcode<NONE, IREG, IREG>;
def OP_X86_INC_REG            : Opcode<IREG, IREG, NONE>;
def OP_X86_INC_MEMBASE        : Opcode<NONE, IREG, NONE>;
def OP_X86_DEC_REG            : Opcode<IREG, IREG, NONE>;
def OP_X86_DEC_MEMBASE        : Opcode<NONE, IREG, NONE>;
def OP_X86_ADD_MEMBASE_IMM    : Opcode<NONE, IREG, NONE>;
def OP_X86_SUB_MEMBASE_IMM    : Opcode<NONE, IREG, NONE>;
def OP_X86_AND_MEMBASE_IMM    : Opcode<NONE, IREG, NONE>;
def OP_X86_OR_MEMBASE_IMM     : Opcode<NONE, IREG, NONE>;
def OP_X86_XOR_MEMBASE_IMM    : Opcode<NONE, IREG, NONE>;
def OP_X86_ADD_MEMBASE_REG    : Opcode<NONE, IREG, IREG>;
def OP_X86_SUB_MEMBASE_REG    : Opcode<NONE, IREG, IREG>;
def OP_X86_AND_MEMBASE_REG    : Opcode<NONE, IREG, IREG>;
def OP_X86_OR_MEMBASE_REG     : Opcode<NONE, IREG, IREG>;
def OP_X86_XOR_MEMBASE_REG    : Opcode<NONE, IREG, IREG>;
def OP_X86_MUL_MEMBASE_REG    : Opcode<NONE, IREG, IREG>;

def OP_X86_ADD_REG_MEMBASE    : Opcode<IREG, IREG, IREG>;
def OP_X86_SUB_REG_MEMBASE    : Opcode<IREG, IREG, IREG>;
def OP_X86_MUL_REG_MEMBASE    : Opcode<IREG, IREG, IREG>;
def OP_X86_AND_REG_MEMBASE    : Opcode<IREG, IREG, IREG>;
def OP_X86_OR_REG_MEMBASE     : Opcode<IREG, IREG, IREG>;
def OP_X86_XOR_REG_MEMBASE    : Opcode<IREG, IREG, IREG>;

def OP_X86_PUSH_MEMBASE       : Opcode<NONE, IREG, NONE>;
def OP_X86_PUSH_IMM           : Opcode<NONE, NONE, NONE>;
def OP_X86_PUSH               : Opcode<NONE, IREG, NONE>;
def OP_X86_PUSH_OBJ           : Opcode<NONE, IREG, NONE>;
def OP_X86_PUSH_GOT_ENTRY     : Opcode<NONE, IREG, NONE>;
def OP_X86_LEA                : Opcode<IREG, IREG, IREG>;
def OP_X86_LEA_MEMBASE        : Opcode<IREG, IREG, NONE>;
def OP_X86_XCHG               : Opcode<NONE, IREG, IREG>;
def OP_X86_FPOP               : Opcode<NONE, FREG, NONE>;
def OP_X86_FP_LOAD_I8         : Opcode<FREG, IREG, NONE>;
def OP_X86_FP_LOAD_I4         : Opcode<FREG, IREG, NONE>;
def OP_X86_SETEQ_MEMBASE      : Opcode<NONE, IREG, NONE>;
def OP_X86_SETNE_MEMBASE      : Opcode<NONE, IREG, NONE>;
def OP_X86_FXCH               : Opcode<NONE, NONE, NONE>;
}

let arch="AMD64" in {
def OP_AMD64_TEST_NULL              : Opcode<NONE, IREG, NONE>;
def OP_AMD64_SET_XMMREG_R4          : Opcode<FREG, FREG, NONE>;
def OP_AMD64_SET_XMMREG_R8          : Opcode<FREG, FREG, NONE>;
def OP_AMD64_ICOMPARE_MEMBASE_REG   : Opcode<NONE, IREG, IREG>;
def OP_AMD64_ICOMPARE_MEMBASE_IMM   : Opcode<NONE, IREG, NONE>;
def OP_AMD64_ICOMPARE_REG_MEMBASE   : Opcode<NONE, IREG, IREG>;
def OP_AMD64_COMPARE_MEMBASE_REG    : Opcode<NONE, IREG, IREG>;
def OP_AMD64_COMPARE_MEMBASE_IMM    : Opcode<NONE, IREG, NONE>;
def OP_AMD64_COMPARE_REG_MEMBASE    : Opcode<NONE, IREG, IREG>;

def OP_AMD64_ADD_MEMBASE_REG        : Opcode<NONE, IREG, IREG>;
def OP_AMD64_SUB_MEMBASE_REG        : Opcode<NONE, IREG, IREG>;
def OP_AMD64_AND_MEMBASE_REG        : Opcode<NONE, IREG, IREG>;
def OP_AMD64_OR_MEMBASE_REG         : Opcode<NONE, IREG, IREG>;
def OP_AMD64_XOR_MEMBASE_REG        : Opcode<NONE, IREG, IREG>;
def OP_AMD64_MUL_MEMBASE_REG        : Opcode<NONE, IREG, IREG>;

def OP_AMD64_ADD_MEMBASE_IMM        : Opcode<NONE, IREG, NONE>;
def OP_AMD64_SUB_MEMBASE_IMM        : Opcode<NONE, IREG, NONE>;
def OP_AMD64_AND_MEMBASE_IMM        : Opcode<NONE, IREG, NONE>;
def OP_AMD64_OR_MEMBASE_IMM         : Opcode<NONE, IREG, NONE>;
def OP_AMD64_XOR_MEMBASE_IMM        : Opcode<NONE, IREG, NONE>;
def OP_AMD64_MUL_MEMBASE_IMM        : Opcode<NONE, IREG, NONE>;

def OP_AMD64_ADD_REG_MEMBASE        : Opcode<IREG, IREG, IREG>;
def OP_AMD64_SUB_REG_MEMBASE        : Opcode<IREG, IREG, IREG>;
def OP_AMD64_AND_REG_MEMBASE        : Opcode<IREG, IREG, IREG>;
def OP_AMD64_OR_REG_MEMBASE         : Opcode<IREG, IREG, IREG>;
def OP_AMD64_XOR_REG_MEMBASE        : Opcode<IREG, IREG, IREG>;
def OP_AMD64_MUL_REG_MEMBASE        : Opcode<IREG, IREG, IREG>;

def OP_AMD64_LOADI8_MEMINDEX        : Opcode<IREG, IREG, IREG>;
def OP_AMD64_SAVE_SP_TO_LMF         : Opcode<NONE, NONE, NONE>;
}

let arch="POWERPC" in {
def OP_PPC_SUBFIC             : Opcode<IREG, IREG, NONE>;
def OP_PPC_SUBFZE             : Opcode<IREG, IREG, NONE>;
def OP_PPC_CHECK_FINITE           : OpcodeGeneral<"ppc_check_finite", NONE, IREG, NONE>;
}

let arch="ARM,ARM64" in {
def OP_ARM_RSBS_IMM            : Opcode<IREG, IREG, NONE>;
def OP_ARM_RSC_IMM             : Opcode<IREG, IREG, NONE>;
/* Set dreg to an r4 value */
def OP_ARM_SETFREG_R4             : Opcode<FREG, FREG, NONE>;
}

let arch="SPARC" in {
def OP_SPARC_BRZ              : Opcode<NONE, NONE, NONE>;
def OP_SPARC_BRLEZ            : Opcode<NONE, NONE, NONE>;
def OP_SPARC_BRLZ             : Opcode<NONE, NONE, NONE>;
def OP_SPARC_BRNZ             : Opcode<NONE, NONE, NONE>;
def OP_SPARC_BRGZ             : Opcode<NONE, NONE, NONE>;
def OP_SPARC_BRGEZ            : Opcode<NONE, NONE, NONE>;
def OP_SPARC_COND_EXC_EQZ     : Opcode<NONE, NONE, NONE>;
def OP_SPARC_COND_EXC_GEZ     : Opcode<NONE, NONE, NONE>;
def OP_SPARC_COND_EXC_GTZ     : Opcode<NONE, NONE, NONE>;
def OP_SPARC_COND_EXC_LEZ     : Opcode<NONE, NONE, NONE>;
def OP_SPARC_COND_EXC_LTZ     : Opcode<NONE, NONE, NONE>;
def OP_SPARC_COND_EXC_NEZ     : Opcode<NONE, NONE, NONE>;
}

let arch="S390X" in {
def OP_S390_LOADARG	   : Opcode<NONE, NONE, NONE>;
def OP_S390_ARGREG 	   : Opcode<NONE, NONE, NONE>;
def OP_S390_ARGPTR 	   : Opcode<NONE, NONE, NONE>;
def OP_S390_STKARG 	   : Opcode<NONE, NONE, NONE>;
def OP_S390_MOVE	 	   : Opcode<IREG, IREG, NONE>;
def OP_S390_SETF4RET	   : Opcode<FREG, FREG, NONE>;
def OP_S390_BKCHAIN 	   : Opcode<IREG, IREG, NONE>;
def OP_S390_LADD          : OpcodeGeneral<"s390_long_add", LREG, IREG, IREG>;
def OP_S390_LADD_OVF      : OpcodeGeneral<"s390_long_add_ovf", LREG, IREG, IREG>;
def OP_S390_LADD_OVF_UN   : OpcodeGeneral<"s390_long_add_ovf_un", LREG, IREG, IREG>;
def OP_S390_LSUB          : OpcodeGeneral<"s390_long_sub", LREG, IREG, IREG>;
def OP_S390_LSUB_OVF      : OpcodeGeneral<"s390_long_sub_ovf", LREG, IREG, IREG>;
def OP_S390_LSUB_OVF_UN   : OpcodeGeneral<"s390_long_sub_ovf_un", LREG, IREG, IREG>;
def OP_S390_LNEG          : OpcodeGeneral<"s390_long_neg", LREG, IREG, IREG>;
def OP_S390_IADD_OVF       : OpcodeGeneral<"s390_int_add_ovf", IREG, IREG, IREG>;
def OP_S390_IADD_OVF_UN    : OpcodeGeneral<"s390_int_add_ovf_un", IREG, IREG, IREG>;
def OP_S390_ISUB_OVF       : OpcodeGeneral<"s390_int_sub_ovf", IREG, IREG, IREG>;
def OP_S390_ISUB_OVF_UN    : OpcodeGeneral<"s390_int_sub_ovf_un", IREG, IREG, IREG>;
def OP_S390_CRJ            : Opcode<IREG, IREG, IREG>;
def OP_S390_CLRJ           : OpcodeGeneral<"s390_crj_un", IREG, IREG, IREG>;
def OP_S390_CGRJ           : Opcode<LREG, LREG, IREG>;
def OP_S390_CLGRJ          : OpcodeGeneral<"s390_cgrj_un", LREG, LREG, IREG>;
def OP_S390_CIJ            : Opcode<IREG, NONE, NONE>;
def OP_S390_CLIJ           : OpcodeGeneral<"s390_cij_un", IREG, IREG, NONE>;
def OP_S390_CGIJ           : Opcode<LREG, NONE, NONE>;
def OP_S390_CLGIJ          : OpcodeGeneral<"s390_cgij_un", LREG, NONE, NONE>;
}

let arch="MIPS" in {
def OP_MIPS_BEQ   : Opcode<NONE, IREG, IREG>;
def OP_MIPS_BGEZ  : Opcode<NONE, IREG, NONE>;
def OP_MIPS_BGTZ  : Opcode<NONE, IREG, NONE>;
def OP_MIPS_BLEZ  : Opcode<NONE, IREG, NONE>;
def OP_MIPS_BLTZ  : Opcode<NONE, IREG, NONE>;
def OP_MIPS_BNE   : Opcode<NONE, IREG, IREG>;
def OP_MIPS_CVTSD : Opcode<FREG, FREG, NONE>;
def OP_MIPS_FBEQ  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBGE  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBGE_UN  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBGT  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBGT_UN  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBLE  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBLE_UN  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBLT  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBLT_UN  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBNE  : Opcode<NONE, FREG, FREG>;
def OP_MIPS_FBFALSE : Opcode<NONE, NONE, NONE>;
def OP_MIPS_FBTRUE : Opcode<NONE, NONE, NONE>;
def OP_MIPS_LWC1  : Opcode<NONE, NONE, NONE>;
def OP_MIPS_MTC1S : OpcodeGeneral<"mips_mtc1_s", FREG, IREG, NONE>;
def OP_MIPS_MTC1S_2 : OpcodeGeneral<"mips_mtc1_s2", FREG, IREG, IREG>;
def OP_MIPS_MFC1S : OpcodeGeneral<"mips_mfc1_s", IREG, FREG, NONE>;
def OP_MIPS_MTC1D : OpcodeGeneral<"mips_mtc1_d", FREG, IREG, NONE>;
def OP_MIPS_MFC1D : OpcodeGeneral<"mips_mfc1_d", IREG, FREG, NONE>;
def OP_MIPS_NOP   : Opcode<NONE, NONE, NONE>;
def OP_MIPS_SLTI  : Opcode<IREG, IREG, NONE>;
def OP_MIPS_SLT   : Opcode<IREG, IREG, IREG>;
def OP_MIPS_SLTIU : Opcode<IREG, IREG, NONE>;
def OP_MIPS_SLTU  : Opcode<IREG, IREG, IREG>;

def OP_MIPS_COND_EXC_EQ : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_GE : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_GT : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_LE : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_LT : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_NE_UN : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_GE_UN : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_GT_UN : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_LE_UN : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_LT_UN : Opcode<NONE, IREG, IREG>;

def OP_MIPS_COND_EXC_OV : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_NO : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_C : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_NC : Opcode<NONE, IREG, IREG>;

def OP_MIPS_COND_EXC_IEQ : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_IGE : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_IGT : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_ILE : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_ILT : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_INE_UN : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_IGE_UN : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_IGT_UN : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_ILE_UN : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_ILT_UN : Opcode<NONE, IREG, IREG>;

def OP_MIPS_COND_EXC_IOV : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_INO : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_IC : Opcode<NONE, IREG, IREG>;
def OP_MIPS_COND_EXC_INC : Opcode<NONE, IREG, IREG>;

}

let arch="ARM64" in {
/* Branch if sreg1 == 0 */
def OP_ARM64_CBZW : Opcode<NONE, IREG, NONE>;
def OP_ARM64_CBZX : Opcode<NONE, IREG, NONE>;
/* Branch if sreg1 != 0 */
def OP_ARM64_CBNZW : Opcode<NONE, IREG, NONE>;
def OP_ARM64_CBNZX : Opcode<NONE, IREG, NONE>;
}
