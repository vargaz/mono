/*
 * interp.h: CIL Interpreter for Mini
 *
 * Based on interp/interp.h.
 *
 * (C) 2010 Novell, Inc.
 */

#ifndef __MONO_INTERP_H__
#define __MONO_INTERP_H__

#include "mini.h"
#include <setjmp.h>

enum {
	VAL_I32     = 0,
	VAL_DOUBLE  = 1,
	VAL_I64     = 2,
	VAL_VALUET  = 3,
	VAL_POINTER = 4,
	VAL_NATI    = 0 + VAL_POINTER,
	VAL_MP      = 1 + VAL_POINTER,
	VAL_TP      = 2 + VAL_POINTER,
	VAL_OBJ     = 3 + VAL_POINTER
};

#if SIZEOF_VOID_P == 4
typedef guint32 mono_u;
typedef gint32  mono_i;
#elif SIZEOF_VOID_P == 8
typedef guint64 mono_u;
typedef gint64  mono_i;
#endif

/*
 * Value types are represented on the eval stack as pointers to the
 * actual storage. The size field tells how much storage is allocated.
 * A value type can't be larger than 16 MB.
 */
typedef struct {
	union {
		gint32 i;
		gint64 l;
		double f;
		/* native size integer and pointer types */
		gpointer p;
		mono_u nati;
		gpointer vt;
	} data;
} stackval;


/* 
 * Structure representing a method transformed for the interpreter 
 * This is domain specific
 */
typedef struct _RuntimeMethod
{
	MonoMethod *method;
	guint32 locals_size;
	guint32 args_size;
	guint32 stack_size;
	guint32 vt_stack_size;
	guint32 alloca_size;
	unsigned short *code;
	unsigned short *new_body_start; /* after all STINARG instrs */
	//MonoPIFunc func;
	int num_clauses;
	MonoExceptionClause *clauses;
	void **data_items;
	int transformed;
	int transform_failed;
	guint32 *arg_offsets;
	guint32 *local_offsets;
	unsigned int param_count;
	unsigned int hasthis;
	unsigned int valuetype;
} RuntimeMethod;

/*
 * Represents an interpred method frame
 */
typedef struct MonoInvocation {
	struct MonoInvocation *parent; /* parent */
	RuntimeMethod  *runtime_method; /* parent */
	MonoMethod     *method; /* parent */
	stackval       *retval; /* parent */
	void           *obj;    /* this - parent */
	char           *args;
	stackval       *stack_args; /* parent */
	stackval       *stack;
	stackval       *sp; /* For GC stack marking */
	/* exception info */
	unsigned char  invoke_trap;
	const unsigned short  *ip;
	MonoException     *ex;
	MonoExceptionClause *ex_handler;
} MonoInvocation;

/* Stores thread-specific information used by the interpreter */
typedef struct {
	MonoDomain *domain;
	MonoInvocation *base_frame;
	MonoInvocation *current_frame;
	MonoInvocation *env_frame;
	jmp_buf *current_env;
	unsigned char search_for_handler;
	unsigned char managed_code;
} ThreadContext;

/*
 * A buffer which is used to pass return values from mono_interp_enter to the INTERP_ENTER
 * trampoline. The mapping between the fields of this struct and hardware registers is arch
 * specific.
 */
typedef struct {
	mgreg_t gregs [2];
	mgreg_t fregs [1];
} InterpResultBuf;

MonoException *
mono_interp_transform_method (RuntimeMethod *runtime_method, ThreadContext *context);

MonoDelegate*
mono_interp_ftnptr_to_delegate (MonoClass *klass, gpointer ftn);

void
mono_interp_transform_init (void);

void inline stackval_from_data (MonoType *type, stackval *result, char *data, gboolean pinvoke);
void inline stackval_to_data (MonoType *type, stackval *val, char *data, gboolean pinvoke);
void ves_exec_method (MonoInvocation *frame);

RuntimeMethod *
mono_interp_get_runtime_method (MonoMethod *method);

void mono_interp_enter (RuntimeMethod *rmethod, mgreg_t *regs, mgreg_t *fpregs, InterpResultBuf *res_buf);

extern int mono_interp_traceopt;

#endif
