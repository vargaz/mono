using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.CompilerServices;

/*
 * Regression tests for the mixed-mode execution.
 * Run with --interp=jit=JitClass
 */

struct AStruct {
	public int i;
}

struct GStruct<T> {
	public int i;
}

class InterpClass
{
	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static void entry_void_0 () {
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static int entry_int_int (int i) {
		return i + 1;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public int entry_int_this_int (int i) {
		return i + 1;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static string entry_string_string (string s1, string s2) {
		return s1 + s2;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static AStruct entry_struct_struct (AStruct l) {
		return l;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static List<string> entry_ginst_ginst (List<string> l) {
		return l;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static GStruct<string> entry_ginst_ginst_vtype (GStruct<string> l) {
		return l;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static void entry_void_byref_int (ref int i) {
		i = i + 1;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static int entry_8_int_args (int i1, int i2, int i3, int i4, int i5, int i6, int i7, int i8) {
		return i1 + i2 + i3 + i4 + i5 + i6 + i7 + i8;
	}
}

/* The methods in this class will always be JITted */
class JitClass
{
	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static int entry () {
		InterpClass.entry_void_0 ();
		InterpClass.entry_void_0 ();
		int res = InterpClass.entry_int_int (1);
		if (res != 2)
			return 1;
		var c = new InterpClass ();
		res = c.entry_int_this_int (1);
		if (res != 2)
			return 2;
		var s = InterpClass.entry_string_string ("A", "B");
		if (s != "AB")
			return 3;
		var astruct = new AStruct () { i = 1 };
		var astruct2 = InterpClass.entry_struct_struct (astruct);
		if (astruct2.i != 1)
			return 4;
		var l = new List<string> ();
		var l2 = InterpClass.entry_ginst_ginst (l);
		if (l != l2)
			return 5;
		var gstruct = new GStruct<string> () { i = 1 };
		var gstruct2 = InterpClass.entry_ginst_ginst_vtype (gstruct);
		if (gstruct2.i != 1)
			return 6;
		int val = 1;
		InterpClass.entry_void_byref_int (ref val);
		if (val != 2)
			return 7;
		res = InterpClass.entry_8_int_args (1, 2, 3, 4, 5, 6, 7, 8);
		if (res != 36)
			return 8;
		return 0;
	}
}

#if __MOBILE__
class MixedTests
#else
class Tests
#endif
{

#if !__MOBILE__
	public static int Main (string[] args) {
		return TestDriver.RunTests (typeof (Tests), args);
	}
#endif

	public static int test_0_entry () {
		// This does an interp->jit transition
		return JitClass.entry ();
	}
}