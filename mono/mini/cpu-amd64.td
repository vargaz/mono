//
// AMD64 cpu descriptor file
//
include "cpu-desc.td"

// FIXME:
// - define 'b' in ops.td
// - get rid of unused opcodes

// Additional reg/clob spec
def ClobSrc1 : ClobSpec<"1">;
def ClobRAX: ClobSpec<"a">;
def ClobRDX: ClobSpec<"d">;
def ClobM : ClobSpec<"m">;
def RegRAX: RegSpec<"a">;
def RegRDX: RegSpec<"d">;
def RegRCX: RegSpec<"s">;
def RegArg1: RegSpec<"A">;

// Calls
let clob = ClobCallee in {
	def call: Ins<32> { let dest = RegRAX; };
	def voidcall: Ins<32>;
	def voidcall_reg: Ins<32>;
	def voidcall_membase: Ins<32> { let src1 = RegBase; };
	def fcall: Ins<64>;
	def fcall_reg: Ins<64>;
	def fcall_membase: Ins<64> { let src1 = RegBase; };
	def rcall: Ins<64>;
	def rcall_reg: Ins<64>;
	def rcall_membase: Ins<64> { let src1 = RegBase; };
	def lcall: Ins<64> { let dest = RegRAX; };
	def lcall_reg: Ins<64> { let dest = RegRAX; };
	def lcall_membase: Ins<64> { let dest = RegRAX; let src1 = RegBase; };
	def vcall: Ins<64>;
	def vcall_reg: Ins<64>;
	def vcall_membase: Ins<64> { let src1 = RegBase; };
	def call_reg: Ins<32> { let dest = RegRAX; };
	def call_membase: Ins<32> { let dest = RegRAX; let src1 = RegBase; };
	def tailcall: Ins<255>;
	def tailcall_reg: Ins<255> { let src1 = RegBase; };
	def tailcall_membase: Ins<255> { let src1 = RegBase; };
    def vcall2: Ins<64>;
    def vcall2_reg: Ins<64>;
    def vcall2_membase: Ins<64> { let src1 = RegBase; };
    def dyn_call: Ins<192>;
}

// tailcall_parameter models the size of moving one parameter,
// so that the required size of a branch around a tailcall can
// be accurately estimated; something like:
// void f1(volatile long *a)
// {
// a[large] = a[another large]
// }
//
// If the offsets fit in 32bits, then len:14:
//	48 8b 87 e0 04 00 00 	movq	1248(%rdi), %rax
//	48 89 87 00 08 00 00 	movq	%rax, 2048(%rdi)
//
// else 64bits:
//	48 b8 e0 fc b3 c4 04 00 00 00 	movabsq	$20479999200, %rax
//	48 8b 04 07 	movq	(%rdi,%rax), %rax
//	48 b9 00 00 b4 c4 04 00 00 00 	movabsq	$20480000000, %rcx
//	48 89 04 0f 	movq	%rax, (%rdi,%rcx)
//
// Frame size is artificially limited to 1GB in mono_arch_tailcall_supported.
// This is presently redundant with tailcall len:255, as the limit of
// near branches is [-128, +127], after which the limit is
// [-2GB, +2GB-1]
// FIXME A fixed size sequence to move parameters would moot this.
def tailcall_parameter : Ins<14>;

def label: Ins<0>;
def br: Ins<6>;
def br_reg: Ins<3>;
def jump_table: Ins<18>;
def seq_point: Ins<46> { let clob = ClobCallee; };
def il_seq_point: Ins<0>;
def break: Ins<2>;

def move: Ins<3>;
def fmove: Ins<8>;
def rmove: Ins<8>;
def xmove: Ins<5>;
def move_f_to_i4: Ins<16>;
def move_i4_to_f: Ins<16>;
def move_f_to_i8: Ins<5>;
def move_i8_to_f: Ins<5>;

def oparglist: Ins<11> { let src1 = RegBase; };
def checkthis: Ins<5> { let src1 = RegBase; };
def aotconst: Ins<10>;
def gc_safe_point: Ins<40> { let clob = ClobCallee; };
def card_table_wbarrier: Ins<56> { let src1 = RegRAX; let clob = RegRDX; };
def relaxed_nop: Ins<2>;
def hard_nop: Ins<1>;
def nop: Ins<0>;
def generic_class_init: Ins<32> { let src1 = RegArg1; let clob = ClobCallee; };
def get_last_error: Ins<32>;
def fill_prof_call_ctx: Ins<128>;

// Pseudo opcodes
def dummy_use: Ins<0>;
def dummy_iconst: Ins<0>;
def dummy_i8const: Ins<0>;
def dummy_r8const: Ins<0>;
def dummy_r4const: Ins<0>;
def not_reached: Ins<0>;
def not_null: Ins<0>;
def liverange_start: Ins<0>;
def liverange_end: Ins<0>;
def gc_liveness_def: Ins<0>;
def gc_liveness_use: Ins<0>;
def gc_spill_slot_liveness_def: Ins<0>;
def gc_param_slot_liveness_def: Ins<0>;

// Binops
let clob = ClobSrc1 in {
	def long_add: Ins<3>;
	def long_sub: Ins<3>;
	def long_mul: Ins<4>;
	def long_and: Ins<3>;
	def long_or: Ins<3>;
	def long_xor: Ins<3>;
	def long_shl: Ins<3> { let src2 = RegRCX; };
	def long_shr: Ins<3> { let src2 = RegRCX; };
	def long_shr_un: Ins<3> { let src2 = RegRCX; };
	def long_min: Ins<16>;
	def long_min_un: Ins<16>;
	def long_max: Ins<16>;
	def long_max_un: Ins<16>;
    def int_add: Ins<4>;
    def int_sub: Ins<4>;
    def int_mul: Ins<4>;
    def int_and: Ins<4>;
    def int_or: Ins<4>;
    def int_xor: Ins<4>;
	def int_shl: Ins<4> { let src2 = RegRCX; };
	def int_shr: Ins<4> { let src2 = RegRCX; };
	def int_shr_un: Ins<4> { let src2 = RegRCX; };
    def int_adc: Ins<4>;
    def int_sbb: Ins<4>;
    def int_addcc: Ins<4>;
    def int_subcc: Ins<4>;
    def int_min: Ins<16>;
    def int_max: Ins<16>;
    def int_min_un: Ins<16>;
    def int_max_un: Ins<16>;
}
let clob = ClobSrc1, len = 8 in {
    def int_add_imm: Ins;
    def int_sub_imm: Ins;
    def int_and_imm: Ins;
    def int_or_imm: Ins;
    def int_xor_imm: Ins;
    def int_shl_imm: Ins;
    def int_shr_imm: Ins;
    def int_shr_un_imm: Ins;
    def int_adc_imm: Ins;
    def int_sbb_imm: Ins;
}
let clob = ClobSrc1 in {
    def long_add_imm: Ins<12>;
    def long_sub_imm: Ins<12>;
    def long_and_imm: Ins<12>;
    def long_or_imm: Ins<12>;
    def long_xor_imm: Ins<12>;
}
def lcompare_imm: Ins<13>;
def int_mul_imm: Ins<32> { let clob = ClobSrc1; };

// Unops
let clob = ClobSrc1 in {
	def long_neg: Ins<3>;
	def long_not: Ins<3>;
    def int_neg: Ins<4>;
    def int_not: Ins<4>;
	def long_mul_imm: Ins<16>;
}

// Mul/div ops
let clob = ClobRDX, dest = RegRAX, src1 = RegRAX in {
	def long_div: Ins<16>;
	def long_div_un: Ins<16>;
    def int_div: Ins<32>;
    def int_div_un: Ins<32>;
}
let clob = ClobRDX, dest = RegRAX in {
    def int_div_imm: Ins<32>;
    def int_div_un_imm: Ins<32>;
}
let clob = ClobRAX, dest = RegRDX, src1 = RegRAX in {
	def long_rem: Ins<16>;
	def long_rem_un: Ins<16>;
    def int_rem: Ins<32>;
    def int_rem_un: Ins<32>;
}
let clob = ClobRAX, dest = RegRDX in {
    def int_rem_un_imm: Ins<32>;
}

// Conversions
def long_conv_to_i1: Ins<4>;
def long_conv_to_i2: Ins<4>;
def long_conv_to_i4: Ins<3>;
def long_conv_to_i8: Ins<3>;
def long_conv_to_r4: Ins<15>;
def long_conv_to_r8: Ins<9>;
def long_conv_to_u1: Ins<4>;
def long_conv_to_u2: Ins<4>;
def long_conv_to_u4: Ins<3>;
def long_conv_to_u8: Ins<3>;
def long_conv_to_r_un: Ins<64>;
def long_conv_to_ovf_i4_un: Ins<16>;
def long_conv_to_ovf_u4: Ins<15>;
def int_conv_to_r4: Ins<15>;
def int_conv_to_r8: Ins<9>;
def int_conv_to_i1: Ins<4>;
def int_conv_to_i2: Ins<4>;
def int_conv_to_i4: Ins<3>;
def int_conv_to_i8: Ins<3>;
def int_conv_to_u4: Ins<3>;
def int_conv_to_u8: Ins<3>;
def int_conv_to_u: Ins<4>;
def int_conv_to_u2: Ins<4>;
def int_conv_to_u1: Ins<4>;
def int_conv_to_i: Ins<4>;
def float_conv_to_r4: Ins<17>;

// EH
def throw: Ins<24>;
def rethrow: Ins<24>;
def start_handler: Ins<16>;
def call_handler: Ins<14> { let clob = ClobCallee; };
def endfinally: Ins<9>;
def endfilter: Ins<9> { let src1 = RegRAX; };
def get_ex_obj: Ins<16> { let dest = RegRAX; };

def ckfinite: Ins<43>;
def localloc: Ins<96>;
def localloc_imm: Ins<96>;

let len = 8 in {
    def ceq: Ins;
    def cgt: Ins;
    def cgt_un: Ins;
    def clt: Ins;
    def clt_un: Ins;
    def int_ceq: Ins;
    def int_cgt: Ins;
    def int_cgt_un: Ins;
    def int_clt: Ins;
    def int_clt_un: Ins;
    def int_cneq: Ins;
    def int_cge: Ins;
    def int_cle: Ins;
    def int_cge_un: Ins;
    def int_cle_un: Ins;
}
let len = 64 in {
    def long_ceq: Ins;
    def long_cgt: Ins;
    def long_cgt_un: Ins;
    def long_clt: Ins;
    def long_clt_un: Ins;
}

def compare: Ins<3>;
def lcompare: Ins<3>;
def icompare: Ins<3>;
def compare_imm: Ins<13>;
def icompare_imm: Ins<8>;
def fcompare: Ins<13> { let clob = ClobRAX; };
def rcompare: Ins<13> { let clob = ClobRAX; };

def iconst: Ins<10>;
def i8const: Ins<10>;
def r4const: Ins<14>;
def r8const: Ins<9>;

// Store membase
let dest = RegBase in {
	def store_membase_imm: Ins<15>;
	def store_membase_reg: Ins<9>;
	def storei8_membase_reg: Ins<9>;
	def storei1_membase_imm: Ins<11>;
	def storei1_membase_reg: Ins<9>;
	def storei2_membase_imm: Ins<13>;
	def storei2_membase_reg: Ins<9>;
	def storei4_membase_imm: Ins<13>;
	def storei4_membase_reg: Ins<9>;
	def storei8_membase_imm: Ins<18>;
	def storer4_membase_reg: Ins<15>;
	def storer8_membase_reg: Ins<10>;
    def storex_membase: Ins<9>;
    def storex_membase_reg: Ins<9>;
    def storex_aligned_membase_reg: Ins<7>;
    def storex_nta_membase_reg: Ins<7>;
}

// Load membase
let src1 = RegBase in {
	def load_membase: Ins<8>;
	def loadi1_membase: Ins<9>;
	def loadu1_membase: Ins<9>;
	def loadi2_membase: Ins<9>;
	def loadu2_membase: Ins<9>;
	def loadi4_membase: Ins<9>;
	def loadu4_membase: Ins<9>;
	def loadi8_membase: Ins<18>;
	def loadr4_membase: Ins<16>;
	def loadr8_membase: Ins<16>;
    def loadx_membase: Ins<9>;
    def loadx_aligned_membase: Ins<7>;
    def prefetch_membase: Ins<4>;
}
def load_mem: Ins<16>;
def loadi8_mem: Ins<16>;
def loadi4_mem: Ins<16>;
def loadu1_mem: Ins<16>;
def loadu2_mem: Ins<16>;
def loadu4_mem: Ins<10>;

// Alu imm
let clob = ClobSrc1, len = 8 in {
	def add_imm: Ins;
	def sub_imm: Ins;
	def and_imm: Ins;
	def or_imm: Ins;
	def xor_imm: Ins;
	def shl_imm: Ins;
	def shr_imm: Ins;
	def shr_un_imm: Ins;
}
let clob = ClobSrc1, len = 11 in {
    def long_shr_imm: Ins;
    def long_shr_un_imm: Ins;
    def long_shl_imm: Ins;
}
def mul_imm: Ins<12>;

let len = 8 in {
	def cond_exc_eq: Ins;
	def cond_exc_ne_un: Ins;
	def cond_exc_lt: Ins;
	def cond_exc_lt_un: Ins;
	def cond_exc_gt: Ins;
	def cond_exc_gt_un: Ins;
	def cond_exc_ge: Ins;
	def cond_exc_ge_un: Ins;
	def cond_exc_le: Ins;
	def cond_exc_le_un: Ins;
	def cond_exc_ov: Ins;
	def cond_exc_no: Ins;
	def cond_exc_c: Ins;
	def cond_exc_nc: Ins;
	def cond_exc_iov: Ins;
	def cond_exc_ic: Ins;
    def cond_exc_ieq: Ins;
    def cond_exc_ine_un: Ins;
    def cond_exc_ilt: Ins;
    def cond_exc_ilt_un: Ins;
    def cond_exc_igt: Ins;
    def cond_exc_igt_un: Ins;
    def cond_exc_ige: Ins;
    def cond_exc_ige_un: Ins;
    def cond_exc_ile: Ins;
    def cond_exc_ile_un: Ins;
    def cond_exc_ino: Ins;
    def cond_exc_inc: Ins;
}

def long_mul_ovf: Ins<16> { let clob = ClobSrc1; };
def long_mul_ovf_un: Ins<22>;
def int_mul_ovf: Ins<32> { let clob = ClobSrc1; };
def int_mul_ovf_un: Ins<32> { let clob = ClobSrc1; };

// Bcc
let len = 8 in {
    def long_beq: Ins;
    def long_bge: Ins;
    def long_bgt: Ins;
    def long_ble: Ins;
    def long_blt: Ins;
    def long_bne_un: Ins;
    def long_bge_un: Ins;
    def long_bgt_un: Ins;
    def long_ble_un: Ins;
    def long_blt_un: Ins;
    def int_beq: Ins;
    def int_bne_un: Ins;
    def int_blt: Ins;
    def int_blt_un: Ins;
    def int_bgt: Ins;
    def int_bgt_un: Ins;
    def int_bge: Ins;
    def int_bge_un: Ins;
    def int_ble: Ins;
    def int_ble_un: Ins;
}

// FBcc
def float_beq: Ins<13>;
def float_bne_un: Ins<18>;
def float_blt: Ins<13>;
def float_blt_un: Ins<30>;
def float_bgt: Ins<13>;
def float_bgt_un: Ins<30>;
def float_bge: Ins<32>;
def float_bge_un: Ins<13>;
def float_ble: Ins<32>;
def float_ble_un: Ins<13>;

// Float alu
let clob = ClobSrc1 in {
    def float_add: Ins<5>;
    def float_sub: Ins<5>;
    def float_mul: Ins<5>;
    def float_div: Ins<5>;
    def float_div_un: Ins<5>;
    def float_rem: Ins<19>;
    def float_rem_un: Ins<19>;
    def float_neg: Ins<23>;
    def float_not: Ins<3>;
}

// Fconv
let len = 49 in {
    def float_conv_to_i1: Ins;
    def float_conv_to_i2: Ins;
    def float_conv_to_i4: Ins;
    def float_conv_to_i8: Ins;
    def float_conv_to_u4: Ins;
    def float_conv_to_u8: Ins;
    def float_conv_to_u2: Ins;
    def float_conv_to_u1: Ins;
    def float_conv_to_i: Ins;
}
let len = 40, dest = RegRAX in {
    def float_conv_to_ovf_i: Ins;
    def float_conv_to_ovd_u: Ins;
}
def float_conv_to_u: Ins<46>;

// FCcc
def float_ceq: Ins<35>;
def float_cgt: Ins<35>;
def float_cgt_un: Ins<48>;
def float_clt: Ins<35>;
def float_clt_un: Ins<42>;
def float_cneq: Ins<42>;
def float_cge: Ins<35>;
def float_cle: Ins<35>;
let src2 = RegBase in {
    def float_ceq_membase: Ins<35>;
    def float_cgt_membase: Ins<35>;
    def float_cgt_un_membase: Ins<48>;
    def float_clt_membase: Ins<35>;
    def float_clt_un_membase: Ins<42>;
}

// R4
let len = 32 in {
    def r4_conv_to_i1: Ins;
    def r4_conv_to_u1: Ins;
    def r4_conv_to_i2: Ins;
    def r4_conv_to_u2: Ins;
    def r4_conv_to_i4: Ins;
    def r4_conv_to_u4: Ins;
    def r4_conv_to_i8: Ins;
    def r4_conv_to_i: Ins;
}
def r4_conv_to_r8: Ins<17>;
def r4_conv_to_r4: Ins<17>;
let clob = ClobSrc1 in {
    def r4_add: Ins<5>;
    def r4_sub: Ins<5>;
    def r4_mul: Ins<5>;
    def r4_div: Ins<5>;
    def r4_neg: Ins<23>;
}
def r4_ceq: Ins<35>;
def r4_cgt: Ins<35>;
def r4_cgt_un: Ins<48>;
def r4_clt: Ins<35>;
def r4_clt_un: Ins<42>;
def r4_cneq: Ins<42>;
def r4_cge: Ins<35>;
def r4_cle: Ins<35>;

def tls_get: Ins<32>;
def tls_set: Ins<16>;

let clob = ClobSrc1 in {
    def adc: Ins<3>;
    def sbb: Ins<3>;
    def addcc: Ins<3>;
    def subcc: Ins<3>;
    def laddcc: Ins<3>;
    def lsubcc: Ins<3>;
    def adc_imm: Ins<8>;
    def sbb_imm: Ins<8>;
}

// Arch specific
let src1 = RegBase in {
    def x86_compare_membase_reg: Ins<9>;
    def x86_compare_membase_imm: Ins<13>;
    def x86_compare_membase8_imm: Ins<9>;
    def x86_inc_membase: Ins<8>;
    def x86_dec_membase: Ins<8>;
    def x86_add_membase_imm: Ins<13>;
    def x86_sub_membase_imm: Ins<13>;
    def x86_push_membase: Ins<8>;
    def x86_seteq_membase: Ins<9>;
    def x86_push_obj: Ins<40>;
}
def x86_test_null: Ins<5>;
def x86_compare_reg_membase: Ins<8> { let src2 = RegBase; };
def x86_inc_reg: Ins<3> { let clob = ClobSrc1; };
def x86_dec_reg: Ins<3> { let clob = ClobSrc1; };
def x86_push: Ins<3>;
def x86_push_imm: Ins<6>;
def x86_lea: Ins<8>;
def x86_lea_membase: Ins<11>;
def x86_fpop: Ins<3>;

let src2 = RegBase, clob = ClobSrc1, len = 13 in {
    def x86_add_reg_membase: Ins;
    def x86_sub_reg_membase: Ins;
    def x86_mul_reg_membase: Ins;
    def x86_and_reg_membase: Ins;
    def x86_or_reg_membase: Ins;
    def x86_xor_reg_membase: Ins;
}

def amd64_test_null: Ins<5>;
def amd64_icompare_membase_reg: Ins<8> { let src1 = RegBase; };
def amd64_icompare_membase_imm: Ins<13> { let src1 = RegBase; };
def amd64_icompare_reg_membase: Ins<8> { let src2 = RegBase; };
def amd64_set_xmmreg_r4: Ins<14> { let clob = ClobM; };
def amd64_set_xmmreg_r8: Ins<14> { let clob = ClobM; };
def amd64_save_sp_to_lmf: Ins<16>;
def amd64_loadi8_memindex: Ins<10>;

let src1 = RegBase in {
    def amd64_compare_membase_reg: Ins<9>;
    def amd64_compare_membase_imm: Ins<14>;
    def amd64_add_membase_imm: Ins<16>;
    def amd64_sub_membase_imm: Ins<16>;
    def amd64_and_membase_imm: Ins<13>;
    def amd64_or_membase_imm: Ins<13>;
    def amd64_xor_membase_imm: Ins<13>;
    def x86_and_membase_imm: Ins<12>;
    def x86_or_membase_imm: Ins<12>;
    def x86_xor_membase_imm: Ins<12>;
    def x86_add_membase_reg: Ins<12>;
    def x86_sub_membase_reg: Ins<12>;
    def x86_and_membase_reg: Ins<12>;
    def x86_or_membase_reg: Ins<12>;
    def x86_xor_membase_reg: Ins<12>;
    def x86_mul_membase_reg: Ins<14>;
    def amd64_add_membase_reg: Ins<13>;
    def amd64_sub_membase_reg: Ins<13>;
    def amd64_and_membase_reg: Ins<13>;
    def amd64_or_membase_reg: Ins<13>;
    def amd64_xor_membase_reg: Ins<13>;
    def amd64_mul_membase_reg: Ins<15>;
}
let src2 = RegBase in {
    def amd64_compare_reg_membase: Ins<9>;
}
let src2 = RegBase, clob = ClobSrc1 in {
    def amd64_add_reg_membase: Ins<14>;
    def amd64_sub_reg_membase: Ins<14>;
    def amd64_and_reg_membase: Ins<14>;
    def amd64_or_reg_membase: Ins<14>;
    def amd64_xor_reg_membase: Ins<14>;
}

// Atomics
let src1 = RegBase in {
    def atomic_add_i4: Ins<32>;
    def atomic_add_i8: Ins<32>;
    def atomic_exchange_i4: Ins<12>;
    def atomic_exchange_i8: Ins<12>;
    def atomic_cas_i4: Ins<24> { let dest = RegRAX; let src3 = RegRAX; };
    def atomic_cas_i8: Ins<24> { let dest = RegRAX; let src3 = RegRAX; };
}
def memory_barrier: Ins<3>;
let src1 = RegBase, len = 9 in {
    def atomic_load_i1: Ins;
    def atomic_load_u1: Ins;
    def atomic_load_i2: Ins;
    def atomic_load_u2: Ins;
    def atomic_load_i4: Ins;
    def atomic_load_u4: Ins;
    def atomic_load_i8: Ins;
    def atomic_load_u8: Ins;
}
let src1 = RegBase in {
    def atomic_load_r4: Ins<16>;
    def atomic_load_r8: Ins<16>;
}
let dest = RegBase, len = 12 in {
    def atomic_store_i1: Ins;
    def atomic_store_u1: Ins;
    def atomic_store_i2: Ins;
    def atomic_store_u2: Ins;
    def atomic_store_i4: Ins;
    def atomic_store_u4: Ins;
    def atomic_store_i8: Ins;
    def atomic_store_u8: Ins;
}
let dest = RegBase in {
    def atomic_store_r4: Ins<18>;
    def atomic_store_r8: Ins<13>;
}

def sin: Ins<32>;
def cos: Ins<32>;
def abs: Ins<32> { let clob = ClobSrc1; };
def tan: Ins<59>;
def atan: Ins<9>;
def sqrt: Ins<32>;

def zext_i4: Ins<4>;
def sext_i1: Ins<4>;
def sext_i2: Ins<4>;
def sext_i4: Ins<8>;

let clob = ClobSrc1, len = 16 in {
    def cmov_ieq: Ins;
    def cmov_ige: Ins;
    def cmov_igt: Ins;
    def cmov_ile: Ins;
    def cmov_ilt: Ins;
    def cmov_ine_un: Ins;
    def cmov_ige_un: Ins;
    def cmov_igt_un: Ins;
    def cmov_ile_un: Ins;
    def cmov_ilt_un: Ins;
    def cmov_leq: Ins;
    def cmov_lge: Ins;
    def cmov_lgt: Ins;
    def cmov_lle: Ins;
    def cmov_llt: Ins;
    def cmov_lne_un: Ins;
    def cmov_lge_un: Ins;
    def cmov_lgt_un: Ins;
    def cmov_lle_un: Ins;
    def cmov_llt_un: Ins;
}

// SIMD
let clob = ClobSrc1 in {
    def addps: Ins<4>;
    def divps: Ins<4>;
    def mulps: Ins<4>;
    def subps: Ins<4>;
    def maxps: Ins<4>;
    def minps: Ins<4>;
    def compps: Ins<5>;
    def andps: Ins<4>;
    def andnps: Ins<4>;
    def orps: Ins<4>;
    def xorps: Ins<4>;
    def haddps: Ins<5>;
    def hsubps: Ins<5>;
    def addsubps: Ins<5>;
}

def dupps_low: Ins<5>;
def dupps_high: Ins<5>;
def duppd: Ins<6>;

let clob = ClobSrc1 in {
    def addpd: Ins<5>;
    def divpd: Ins<5>;
    def mulpd: Ins<5>;
    def subpd: Ins<5>;
    def maxpd: Ins<5>;
    def minpd: Ins<5>;
    def comppd: Ins<6>;
    def andpd: Ins<5>;
    def andnpd: Ins<5>;
    def orpd: Ins<5>;
    def xorpd: Ins<5>;
    def sqrtpd: Ins<5>;
    def haddpd: Ins<6>;
    def hsubpd: Ins<6>;
    def addsubpd: Ins<6>;
    def pand: Ins<5>;
    def por: Ins<5>;
    def pxor: Ins<5>;
    def shufps: Ins<5>;
    def shufpd: Ins<6>;
    def paddb: Ins<5>;
    def paddw: Ins<5>;
    def paddd: Ins<5>;
    def paddq: Ins<5>;
    def psubb: Ins<5>;
    def psubw: Ins<5>;
    def psubd: Ins<5>;
    def psubq: Ins<5>;
    def pmaxb_un: Ins<5>;
    def pmaxw_un: Ins<6>;
    def pmaxd_un: Ins<6>;
    def pmaxb: Ins<6>;
    def pmaxw: Ins<5>;
    def pmaxd: Ins<6>;
    def pavgb_un: Ins<5>;
    def pavgw_un: Ins<5>;
    def pminb_un: Ins<5>;
    def pminw_un: Ins<6>;
    def pmind_un: Ins<6>;
    def pminb: Ins<6>;
    def pminw: Ins<5>;
    def pmind: Ins<6>;
    def pcmpeqb: Ins<5>;
    def pcmpeqw: Ins<5>;
    def pcmpeqd: Ins<5>;
    def pcmpeqq: Ins<6>;
    def pcmpgtb: Ins<5>;
    def pcmpgtw: Ins<5>;
    def pcmpgtd: Ins<5>;
    def pcmpgtq: Ins<6>;
    def psumabsdiff: Ins<5>;
    def unpack_lowb: Ins<5>;
    def unpack_loww: Ins<5>;
    def unpack_lowd: Ins<5>;
    def unpack_lowq: Ins<5>;
    def unpack_lowps: Ins<5>;
    def unpack_lowpd: Ins<5>;
    def unpack_highb: Ins<5>;
    def unpack_highw: Ins<5>;
    def unpack_highd: Ins<5>;
    def unpack_highq: Ins<5>;
    def unpack_highps: Ins<5>;
    def unpack_highpd: Ins<5>;
    def packw: Ins<5>;
    def packd: Ins<5>;
    def packw_un: Ins<5>;
    def packd_un: Ins<6>;
    def paddb_sat: Ins<5>;
    def paddb_sat_un: Ins<5>;
    def paddw_sat: Ins<5>;
    def paddw_sat_un: Ins<5>;
    def psubb_sat: Ins<5>;
    def psubb_sat_un: Ins<5>;
    def psubw_sat: Ins<5>;
    def psubw_sat_un: Ins<5>;
    def pmulw: Ins<5>;
    def pmuld: Ins<6>;
    def pmulq: Ins<5>;
    def pmul_high_un: Ins<5>;
    def pmul_high: Ins<5>;
    def pshrw: Ins<6>;
    def pshrw_reg: Ins<5>;
    def psarw: Ins<6>;
    def psarw_reg: Ins<5>;
    def pshlw: Ins<6>;
    def pshlw_reg: Ins<5>;
    def pshrd: Ins<6>;
    def pshrd_reg: Ins<5>;
    def psard: Ins<6>;
    def psard_reg: Ins<5>;
    def pshld: Ins<6>;
    def pshld_reg: Ins<5>;
    def pshrq: Ins<6>;
    def pshrq_reg: Ins<5>;
    def pshlq: Ins<6>;
    def pshlq_reg: Ins<5>;
    def cvtdq2pd: Ins<5>;
    def cvtdq2ps: Ins<4>;
    def cvtpd2dq: Ins<5>;
    def cvtpd2ps: Ins<5>;
    def cvtps2dq: Ins<5>;
    def cvtps2pd: Ins<4>;
    def cvttpd2dq: Ins<5>;
    def cvttps2dq: Ins<5>;
}

def sqrtps: Ins<5>;
def rsqrtps: Ins<5>;
def rcpps: Ins<5>;
def pshufflew_high: Ins<6>;
def pshufflew_low: Ins<6>;
def pshuffled: Ins<6>;
def extract_mask: Ins<6>;

def xzero: Ins<5>;
def xones: Ins<5>;
def iconv_to_x: Ins<5>;
def extract_i4: Ins<5>;
def extract_i8: Ins<9>;
def extract_i2: Ins<13>;
def extract_u2: Ins<13>;
def extract_i1: Ins<13>;
def extract_u1: Ins<13>;
def extract_r8: Ins<5>;
def iconv_to_r4_raw: Ins<10>;
def insert_i2: Ins<6> { let clob = ClobSrc1; };
def extractx_u2: Ins<6>;
def insertx_u1_slow: Ins<18>;
def insertx_i4_slow: Ins<16>;
def insertx_i8_slow: Ins<13>;
def insertx_r4_slow: Ins<24>;
def insertx_r8_slow: Ins<24>;
def fconv_to_r8_x: Ins<4>;
def xconv_r8_to_i4: Ins<7>;
def expand_i2: Ins<18>;
def expand_i4: Ins<11>;
def expand_i8: Ins<11>;
def expand_r4: Ins<16>;
def expand_r8: Ins<13>;
def roundpd: Ins<10>;

