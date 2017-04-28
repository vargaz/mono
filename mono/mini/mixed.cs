using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.CompilerServices;
using System.Diagnostics;

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

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static int entry_9_int_args (int i1, int i2, int i3, int i4, int i5, int i6, int i7, int i8, int i9) {
		return i1 + i2 + i3 + i4 + i5 + i6 + i7 + i8 + i9;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static IntPtr entry_intptr_intptr (IntPtr i) {
		return i;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static StackTrace get_stacktrace_interp () {
		var o = new object ();
		return new StackTrace (true);
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
		res = InterpClass.entry_9_int_args (1, 2, 3, 4, 5, 6, 7, 8, 9);
		if (res != 45)
			return 9;
		var ptr = new IntPtr (32);
		var ptr2 = InterpClass.entry_intptr_intptr (ptr);
		if (ptr != ptr2)
			return 10;
		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static AStruct exit_vtype (AStruct s) {
		return s;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static List<string> exit_ginst (List<string> l) {
		return l;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static GStruct<string> exit_ginst_vtype (GStruct<string> l) {
		return l;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static void exit_byref (ref int i) {
		i += 1;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static void throw_ex () {
		throw new Exception ();
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	public static StackTrace get_stacktrace_jit () {
		return InterpClass.get_stacktrace_interp ();
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

	public static int test_0_exit () {
		var astruct = new AStruct () { i = 1};
		var astruct2 = JitClass.exit_vtype (astruct);
		if (astruct2.i != 1)
			return 1;
		var ginst = new List<string> ();
		var ginst2 = JitClass.exit_ginst (ginst);
		if (ginst != ginst2)
			return 2;
		var gstruct = new GStruct<string> () { i = 1 };
		var gstruct2 = JitClass.exit_ginst_vtype (gstruct);
		if (gstruct2.i != 1)
			return 3;
		var anint = 1;
		JitClass.exit_byref (ref anint);
		if (anint != 2)
			return 4;
		return 0;
	}

	public static int test_0_eh1 () {
		// Throw an exception from jitted code, catch it in interpreted code
		try {
			JitClass.throw_ex ();
		} catch {
			return 0;
		}
		return 1;
	}

	static bool finally_called;

	public static void call_finally () {
		try {
			JitClass.throw_ex ();
		} finally {
			finally_called = true;
		}
	}

	public static int test_0_eh2 () {
		finally_called = false;

		// Throw an exception from jitted code, execute finally in interpreted code
		try {
			call_finally ();
		} catch {
			return 0;
		}
		if (!finally_called)
			return 2;
		return 1;
	}

	public static int test_0_stack_traces () {
		//
		// Get a stacktrace for an interp->jit->interp call stack
		//
		StackTrace st = JitClass.get_stacktrace_jit ();
		var frame = st.GetFrame (0);
		if (frame.GetMethod ().Name != "get_stacktrace_interp")
			return 1;
		frame = st.GetFrame (1);
		if (frame.GetMethod ().Name != "get_stacktrace_jit")
			return 2;
		frame = st.GetFrame (2);
		if (frame.GetMethod ().Name != "test_0_stack_traces")
			return 3;
		return 0;
	}
}