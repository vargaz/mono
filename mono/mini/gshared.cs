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
}

//
// Tests for generic sharing of vtypes.
// The tests use arrays to pass/receive values to keep the calling convention of the methods stable, which is a current limitation of the runtime support for gsharedvt.
//

public class Tests
{
	public static int Main (String[] args) {
		return TestDriver.RunTests (typeof (Tests), args);
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

	public static int test_0_vt_ldfld () {
		var foo = new GFoo<Foo> () { t = new Foo () { i = 1, j = 2 }, i = 5 };
		var farr = new GFoo<Foo>[] { foo };

		/* Normal fields with a variable offset */
		var iarr = new int [10];
		ldfld_nongeneric<Foo> (farr, iarr);
		Console.WriteLine (iarr [0]);

		/*
		var arr = new Foo [10];

		ldfld<Foo> (new GFoo<Foo> [] { foo }, arr);
		Console.WriteLine (arr [0].i);
		Console.WriteLine (arr [0].j);
		*/
		return 0;
	}

	// FIXME: Add tests for more types to each method

	public static int test_0_vtype_list () {
		List<int> l = new List<int> ();

		l.Add (5);
		//Console.WriteLine (l.Count);
		return 0;
	}
}
