//
// Common tablegen definitions for cpu-<ARCH>.td files
//

include "ops.td"

// Register descriptor
// Used by the local register allocator
class RegSpec<string _spec> {
	  string spec = _spec;
}

// Automically mapped based on the opcode definition
// 'i' for IREG, 'f' for FREG, 'x' for XREG
def RegDefault : RegSpec<"default">;
// Same as 'i', but only read if its on a dest
def RegBase : RegSpec<"b">;

// Clobber descriptor
// Used by the local register allocator
class ClobSpec<string _spec> {
	  string spec = _spec;
}

def ClobNone : ClobSpec<"">;
def ClobCallee : ClobSpec<"c">;

// defs should inherit from this class
// the name of the def should match the label field of a OP_... def from ops.td
class InsGeneral<int _len, RegClass _dest, RegClass _src1, RegClass _src2, RegClass _src3, ClobSpec _clob> {
	int dest = _dest;
	int src1 = _src1;
	int src2 = _src2;
	int src3 = _src3;
	int len = _len;
	ClobSpec clob = _clob;
}

// Common case
class Ins<int _len = 0>: InsGeneral<_len, RegDefault, RegDefault, RegDefault, RegDefault, ClobNone> {
}
