/*
 * lldb.c: Mono support for LLDB.
 *
 * Author:
 *   Zoltan Varga (vargaz@gmail.com)
 *
 * Copyright 2016 Xamarin, Inc (http://www.xamarin.com)
 */

#include "config.h"
#include "mini.h"
#include "lldb.h"

typedef enum {
	ENTRY_CODE_REGION = 1,
	ENTRY_METHOD = 2
} EntryType;

/*
 * Represents a memory region used for code.
 */
typedef struct {
	/*
	 * OBJFILE_MAGIC. This is needed to make it easier for lldb to
	 * create object files from this packet.
	 */
	char magic [32];
	guint64 start;
	guint32 size;
} CodeRegionEntry;

typedef struct {
	int op;
	int when;
	int reg;
	int val;
} UnwindOp;

/*
 * Represents a managed method.
 */
typedef struct {
	/* The start of the codegen region which contains CODE */
	guint64 region_addr;
	guint64 code;
	int code_size;
	int nunwind_ops;
	int name_offset;
	int unwind_ops_offset;
} MethodEntry;

/* One data packet sent from the runtime to the debugger */
typedef struct {
	/* The type of data pointed to by ADDR */
	/* One of the ENTRY_ constants */
	guint32 type;
	guint64 size;
	gpointer addr;
} DebugEntry;

typedef struct
{
	/* (MAJOR << 16) | MINOR */
	guint32 version;
	DebugEntry *entry;
} JitDescriptor;

#define MAJOR_VERSION 1
#define MINOR_VERSION 0

static const char* OBJFILE_MAGIC = { "MONO_JIT_OBJECT_FILE" };

JitDescriptor __mono_jit_debug_descriptor = { (MAJOR_VERSION << 16) | MINOR_VERSION };

void MONO_NEVER_INLINE __mono_jit_debug_register_code(void);

/* The native debugger puts a breakpoint in this function. */
void MONO_NEVER_INLINE
__mono_jit_debug_register_code(void)
{
	/* Make sure that even compilers that ignore __noinline__ don't inline this */
#if defined(__GNUC__)
 	asm ("");
#endif
}

void
mono_lldb_init (const char *options)
{
}

typedef struct {
	gpointer code;
	gpointer region_start;
	guint32 region_size;
	gboolean found;
} UserData;

static int
find_code_region (void *data, int csize, int size, void *user_data)
{
	UserData *ud = user_data;

	if ((char*)ud->code >= (char*)data && (char*)ud->code < (char*)data + csize) {
		ud->region_start = data;
		ud->region_size = csize;
		ud->found = TRUE;
		return 1;
 	}
	return 0;
}

static GHashTable *codegen_regions;

static void
send_entry (EntryType type, gpointer buf, int size)
{
	DebugEntry *entry;

	entry = g_malloc0 (sizeof (DebugEntry));
	entry->type = type;
	entry->addr = buf;
	entry->size = size;

	__mono_jit_debug_descriptor.entry = entry;
	__mono_jit_debug_register_code ();
}

void
mono_lldb_save_method_info (MonoCompile *cfg)
{
	CodeRegionEntry *region_entry;
	MethodEntry *method_entry;
	UserData udata;
	int i, buf_len;
	guint8 *buf, *p;
	gboolean region_found;
	UnwindOp *ops;
	GSList *l;

	if (cfg->method->dynamic)
		return;

	/* Find the codegen region which contains the code */
	memset (&udata, 0, sizeof (udata));
	udata.code = cfg->native_code;
	mono_domain_code_foreach (cfg->domain, find_code_region, &udata);
	g_assert (udata.found);

	// FIXME: Locking
	if (!codegen_regions)
		codegen_regions = g_hash_table_new (NULL, NULL);
	region_found = g_hash_table_lookup (codegen_regions, udata.region_start) != NULL;
	if (!region_found)
		g_hash_table_insert (codegen_regions, udata.region_start, udata.region_start);

	if (!region_found) {
		/* Register the region with the debugger */
		buf_len = 1024;
		buf = p = g_malloc0 (buf_len);

		region_entry = (CodeRegionEntry*)p;
		p += sizeof (CodeRegionEntry);
		memset (region_entry, 0, sizeof (CodeRegionEntry));
		strcpy (region_entry->magic, OBJFILE_MAGIC);
		region_entry->start = (gsize)udata.region_start;
		region_entry->size = (gsize)udata.region_size;

		send_entry (ENTRY_CODE_REGION, buf, p - buf);
	}

	// FIXME:
	buf_len = 1024;
	buf = p = g_malloc0 (buf_len);

	method_entry = (MethodEntry*)p;
	p += sizeof (MethodEntry);
	method_entry->region_addr = (gsize)udata.region_start;
	method_entry->code = (gsize)cfg->native_code;
	method_entry->code_size = cfg->code_size;

	/* Add unwind info */
	//cie = mono_unwind_get_cie_program ();
	/* We use the unencoded version of the unwind info to make it easier to decode */
	method_entry->nunwind_ops = g_slist_length (cfg->unwind_ops);
	method_entry->unwind_ops_offset = p - buf;
	ops = (UnwindOp*)p;
	i = 0;
	for (l = cfg->unwind_ops; l; l = l->next) {
		MonoUnwindOp *op = l->data;

		ops [i].op = op->op;
		ops [i].when = op->when;
		ops [i].reg = mono_hw_reg_to_dwarf_reg (op->reg);
		ops [i].val = op->val;
		i ++;
 	}
	p += sizeof (UnwindOp) * method_entry->nunwind_ops;

	method_entry->name_offset = p - buf;
	strcpy ((char*)p, cfg->method->name);
	p += strlen (cfg->method->name) + 1;

	send_entry (ENTRY_METHOD, buf, p - buf);
}

void
mono_lldb_save_trampoline_info (MonoTrampInfo *info)
{
}

//
// FIXME:
// -add a way to disable this
// -DISABLE_JIT
//

/*
DESIGN:

Communication:
Similar to the gdb jit interface. The runtime communicates with a plugin running inside lldb.
- The runtime allocates a data packet, points a symbol with a well known name at it.
- It calls a dummy function with a well known name.
- The plugin sets a breakpoint at this function, causing the runtime to be suspended.
- The plugin reads the data pointed to by the other symbol and processes it.

The data packets are kept in a list, so lldb can read all of them after attaching.
Lldb will associate an object file with each mono codegen region.

Packet design:
- use a flat byte array so the whole data can be read in one operation.
- use 64 bit ints for pointers.
*/
