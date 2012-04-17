using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;

struct Foo {
	public int i, j;
}

struct GFoo<T> {
	public T dummy;
	public T t;
	public int i;
	public Foo f;
	public static T static_dummy;
	public static T static_t;
	public static Foo static_f;
}

struct GFoo2<T> {
	public T t, t2;
}

//
// Tests for generic sharing of vtypes.
// The tests use arrays to pass/receive values to keep the calling convention of the methods stable, which is a current limitation of the runtime support for gsharedvt.
//

// FIXME: Add mixed ref/noref tests, i.e. Dictionary<string, int>

public class Tests
{
	public static int Main (String[] args) {
		return TestDriver.RunTests (typeof (Tests), args);
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void gshared<T> (T [] array, int i, int j) {
		T tmp = array [i];
		array [i] = array [j];
		array [j] = tmp;
	}

	// Test that the gshared and gsharedvt versions don't mix
	public static int test_0_vt_gshared () {
		string[] sarr = new string [2] { "A", "B" };

		gshared<string> (sarr, 0, 1);

		Foo[] arr = new Foo [2];
		arr [0] = new Foo () { i = 1, j = 2 };
		arr [1] = new Foo () { i = 3, j = 4 };

		gshared<Foo> (arr, 0, 1);
		if (arr [0].i != 3 || arr [0].j != 4)
			return 1;
		if (arr [1].i != 1 || arr [1].j != 2)
			return 2;

		return 0;
	}

	static void ldelem_stelem<T> (T [] array, int i, int j) {
		T tmp = array [i];
		array [i] = array [j];
		array [j] = tmp;
	}

	public static int test_0_vt_ldelem_stelem () {
		Foo[] arr = new Foo [2];
		arr [0] = new Foo () { i = 1, j = 2 };
		arr [1] = new Foo () { i = 3, j = 4 };

		ldelem_stelem<Foo> (arr, 0, 1);
		if (arr [0].i != 3 || arr [0].j != 4)
			return 1;
		if (arr [1].i != 1 || arr [1].j != 2)
			return 2;

		int[] arr2 = new int [2] { 1, 2 };
		ldelem_stelem<int> (arr2, 0, 1);
		if (arr2 [0] !=2 || arr2 [1] != 1)
			return 3;

		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	private static void initobj<T> (T [] array, int i, int j) {
		T x = default(T);
		array [i] = x;
	}

	public static int test_0_vt_initobj () {
		Foo[] arr = new Foo [2];
		arr [0] = new Foo () { i = 1, j = 2 };
		arr [1] = new Foo () { i = 3, j = 4 };

		initobj<Foo> (arr, 0, 1);
		if (arr [0].i != 0 || arr [0].j != 0)
			return 1;
		if (arr [1].i != 3 || arr [1].j != 4)
			return 2;
		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	private static void box<T> (T [] array, object[] arr) {
		object x = array [0];
		arr [0] = x;
	}

	public static int test_0_vt_box () {
		Foo[] arr = new Foo [2];
		arr [0] = new Foo () { i = 1, j = 2 };

		object[] arr2 = new object [16];
		box<Foo> (arr, arr2);
		if (arr2 [0].GetType () != typeof (Foo))
			return 1;
		Foo f = (Foo)arr2 [0];
		if (f.i != 1 || f.j != 2)
			return 2;
		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	private static void unbox_any<T> (T [] array, object[] arr) {
		T t = (T)arr [0];
		array [0] = t;
	}

	public static int test_0_vt_unbox_any () {
		Foo[] arr = new Foo [2];

		object[] arr2 = new object [16];
		arr2 [0] = new Foo () { i = 1, j = 2 };
		unbox_any<Foo> (arr, arr2);
		if (arr [0].i != 1 || arr [0].j != 2)
			return 2;
		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void ldfld_nongeneric<T> (GFoo<T>[] foo, int[] arr) {
		arr [0] = foo [0].i;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void ldfld<T> (GFoo<T>[] foo, T[] arr) {
		arr [0] = foo [0].t;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void stfld_nongeneric<T> (GFoo<T>[] foo, int[] arr) {
		foo [0].i = arr [0];
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void stfld<T> (GFoo<T>[] foo, T[] arr) {
		foo [0].t = arr [0];
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void ldflda<T> (GFoo<T>[] foo, int[] arr) {
		arr [0] = foo [0].f.i;
	}

	public static int test_0_vt_ldfld_stfld () {
		var foo = new GFoo<Foo> () { t = new Foo () { i = 1, j = 2 }, i = 5, f = new Foo () { i = 5, j = 6 } };
		var farr = new GFoo<Foo>[] { foo };

		/* Normal fields with a variable offset */
		var iarr = new int [10];
		ldfld_nongeneric<Foo> (farr, iarr);
		if (iarr [0] != 5)
			return 1;
		iarr [0] = 16;
		stfld_nongeneric<Foo> (farr, iarr);
		if (farr [0].i != 16)
			return 2;

		/* Variable type field with a variable offset */
		var arr = new Foo [10];
		ldfld<Foo> (farr, arr);
		if (arr [0].i != 1 || arr [0].j != 2)
			return 3;
		arr [0] = new Foo () { i = 3, j = 4 };
		stfld<Foo> (farr, arr);
		if (farr [0].t.i != 3 || farr [0].t.j != 4)
			return 4;

		ldflda<Foo> (farr, iarr);
		if (iarr [0] != 5)
			return 5;

		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void stsfld<T> (T[] arr) {
		GFoo<T>.static_t = arr [0];
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void ldsfld<T> (T[] arr) {
		arr [0] = GFoo<T>.static_t;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static void ldsflda<T> (int[] iarr) {
		iarr [0] = GFoo<T>.static_f.i;
	}
	
	public static int test_0_stsfld () {
		Foo[] farr = new Foo [] { new Foo () { i = 1, j = 2 } };
		stsfld<Foo> (farr);

		if (GFoo<Foo>.static_t.i != 1 || GFoo<Foo>.static_t.j != 2)
			return 1;

		Foo[] farr2 = new Foo [1];
		ldsfld<Foo> (farr2);
		if (farr2 [0].i != 1 || farr2 [0].j != 2)
			return 2;

		var iarr = new int [10];
		GFoo<Foo>.static_f = new Foo () { i = 5, j = 6 };
		ldsflda<Foo> (iarr);
		if (iarr [0] != 5)
			return 3;

		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static object newarr<T> () {
		object o = new T[10];
		return o;
	}

	public static int test_0_vt_newarr () {
		object o = newarr<Foo> ();
		if (!(o is Foo[]))
			return 1;
		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static Type ldtoken<T> () {
		return typeof (GFoo<T>);
	}

	public static int test_0_vt_ldtoken () {
		Type t = ldtoken<Foo> ();
		if (t != typeof (GFoo<Foo>))
			return 1;
		t = ldtoken<int> ();
		if (t != typeof (GFoo<int>))
			return 2;

		return 0;
	}

	public static int test_0_vtype_list () {
		List<int> l = new List<int> ();

		l.Add (5);
		if (l.Count != 1)
			return 1;
		return 0;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static int args_simple<T> (T t, int i) {
		return i;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static Type args_rgctx<T> (T t, int i) {
		return typeof (T);
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static Type eh_in<T> (T t, int i) {
		throw new OverflowException ();
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	static T return_t<T> (T t) {
		return t;
	}

	[MethodImplAttribute (MethodImplOptions.NoInlining)]
	T return_this_t<T> (T t) {
		return t;
	}

	public static int test_0_gsharedvt_in () {
		// Check that the non-generic argument is passed at the correct stack position
		int r = args_simple<bool> (true, 42);
		if (r != 42)
			return 1;
		r = args_simple<Foo> (new Foo (), 43);
		if (r != 43)
			return 2;
		// Check that the proper rgctx is passed to the method
		Type t = args_rgctx<int> (5, 42);
		if (t != typeof (int))
			return 3;
		// Check that EH works properly
		try {
			eh_in<int> (1, 2);
		} catch (OverflowException) {
		}
		return 0;
	}

	public static int test_0_gsharedvt_in_ret () {
		int i = return_t<int> (42);
		if (i != 42)
			return 1;
		long l = return_t<long> (Int64.MaxValue);
		if (l != Int64.MaxValue)
			return 2;
		double d = return_t<double> (3.0);
		if (d != 3.0)
			return 3;
		float f = return_t<float> (3.0f);
		if (f != 3.0f)
			return 4;
		var v = new GFoo2<int> () { t = 55, t2 = 32 };
		var v2 = return_t<GFoo2<int>> (v);
		if (v2.t != 55 || v2.t2 != 32)
			return 5;
		i = new Tests ().return_this_t<int> (42);
		if (i != 42)
			return 6;
		return 0;
	}

	public static int test_0_regress () {
		var cmp = System.Collections.Generic.Comparer<int>.Default ;
		if (cmp == null)
			return 1;
		return 0;
	}
}
