
#ifndef ARM_THUMB_CODEGEN_H
#define ARM_THUMB_CODEGEN_H

#define THUMB_EMIT(p, i) do { *(guint16*)p = i; p += 2; } while (0)

#define THUMB_MOV_REG_REG(p, rd, rm) THUMB_EMIT ((p), (0x11 << 10) | (0x2 << 8) | (((rd) >> 3) << 7) | ((rm) << 3) | (((rd) & 0x7) << 0))

static inline gpointer
thumb_emit_push (guint8 *p, int regs) {
	int v;

	if ((((regs) & ~(1 << 14)) >> 8) == 0) {
		THUMB_EMIT (p, (0xb << 12) | (0x0 << 11) | (0x2 << 9) | (((regs) >> 14) << 8) | (((regs) & 0xff) << 0));
		return p;
	}

	g_assert (regs);
	g_assert ((regs & (1 << 13)) == 0);
	g_assert ((regs & (1 << 15)) == 0);

	/* Check whenever there is more than one reg */
	v = (regs);
	while (!(v & 1))
		v >>= 1;
	v >>= 1;
	if (v) {
		/* T2 encoding */
		/* The encoding in the arm ref manual is wrong, it uses 0x2 << 6 */
		THUMB_EMIT (p, (0x1d << 11) | (0x0 << 9) | (0x4 << 6) | (0x1 << 5) | (0x0 << 4) | (0xd << 0));
		THUMB_EMIT (p, (0x0 << 15) | (((regs) >> 14) << 14) | (0x0 << 13) | (((regs) & 0x1fff) << 0));
	} else {
		g_assert_not_reached ();
	}

	return p;
}
	
#define THUMB_PUSH(p, regs) do { (p) = thumb_emit_push ((gpointer)(p), (regs)); } while (0)

#define is_thumb_sub_sp_imm(imm) (((imm) > 0) && (((imm) >> 12) == 0))

static inline gpointer
thumb_emit_sub_reg_imm (guint8 *p, int rd, int rn, int imm)
{
	if (rd == ARMREG_SP && rn == ARMREG_SP && (imm > 0) && ((imm & 0x3) == 0) && ((imm >> 9) == 0)) {
		THUMB_EMIT (p, (0xb << 12) | (0x0 << 8) | (0x1 << 7) | ((imm >> 2) << 0));
	} else {
		g_assert_not_reached ();
	}

	return p;
}

#define THUMB_SUB_SP_IMM(p, imm) do { (p) = thumb_emit_sub_reg_imm (p, ARMREG_SP, ARMREG_SP, (imm)); } while (0)

static inline gpointer
thumb_emit_str_imm (guint8 *p, int rt, int rn, int imm)
{
	guint32 i = (guint32)imm;

	// FIXME: Smaller encodings
	if ((i >> 12) == 0) {
		THUMB_EMIT (p, (0x1f << 11) | (0x0 << 9) | (0x0 << 8) | (0x1 << 7) | (0x2 << 5) | (0x0 << 4) | (rn << 0));
		THUMB_EMIT (p, (rt << 12) | (i << 0));
	} else {
		g_assert_not_reached ();
	}

	return p;
}

#define THUMB_STR_IMM(p, rt, rn, imm) do { (p) = thumb_emit_str_imm ((gpointer)(p), (rt), (rn), (imm)); } while (0)

static inline gpointer
thumb_emit_ldr_imm (guint8 *p, int rt, int rn, int imm)
{
	guint32 i = (guint32)imm;

	// FIXME: Smaller encodings
	if ((i >> 12) == 0) {
		THUMB_EMIT (p, (0x1f << 11) | (0x0 << 9) | (0x0 << 8) | (0x1 << 7) | (0x2 << 5) | (0x1 << 4) | (rn << 0));
		THUMB_EMIT (p, (rt << 12) | (i << 0));
	} else {
		g_assert_not_reached ();
	}

	return p;
}

#define THUMB_LDR_IMM(p, rt, rn, imm) do { (p) = thumb_emit_ldr_imm ((gpointer)(p), (rt), (rn), (imm)); } while (0)

/*
#define THUMB_STMDB(p, rn, regs, wb) do { \
	g_assert (((regs) & (1 << (rn))) == 0); \
	g_assert ((regs) & (1 << 
	THUMB_EMIT2 ((gpointer)(p), (0x1d << 11) | (0x0 << 9) | (0x4 << 6) | ((wb) << 5) | (0x0 << 4) | ((rn) << 0), (0x0 << 15) | (
*/

static inline gpointer
thumb_emit_bl (guint8 *p, int offset)
{
	int S, J1, J2;

	g_assert ((offset & 0x1) == 0);

	// FIXME:
	g_assert ((offset >> 22) == 0);

	// FIXME:
	S = 0;
	J1 = J2 = 1;
	THUMB_EMIT (p, (0x1e << 11) | (S << 10) | (((offset >> 12) & 0x3ff) << 0));
	THUMB_EMIT (p, (0x3 << 14) | (J1 << 13) | (0x1 << 12) | (J2 << 11) | (((offset >> 1) & 0x7ff) << 0));

	return p;
}

#define THUMB_BL(p, offset) do { (p) = thumb_emit_bl ((gpointer)(p), (offset)); } while (0)

static inline gpointer
thumb_emit_movw_reg_imm (guint8 *p, int rd, int imm)
{
	guint32 i = (guint32)imm;

	g_assert ((i >> 16) == 0);

	// FIXME: Implement the smaller encodings
	THUMB_EMIT (p, (0x1e << 11) | (((i >> 11) & 0x1) << 10) | (0x2 << 8) | (0x0 << 7) | (0x1 << 6) | (0x0 << 5) | (0x0 << 4) | ((i >> 12) << 0));
	THUMB_EMIT (p, (0x0 << 15) | (((i >> 8) & 0x7) << 12) | (rd << 8) | ((i & 0xff) << 0));

	return p;
}

#define THUMB_MOVW_REG_IMM(p, rd, imm) do { (p) = thumb_emit_movw_reg_imm ((gpointer)(p), (rd), (imm)); } while (0)

static inline gpointer
thumb_emit_movt_reg_imm (guint8 *p, int rd, int imm)
{
	guint32 i = (guint32)imm;

	g_assert ((i >> 16) == 0);

	THUMB_EMIT (p, (0x1e << 11) | (((i >> 11) & 0x1) << 10) | (0x2 << 8) | (0x1 << 7) | (0x1 << 6) | (0x0 << 5) | (0x0 << 4) | ((i >> 12) << 0));
	THUMB_EMIT (p, (0x0 << 15) | (((i >> 8) & 0x7) << 12) | (rd << 8) | ((i & 0xff) << 0));

	return p;
}

#define THUMB_MOVT_REG_IMM(p, rd, imm) do { (p) = thumb_emit_movt_reg_imm ((gpointer)(p), (rd), (imm)); } while (0)

static inline gpointer
arm_emit_mov_reg_reg (guint8 *p, int rd, int rm)
{
	if (use_thumb)
		THUMB_MOV_REG_REG (p, rd, rm);
	else
		ARM_MOV_REG_REG (p, rd, rm);
	return p;
}

#undef ARM_MOV_REG_REG
#define ARM_MOV_REG_REG(p, rd, rm) do { (p) = arm_emit_mov_reg_reg ((gpointer)(p), (rd), (rm)); } while (0)

static inline gpointer
arm_emit_push (guint8 *p, guint32 regs)
{
	if (use_thumb)
		THUMB_PUSH (p, regs);
	else
		ARM_PUSH (p, regs);
	return p;
}

#undef ARM_PUSH
#define ARM_PUSH(p,regs) do { (p) = arm_emit_push ((gpointer)(p), (regs)); } while (0)

static inline gpointer
arm_emit_sub_reg_imm (guint8 *p, int rd, int rn, int imm8, int rot)
{
	if (use_thumb) {
		g_assert (rd == ARMREG_SP);
		g_assert (rn == ARMREG_SP);
		g_assert (rot == 0);
		THUMB_SUB_SP_IMM (p, imm8);
	} else {
		ARM_SUB_REG_IMM (p, rd, rn, imm8, rot);
	}
	return p;
}

#undef ARM_SUB_REG_IMM
#define ARM_SUB_REG_IMM(p, rd, rn, imm8, rot) do { (p) = arm_emit_sub_reg_imm ((p), (rd), (rn), (imm8), (rot)); } while (0)

static inline gpointer
thumb_emit_add_reg_imm (guint8 *p, int rd, int rn, int imm8, int rot)
{
	guint32 i = (guint32)imm8;

	g_assert (imm8 >= 0);

	// FIXME: Use better encodings
	if (rn == ARMREG_PC || rn == ARMREG_SP)
		g_assert_not_reached ();
	g_assert (rot == 0);
	g_assert (i >> 12 == 0);

	THUMB_EMIT (p, (0x1e << 11) | ((i >> 11) << 10) | (0x1 << 9) | (rn));
	THUMB_EMIT (p, (((i >> 8) & 0x7) << 12) | (rd << 8) | ((i & 0xff)));
	return p;
}

static inline gpointer
arm_emit_add_reg_imm (guint8 *p, int rd, int rn, int imm8, int rot)
{
	if (use_thumb) {
		p = thumb_emit_add_reg_imm (p, rd, rn, imm8, rot);
	} else {
		ARM_ADD_REG_IMM (p, rd, rn, imm8, rot);
	}
	return p;
}

#undef ARM_ADD_REG_IMM
#define ARM_ADD_REG_IMM(p, rd, rn, imm8, rot) do { (p) = arm_emit_add_reg_imm ((gpointer)(p), (rd), (rn), (imm8), (rot)); } while (0)

static inline gpointer
thumb_emit_mov_reg_imm (guint8 *p, int reg, guint32 imm)
{
	g_assert (reg < ARMREG_R8);
	THUMB_EMIT ((p), (0x1 << 13) | ((reg) << 8) | ((imm) & 0xff));
	return p;
}

static inline gpointer
arm_emit_mov_reg_imm (guint8 *p, int reg, guint32 imm8, int rot)
{
	if (use_thumb)
		p = thumb_emit_mov_reg_imm (p, reg, imm8);
	else
		ARM_MOV_REG_IMM (p, reg, imm8, rot);
	return p;
}

#undef ARM_MOV_REG_IMM
#define ARM_MOV_REG_IMM(p, reg, imm8, rot) do { (p) = arm_emit_mov_reg_imm ((gpointer)(p), (reg), (imm8), (rot)); } while (0)

static inline gpointer
thumb_emit_pop (guint8 *p, guint32 regs)
{
	// FIXME: Add checks
	// T2 encoding
	THUMB_EMIT (p, (0b11101 << 11) | (0b10 << 6) | (0b1 << 5) | (0b1 << 4) | (ARMREG_SP));
	THUMB_EMIT (p, (regs));
	return p;
}

static inline gpointer
arm_emit_pop (guint8 *p, guint32 regs)
{
	if (use_thumb)
		p = thumb_emit_pop (p, regs);
	else
		ARM_POP (p, regs);
	return p;
}

#undef ARM_POP
#define ARM_POP(p, regs) do { (p) = arm_emit_pop ((gpointer)(p), (regs)); } while (0)

/*
#undef ARM_STR_IMM
#define ARM_STR_IMM THUMB_STR_IMM

#undef ARM_LDR_IMM
#define ARM_LDR_IMM THUMB_LDR_IMM

#undef ARM_BL
#define ARM_BL THUMB_BL

#undef ARM_MOVW_REG_IMM
#define ARM_MOVW_REG_IMM THUMB_MOVW_REG_IMM

#undef ARM_MOVT_REG_IMM
#define ARM_MOVT_REG_IMM THUMB_MOVT_REG_IMM
*/

#endif

