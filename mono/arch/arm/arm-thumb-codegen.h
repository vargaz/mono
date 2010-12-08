
#ifndef ARM_THUMB_CODEGEN_H
#define ARM_THUMB_CODEGEN_H

#define THUMB_EMIT(p, i) do { *(guint16*)p = i; p += 2; } while (0)

static inline void
encode_thumb_imm (guint32 imm, guint32 *i, guint32 *imm3, guint32 *imm8)
{
	g_assert (imm >> 8 == 0);
	*i = 0;
	*imm3 = 0;
	*imm8 = imm;
}

/* MOV reg, reg */

static inline gpointer
thumb_mov_reg_reg (guint8 *p, int rd, int rm)
{
	THUMB_EMIT ((p), (0x11 << 10) | (0x2 << 8) | (((rd) >> 3) << 7) | ((rm) << 3) | (((rd) & 0x7) << 0));
	return p;
}

static inline gpointer
arm_emit_mov_reg_reg (guint8 *p, int rd, int rm)
{
	if (use_thumb)
		p = thumb_mov_reg_reg (p, rd, rm);
	else
		ARM_MOV_REG_REG (p, rd, rm);
	return p;
}

#undef ARM_MOV_REG_REG
#define ARM_MOV_REG_REG(p, rd, rm) do { (p) = arm_emit_mov_reg_reg ((gpointer)(p), (rd), (rm)); } while (0)

/* MOV reg, imm */

static inline gpointer
thumb_emit_mov_reg_imm (guint8 *p, int reg, guint32 imm)
{
	g_assert (reg < ARMREG_R8);

	if ((imm >> 8) == 0) {
		/* T1 encoding */
		THUMB_EMIT ((p), (0x1 << 13) | ((reg) << 8) | ((imm) & 0xff));
	} else {
		int imm4 = (imm >> 12);
		int i = (imm >> 11) & 1;
		int imm3 = (imm >> 8) & 0x7;
		int imm8 = (imm >>0) & 0xff;

		/* T3 encoding */
		g_assert ((imm >> 16) == 0);
		THUMB_EMIT ((p), (0b11110 << 11) | (i << 10) | (0b10 << 8) | (0 << 7) | (1 << 6) | (0 << 5) | (0 << 4) | (imm4 << 0));
		THUMB_EMIT ((p), (0 << 15) | (imm3 << 12) | (reg << 8) | (imm8 << 0));
	}
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

/* PUSH */

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
	
static inline gpointer
arm_emit_push (guint8 *p, guint32 regs)
{
	if (use_thumb)
		p = thumb_emit_push (p, regs);
	else
		ARM_PUSH (p, regs);
	return p;
}

#undef ARM_PUSH
#define ARM_PUSH(p,regs) do { (p) = arm_emit_push ((gpointer)(p), (regs)); } while (0)

/* POP */

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

/* SUB reg, imm */

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

static inline gpointer
arm_emit_sub_reg_imm (guint8 *p, int rd, int rn, int imm8, int rot)
{
	if (use_thumb) {
		g_assert (rot == 0);
		p = thumb_emit_sub_reg_imm (p, rd, rn, imm8);
	} else {
		ARM_SUB_REG_IMM (p, rd, rn, imm8, rot);
	}
	return p;
}

#undef ARM_SUB_REG_IMM
#define ARM_SUB_REG_IMM(p, rd, rn, imm8, rot) do { (p) = arm_emit_sub_reg_imm ((p), (rd), (rn), (imm8), (rot)); } while (0)

/* ADD reg, imm */

static inline gpointer
thumb_emit_add_reg_imm (guint8 *p, int rd, int rn, int imm8, int rot)
{
	guint32 i = (guint32)imm8;

	g_assert (imm8 >= 0);

	// FIXME: Use better encodings
	if (rn == ARMREG_PC)
	g_assert (rot == 0);
	g_assert (i >> 12 == 0);

	if (rn == ARMREG_SP) {
		/* T2 encoding */
		g_assert (rd == ARMREG_SP);
		g_assert ((i & 0x3) == 0);
		g_assert ((i >> 9) == 0);
		THUMB_EMIT (p, ((0b1011) << 12) | (0 << 8) | (0 << 7) | ((i >> 2) << 0));
	} else {
		THUMB_EMIT (p, (0x1e << 11) | ((i >> 11) << 10) | (0x1 << 9) | (rn));
		THUMB_EMIT (p, (((i >> 8) & 0x7) << 12) | (rd << 8) | ((i & 0xff)));
	}
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

/* STR reg, [reg+imm] */

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

static inline gpointer
arm_emit_str_imm (guint8 *p, int rt, int rn, int imm)
{
	if (use_thumb)
		p = thumb_emit_str_imm (p, rt, rn, imm);
	else
		ARM_STR_IMM (p, rt, rn, imm);
	return p;
}

#undef ARM_STR_IMM
#define ARM_STR_IMM(p, rt, rn, imm) do { (p) = arm_emit_str_imm ((gpointer)(p), (rt), (rn), (imm)); } while (0)

/* LDR reg, [reg + imm] */

static inline gpointer
thumb_emit_ldr_imm (guint8 *p, int rt, int rn, int imm)
{
	guint32 i = (guint32)imm;

	if ((i >> 12) == 0) {
		THUMB_EMIT (p, (0x1f << 11) | (0x0 << 9) | (0x0 << 8) | (0x1 << 7) | (0x2 << 5) | (0x1 << 4) | (rn << 0));
		THUMB_EMIT (p, (rt << 12) | (i << 0));
	} else {
		g_assert_not_reached ();
	}

	return p;
}

static inline gpointer
arm_emit_ldr_imm (guint8 *p, int rt, int rn, int imm)
{
	if (use_thumb)
		p = thumb_emit_ldr_imm (p, rt, rn, imm);
	else
		ARM_LDR_IMM (p, rt, rn, imm);
	return p;
}

#undef ARM_LDR_IMM
#define ARM_LDR_IMM(p, rt, rn, imm) do { (p) = arm_emit_ldr_imm ((gpointer)(p), (rt), (rn), (imm)); } while (0)

/* CMP reg, imm */

static inline gpointer
thumb_emit_cmp_reg_imm (guint8 *p, int rn, int imm, int rot)
{
	guint32 i, imm3, imm8;

	encode_thumb_imm ((guint32)imm, &i, &imm3, &imm8);

	/* T2 encoding */
	THUMB_EMIT ((p), (0b11110 << 11) | (i << 10) | (0 << 9) | (0b1101 << 5) | (1 << 4) | (rn << 0));
	THUMB_EMIT ((p), (0 << 15) | (imm3 << 12) | (0b1111 << 8) | (imm8 << 0));
	return p;
}

static inline gpointer
arm_emit_cmp_reg_imm (guint8 *p, int rn, int imm8, int rot)
{
	if (use_thumb)
		p = thumb_emit_cmp_reg_imm (p, rn, imm8, rot);
	else
		ARM_CMP_REG_IMM (p, rn, imm8, rot);
	return p;
}

#undef ARM_CMP_REG_IMM
#define ARM_CMP_REG_IMM(p,rn,imm8,rot) do { (p) = arm_emit_cmp_reg_imm ((gpointer)(p), (rn), (imm8), (rot)); } while (0)

/* B */

static inline gpointer
thumb_emit_b_cond (guint8 *p, int cond, int offset)
{
	int i = (guint32)offset;
	int j1 = (offset >> 18) & 1;
	int j2 = (offset >> 19) & 1;
	int s = (offset >> 20) & 1;
	int imm6 = (offset >> 12) & 0x3f;
	int imm11 = (offset >> 0) & 0x7ff;

	if ((cond & 0b1110) == 0b1110) {
		g_assert ((offset & 1) == 0);
		g_assert ((offset >> 12) == 0 || (offset >> 12) == -1);

		/* T2 encoding */
		THUMB_EMIT ((p), (0b11100 << 11) | (((i & 0xfff) >> 1) << 0));
	} else {
		g_assert ((offset & 1) == 0);
		g_assert ((offset >> 21) == 0 || (offset >> 21) == -1);

		/* T3 encoding */
		THUMB_EMIT ((p), (0b11110 << 11) | (s << 10) | (cond << 6) | (imm6 << 0));
		THUMB_EMIT ((p), (0b10 << 14) | (j1 << 13) | (0 << 12) | (j2 << 11) | (imm11 << 0));
	}
	return p;
}

static inline gpointer
arm_emit_b_cond (guint8 *p, int cond, int offset)
{
	if (use_thumb)
		p = thumb_emit_b_cond (p, cond, offset);
	else
		ARM_B_COND (p, cond, offset);
	return p;
}

#undef ARM_B_COND
#define ARM_B_COND(p,cond,offset) do { (p) = arm_emit_b_cond ((gpointer)(p), (cond), (offset)); } while (0)
#define ARM_B(p, offs) ARM_B_COND((p), ARMCOND_AL, (offs))

/* BL */

static inline gpointer
thumb_emit_bl (guint8 *p, int offset)
{
	int S, J1, J2;
	guint32 uoffset = (guint32)offset;

	g_assert ((uoffset & 0x1) == 0);

	// FIXME:
	//g_assert ((offset >> 22) == 0);

	// FIXME:
	S = 1;
	J1 = J2 = 1;
	THUMB_EMIT (p, (0b11110 << 11) | (S << 10) | (((uoffset >> 12) & 0x3ff) << 0));
	THUMB_EMIT (p, (0b11 << 14) | (J1 << 13) | (0x1 << 12) | (J2 << 11) | (((uoffset >> 1) & 0x7ff) << 0));

	return p;
}

static inline gpointer
arm_emit_bl (guint8 *p, int offset)
{
	if (use_thumb)
		p = thumb_emit_bl (p, offset);
	else
		ARM_BL (p, offset);
	return p;
}

#undef ARM_BL
#define ARM_BL(p,offset) do { (p) = arm_emit_bl ((gpointer)(p), (offset)); } while (0)

/* BLX */

static inline gpointer
thumb_emit_blx (guint8 *p, int offset)
{
	int S, J1, J2;
	guint32 uoffset = (guint32)offset;
	guint32 imm10H, imm10L;

	g_assert ((uoffset & 0x1) == 0);

	// FIXME:
	//g_assert ((offset >> 22) == 0);

	// FIXME:
	S = 1;
	J1 = J2 = 1;
	imm10H = (uoffset >> 12) & 0x3ff;
	imm10L = (uoffset >> 2) & 0x3ff;
	THUMB_EMIT (p, (0b11110 << 11) | (S << 10) | (imm10H << 0));
	THUMB_EMIT (p, (0b11 << 14) | (J1 << 13) | (0 << 12) | (J2 << 11) | (imm10L << 1) | (0 << 0));

	return p;
}

static inline gpointer
arm_emit_blx (guint8 *p, int offset)
{
	if (use_thumb)
		p = thumb_emit_blx (p, offset);
	else {
		g_assert_not_reached ();
	}
	return p;
}

#undef ARM_BLX
#define ARM_BLX(p,offset) do { (p) = arm_emit_blx ((gpointer)(p), (offset)); } while (0)

/* MOVT */

static inline gpointer
thumb_emit_movt_reg_imm (guint8 *p, int rd, int imm)
{
	guint32 i = (guint32)imm;

	g_assert ((i >> 16) == 0);

	/* T1 encoding */
	THUMB_EMIT (p, (0x1e << 11) | (((i >> 11) & 0x1) << 10) | (0x2 << 8) | (0x1 << 7) | (0x1 << 6) | (0x0 << 5) | (0x0 << 4) | ((i >> 12) << 0));
	THUMB_EMIT (p, (0x0 << 15) | (((i >> 8) & 0x7) << 12) | (rd << 8) | ((i & 0xff) << 0));

	return p;
}

static inline gpointer
arm_emit_movt_reg_imm (guint8 *p, int rd, int imm)
{
	if (use_thumb)
		p = thumb_emit_movt_reg_imm (p, rd, imm);
	else
		ARM_MOVT_REG_IMM (p, rd, imm);
	return p;
}

#undef ARM_MOVT_REG_IMM
#define ARM_MOVT_REG_IMM(p, rd, imm) do { (p) = arm_emit_movt_reg_imm ((gpointer)(p), (rd), (imm)); } while (0)

/* BX */

static inline gpointer
thumb_emit_bx (guint8 *p, int reg)
{
	THUMB_EMIT (p, (0b010001 << 10) | (0b11 << 8) | (0 << 7) | (reg << 3) | (0 << 0));
	return p;
}

static inline gpointer
arm_emit_bx (guint8 *p, int reg)
{
	if (use_thumb)
		p = thumb_emit_bx (p, reg);
	else
		ARM_BX (p, reg);
	return p;
}

#undef ARM_BX
#define ARM_BX(p, reg) do { (p) = arm_emit_bx ((gpointer)(p), (reg)); } while (0)

#endif

