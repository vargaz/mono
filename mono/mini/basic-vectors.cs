using System;
using System.Numerics;

/*
 * Tests for the SIMD intrinsics in the System.Numerics.Vectors assembly.
 */
public class VectorTests {

#if !MOBILE
	public static int Main (string[] args) {
		return TestDriver.RunTests (typeof (VectorTests), args);
	}
#endif

	public static int test_0_is_hw_accelerated () {
		bool b = VectorMath.IsHardwareAccelerated;
		return b ? 0 : 0;
	}

	public static int test_0_vector2f_ctor () {
		var v = new Vector2f (1.0f, 2.0f);
		if (v.X != 1.0f)
			return 1;
		if (v.Y != 2.0f)
			return 2;
		return 0;
	}

	public static int test_0_vector2f_one_element_ctor () {
		var v = new Vector2f (1.0f);
		if (v.X != 1.0f)
			return 1;
		if (v.Y != 1.0f)
			return 2;
		return 0;
	}

	public static int test_0_vector2f_set_x () {
		var v = new Vector2f (1.0f);
		v.X = 2.0f;
		if (v.X != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector2f_set_y () {
		var v = new Vector2f (1.0f);
		v.Y = 2.0f;
		if (v.Y != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector2f_add () {
		var v1 = new Vector2f (1.0f, 2.0f);
		var v2 = new Vector2f (3.0f, 4.0f);
		var v = v1 + v2;
		if (v.X != 4.0f || v.Y != 6.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector2f_sub () {
		var v1 = new Vector2f (1.0f, 2.0f);
		var v2 = new Vector2f (3.0f, 4.0f);
		var v = v1 - v2;
		if (v.X != -2.0f || v.Y != -2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector2f_mul () {
		var v1 = new Vector2f (1.0f, 2.0f);
		var v2 = new Vector2f (3.0f, 4.0f);
		var v = v1 * v2;
		if (v.X != 3.0f || v.Y != 8.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector2f_div () {
		var v1 = new Vector2f (8.0f, 6.0f);
		var v2 = new Vector2f (2.0f, 3.0f);
		var v = v1 / v2;
		if (v.X != 4.0f || v.Y != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector2f_neg () {
		var v1 = new Vector2f (8.0f, 6.0f);
		var v = - v1;
		if (v.X != -8.0f || v.Y != -6.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector2f_equals () {
		var v1 = new Vector2f (8.0f, 6.0f);
		var v2 = new Vector2f (8.0f, 1.0f);
		var v3 = new Vector2f (1.0f, 6.0f);
		if (!v1.Equals (v1))
			return 1;
		if (v1.Equals (v2))
			return 2;
		if (v1.Equals (v3))
			return 3;
		return 0;
	}

	public static int test_0_vector3f_ctor () {
		var v = new Vector3f (1.0f, 2.0f, 3.0f);
		if (v.X != 1.0f)
			return 1;
		if (v.Y != 2.0f)
			return 2;
		if (v.Z != 3.0f)
			return 3;
		return 0;
	}

	public static int test_0_vector3f_one_element_ctor () {
		var v = new Vector3f (1.0f);
		if (v.X != 1.0f)
			return 1;
		if (v.Y != 1.0f)
			return 2;
		if (v.Z != 1.0f)
			return 3;
		return 0;
	}

	public static int test_0_vector3f_set_x () {
		var v = new Vector3f (1.0f);
		v.X = 2.0f;
		if (v.X != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector3f_set_y () {
		var v = new Vector3f (1.0f);
		v.Y = 2.0f;
		if (v.Y != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector3f_set_z () {
		var v = new Vector3f (1.0f);
		v.Z = 2.0f;
		if (v.Z != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector3f_add () {
		var v1 = new Vector3f (1.0f, 2.0f, 3.0f);
		var v2 = new Vector3f (3.0f, 4.0f, 4.0f);
		var v = v1 + v2;
		if (v.X != 4.0f || v.Y != 6.0f || v.Z != 7.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector3f_sub () {
		var v1 = new Vector3f (1.0f, 2.0f, 3.0f);
		var v2 = new Vector3f (3.0f, 4.0f, 4.0f);
		var v = v1 - v2;
		if (v.X != -2.0f || v.Y != -2.0f || v.Z != -1.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector3f_mul () {
		var v1 = new Vector3f (1.0f, 2.0f, 3.0f);
		var v2 = new Vector3f (3.0f, 4.0f, 4.0f);
		var v = v1 * v2;
		if (v.X != 3.0f || v.Y != 8.0f || v.Z != 12.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector3f_div () {
		var v1 = new Vector3f (8.0f, 6.0f, 12.0f);
		var v2 = new Vector3f (2.0f, 3.0f, 2.0f);
		var v = v1 / v2;
		if (v.X != 4.0f || v.Y != 2.0f || v.Z != 6.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector3f_neg () {
		var v1 = new Vector3f (8.0f, 6.0f, 12.0f);
		var v = - v1;
		if (v.X != -8.0f || v.Y != -6.0f || v.Z != -12.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector3f_equals () {
		var v1 = new Vector3f (8.0f, 6.0f, 12.0f);
		var v2 = new Vector3f (8.0f, 1.0f, 12.0f);
		var v3 = new Vector3f (1.0f, 6.0f, 12.0f);
		if (!v1.Equals (v1))
			return 1;
		if (v1.Equals (v2))
			return 2;
		if (v1.Equals (v3))
			return 3;
		return 0;
	}

	public static int test_0_vector4f_ctor () {
		var v = new Vector4f (1.0f, 2.0f, 3.0f, 4.0f);
		if (v.X != 1.0f)
			return 1;
		if (v.Y != 2.0f)
			return 2;
		if (v.Z != 3.0f)
			return 3;
		if (v.W != 4.0f)
			return 4;
		return 0;
	}

	public static int test_0_vector4f_one_element_ctor () {
		var v = new Vector4f (1.0f);
		if (v.X != 1.0f)
			return 1;
		if (v.Y != 1.0f)
			return 2;
		if (v.Z != 1.0f)
			return 3;
		if (v.W != 1.0f)
			return 4;
		return 0;
	}

	public static int test_0_vector4f_set_x () {
		var v = new Vector4f (1.0f);
		v.X = 2.0f;
		if (v.X != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_set_y () {
		var v = new Vector4f (1.0f);
		v.Y = 2.0f;
		if (v.Y != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_set_z () {
		var v = new Vector4f (1.0f);
		v.Z = 2.0f;
		if (v.Z != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_set_w () {
		var v = new Vector4f (1.0f);
		v.W = 2.0f;
		if (v.W != 2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_add () {
		var v1 = new Vector4f (1.0f, 2.0f, 3.0f, 4.0f);
		var v2 = new Vector4f (3.0f, 4.0f, 4.0f, 5.0f);
		var v = v1 + v2;
		if (v.X != 4.0f || v.Y != 6.0f || v.Z != 7.0f || v.W != 9.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_sub () {
		var v1 = new Vector4f (1.0f, 2.0f, 3.0f, 4.0f);
		var v2 = new Vector4f (3.0f, 4.0f, 4.0f, 6.0f);
		var v = v1 - v2;
		if (v.X != -2.0f || v.Y != -2.0f || v.Z != -1.0f || v.W != -2.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_mul () {
		var v1 = new Vector4f (1.0f, 2.0f, 3.0f, 4.0f);
		var v2 = new Vector4f (3.0f, 4.0f, 4.0f, 5.0f);
		var v = v1 * v2;
		if (v.X != 3.0f || v.Y != 8.0f || v.Z != 12.0f || v.W != 20.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_div () {
		var v1 = new Vector4f (8.0f, 6.0f, 12.0f, 16.0f);
		var v2 = new Vector4f (2.0f, 3.0f, 2.0f, 4.0f);
		var v = v1 / v2;
		if (v.X != 4.0f || v.Y != 2.0f || v.Z != 6.0f || v.W != 4.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_neg () {
		var v1 = new Vector4f (8.0f, 6.0f, 12.0f, 20.0f);
		var v = - v1;
		if (v.X != -8.0f || v.Y != -6.0f || v.Z != -12.0f || v.W != -20.0f)
			return 1;
		return 0;
	}

	public static int test_0_vector4f_equals () {
		var v1 = new Vector4f (8.0f, 6.0f, 12.0f, 20.0f);
		var v2 = new Vector4f (8.0f, 1.0f, 12.0f, 20.0f);
		var v3 = new Vector4f (1.0f, 6.0f, 12.0f, 20.0f);
		if (!v1.Equals (v1))
			return 1;
		if (v1.Equals (v2))
			return 2;
		if (v1.Equals (v3))
			return 3;
		return 0;
	}

	public static int test_0_vector_t_length () {
		// This assumes a 16 byte simd register size
		if (Vector<byte>.Length != 16)
			return 1;
		if (Vector<short>.Length != 8)
			return 2;
		if (Vector<int>.Length != 4)
			return 3;
		if (Vector<long>.Length != 2)
			return 4;
		return 0;
	}

	public static int test_0_vector_t_zero () {
		var v = Vector<byte>.Zero;
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != 0)
				return 1;
		var v2 = Vector<double>.Zero;
		for (int i = 0; i < Vector<double>.Length; ++i)
			if (v2 [i] != 0.0)
				return 2;
		return 0;
	}

	public static int test_0_vector_t_i1_accessor () {
		var elems = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v = new Vector<byte> (elems, 0);
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != i + 1)
				return 1;
		if (v [0] != 1)
			return 2;
		if (v [1] != 2)
			return 2;
		if (v [15] != 16)
			return 2;
		try {
			int r = v [-1];
			return 3;
		} catch (IndexOutOfRangeException) {
		}
		try {
			int r = v [16];
			return 4;
		} catch (IndexOutOfRangeException) {
		}
		return 0;
	}

	public static int test_0_vector_t_i4_accessor () {
		var elems = new int [] { 1, 2, 3, 4 };
		var v = new Vector<int> (elems, 0);
		for (int i = 0; i < Vector<int>.Length; ++i)
			if (v [i] != i + 1)
				return 1;
		if (v [0] != 1)
			return 2;
		if (v [1] != 2)
			return 2;
		if (v [3] != 4)
			return 2;
		try {
			int r = v [-1];
			return 3;
		} catch (IndexOutOfRangeException) {
		}
		try {
			int r = v [Vector<int>.Length];
			return 4;
		} catch (IndexOutOfRangeException) {
		}
		return 0;
	}

	public static int test_0_vector_t_i8_accessor () {
		var elems = new long [] { 1, 2 };
		var v = new Vector<long> (elems, 0);
		for (int i = 0; i < Vector<long>.Length; ++i)
			if (v [i] != i + 1)
				return 1;
		if (v [0] != 1)
			return 2;
		if (v [1] != 2)
			return 2;
		try {
			var r = v [-1];
			return 3;
		} catch (IndexOutOfRangeException) {
		}
		try {
			var r = v [Vector<long>.Length];
			return 4;
		} catch (IndexOutOfRangeException) {
		}
		return 0;
	}

	public static int test_0_vector_t_r8_accessor () {
		var elems = new double [] { 1.0, 2.0 };
		var v = new Vector<double> (elems, 0);
		for (int i = 0; i < Vector<double>.Length; ++i)
			if (v [i] != (double)i + 1.0)
				return 1;
		if (v [0] != 1.0)
			return 2;
		if (v [1] != 2.0)
			return 2;
		try {
			var r = v [-1];
			return 3;
		} catch (IndexOutOfRangeException) {
		}
		try {
			var r = v [Vector<double>.Length];
			return 4;
		} catch (IndexOutOfRangeException) {
		}
		return 0;
	}

	public static int test_0_vector_t_i1_ctor () {
		var elems = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
								  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 };
		var v = new Vector<byte> (elems, 16);
		for (int i = 0; i < 16; ++i)
			if (v [i] != i)
				return 1;
		try {
			var v2 = new Vector<byte> (elems, 16 + 4);
			return 2;
		} catch (IndexOutOfRangeException) {
		}
		return 0;
	}

	public static int test_0_vector_t_i1_ctor_2 () {
		var elems = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v = new Vector<byte> (elems);
		for (int i = 0; i < 16; ++i)
			if (v [i] != i + 1)
				return 1;
		try {
			var elems2 = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
			var v2 = new Vector<byte> (elems2);
			return 2;
		} catch (IndexOutOfRangeException) {
		}
		return 0;
	}

	public static int test_0_vector_t_i1_ctor_3 () {
		var v = new Vector<byte> (5);
		for (int i = 0; i < 16; ++i)
			if (v [i] != 5)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i2_ctor_3 () {
		var v = new Vector<short> (5);
		for (int i = 0; i < 8; ++i)
			if (v [i] != 5)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i4_ctor_3 () {
		var v = new Vector<int> (0xffffeee);
		for (int i = 0; i < 4; ++i)
			if (v [i] != 0xffffeee)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i8_ctor_3 () {
		var v = new Vector<long> (0xffffeeeeabcdefL);
		for (int i = 0; i < 2; ++i)
			if (v [i] != 0xffffeeeeabcdefL)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_r4_ctor_3 () {
		var v = new Vector<float> (0.5f);
		for (int i = 0; i < 4; ++i) {
			if (v [i] != 0.5f)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_r8_ctor_3 () {
		var v = new Vector<double> (0.5f);
		for (int i = 0; i < 2; ++i) {
			if (v [i] != 0.5f)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_i1_add () {
		var elems1 = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v2 = new Vector<byte> (elems2);
		var v = Vector<byte>.Add (v1, v2);
		for (int i = 0; i < 16; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i2_add () {
		var elems1 = new short [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<short> (elems1);
		var elems2 = new short [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v2 = new Vector<short> (elems2);
		var v = Vector<short>.Add (v1, v2);
		for (int i = 0; i < 8; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i4_add () {
		var elems1 = new int [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<int> (elems1);
		var elems2 = new int [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v2 = new Vector<int> (elems2);
		var v = Vector<int>.Add (v1, v2);
		for (int i = 0; i < 4; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i8_add () {
		var elems1 = new long [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<long> (elems1);
		var elems2 = new long [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v2 = new Vector<long> (elems2);
		var v = Vector<long>.Add (v1, v2);
		for (int i = 0; i < 2; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i1_sub () {
		var elems1 = new byte [] { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 };
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v2 = new Vector<byte> (elems2);
		var v = v1 - v2;
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != 10)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i2_sub () {
		var elems1 = new short [] { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 };
		var v1 = new Vector<short> (elems1);
		var elems2 = new short [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v2 = new Vector<short> (elems2);
		var v = v1 - v2;
		for (int i = 0; i < Vector<short>.Length; ++i)
			if (v [i] != 10)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i4_sub () {
		var elems1 = new int [] { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 };
		var v1 = new Vector<int> (elems1);
		var elems2 = new int [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v2 = new Vector<int> (elems2);
		var v = v1 - v2;
		for (int i = 0; i < Vector<int>.Length; ++i)
			if (v [i] != 10)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i8_sub () {
		var elems1 = new long [] { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 };
		var v1 = new Vector<long> (elems1);
		var elems2 = new long [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v2 = new Vector<long> (elems2);
		var v = v1 - v2;
		for (int i = 0; i < Vector<long>.Length; ++i)
			if (v [i] != 10)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i1_mul () {
		var elems1 = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<byte> (elems1);
		var v2 = new Vector<byte> (2);
		var v = v1 * v2;
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i2_mul () {
		var elems1 = new short [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<short> (elems1);
		var v2 = new Vector<short> (2);
		var v = v1 * v2;
		for (int i = 0; i < Vector<short>.Length; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i4_mul () {
		var elems1 = new int [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<int> (elems1);
		var v2 = new Vector<int> (2);
		var v = v1 * v2;
		for (int i = 0; i < Vector<int>.Length; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i8_mul () {
		var elems1 = new long [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<long> (elems1);
		var v2 = new Vector<long> (2);
		var v = v1 * v2;
		for (int i = 0; i < Vector<long>.Length; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	/* Scalar multiply left */
	public static int test_0_vector_t_i4_mul_scalar_left () {
		var elems1 = new int [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<int> (elems1);
		var v = 2 * v1;
		for (int i = 0; i < Vector<int>.Length; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	/* Scalar multiply right */
	public static int test_0_vector_t_i4_mul_scalar_right () {
		var elems1 = new int [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		var v1 = new Vector<int> (elems1);
		var v = v1 * 2;
		for (int i = 0; i < Vector<int>.Length; ++i)
			if (v [i] != (i + 1) * 2)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_r4_div () {
		var elems1 = new float [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		for (int i = 0; i < elems1.Length; ++i)
			elems1 [i] = (float)(elems1 [i] * 2);
		var v1 = new Vector<float> (elems1);
		var v2 = new Vector<float> (2);
		var v = v1 / v2;
		for (int i = 0; i < Vector<float>.Length; ++i)
			if (v [i] != i + 1)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_r8_div () {
		var elems1 = new double [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
		for (int i = 0; i < elems1.Length; ++i)
			elems1 [i] = (double)(elems1 [i] * 2);
		var v1 = new Vector<double> (elems1);
		var v2 = new Vector<double> (2);
		var v = v1 / v2;
		for (int i = 0; i < Vector<double>.Length; ++i)
			if (v [i] != i + 1)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i1_and () {
		var elems1 = new byte [16];
		for (int i = 0; i < elems1.Length; ++i)
			elems1 [i] = 0x33;
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [16];
		for (int i = 0; i < elems2.Length; ++i)
			elems2 [i] = 0xee;
		var v2 = new Vector<byte> (elems2);
		var v = v1 & v2;
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != 0x22)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i1_or () {
		var elems1 = new byte [16];
		for (int i = 0; i < elems1.Length; ++i)
			elems1 [i] = 0x33;
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [16];
		for (int i = 0; i < elems2.Length; ++i)
			elems2 [i] = 0xee;
		var v2 = new Vector<byte> (elems2);
		var v = v1 | v2;
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != 0xff)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i1_xor () {
		var elems1 = new byte [16];
		for (int i = 0; i < elems1.Length; ++i)
			elems1 [i] = 0x33;
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [16];
		for (int i = 0; i < elems2.Length; ++i)
			elems2 [i] = 0xee;
		var v2 = new Vector<byte> (elems2);
		var v = v1 ^ v2;
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != (0x33 ^ 0xee))
				return 1;
		return 0;
	}

	// FIXME: This fails without simd
	public static int test_0_vector_t_i1_and_not () {
		var elems1 = new byte [16];
		for (int i = 0; i < elems1.Length; ++i)
			elems1 [i] = 0x33;
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [16];
		for (int i = 0; i < elems2.Length; ++i)
			elems2 [i] = 0xee;
		var v2 = new Vector<byte> (elems2);
		var v = Vector<byte>.AndNot (v1, v2);
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != 0xcc)
				return 1;
		return 0;
	}

	public static int test_0_vector_t_i1_min () {
		var elems1 = new byte [16];
		for (int i = 0; i < elems1.Length; ++i)
			elems1 [i] = (byte)i;
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [16];
		for (int i = 0; i < elems2.Length; ++i)
			elems2 [i] = (byte)(i * 2);
		var v2 = new Vector<byte> (elems2);
		var v = VectorMath.Min (v1, v2);
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != i)
				return 1;
		v = VectorMath.Min (v2, v1);
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != i)
				return 2;
		return 0;
	}

	public static int test_0_vector_t_i1_max () {
		var elems1 = new byte [16];
		for (int i = 0; i < elems1.Length; ++i)
			elems1 [i] = (byte)i;
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [16];
		for (int i = 0; i < elems2.Length; ++i)
			elems2 [i] = (byte)(i * 2);
		var v2 = new Vector<byte> (elems2);
		var v = VectorMath.Max (v1, v2);
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != (i * 2))
				return 1;
		v = VectorMath.Max (v2, v1);
		for (int i = 0; i < Vector<byte>.Length; ++i)
			if (v [i] != (i * 2))
				return 2;
		return 0;
	}

	public static int test_0_vector_t_r4_equal () {
		var elems1 = new float [4] { 1.0f, 1.0f, 1.0f, 1.0f };
		var v1 = new Vector<float> (elems1);
		var elems2 = new float [4] { 1.0f, 2.0f, 1.0f, 2.0f };
		var v2 = new Vector<float> (elems2);
		Vector<int> v = Vector.Equals (v1, v2);
		if (v [0] != -1 || v [1] != 0 || v [2] != -1 || v [3] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_r8_equal () {
		var elems1 = new double [] { 1.0f, 1.0f };
		var v1 = new Vector<double> (elems1);
		var elems2 = new double [] { 1.0f, 2.0f };
		var v2 = new Vector<double> (elems2);
		Vector<long> v = Vector.Equals (v1, v2);
		if (v [0] != -1 || v [1] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_i8_equal () {
		var elems1 = new long [] { 1, 1 };
		var v1 = new Vector<long> (elems1);
		var elems2 = new long [] { 1, 2 };
		var v2 = new Vector<long> (elems2);
		Vector<long> v = Vector.Equals (v1, v2);
		if (v [0] != -1 || v [1] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_i4_equal () {
		var elems1 = new int [] { 1, 1, 1, 1 };
		var v1 = new Vector<int> (elems1);
		var elems2 = new int [] { 1, 2, 1, 2 };
		var v2 = new Vector<int> (elems2);
		Vector<int> v = Vector.Equals (v1, v2);
		if (v [0] != -1 || v [1] != 0 || v [2] != -1 || v[3] != 0)
			return 1;
		return 0;
	}

	/*
	public static int test_0_vector_t_u4_equal () {
		var elems1 = new uint [] { 1, 1, 1, 1 };
		var v1 = new Vector<uint> (elems1);
		var elems2 = new uint [] { 1, 2, 1, 2 };
		var v2 = new Vector<uint> (elems2);
		Vector<uint> v = Vector.Equals (v1, v2);
		if (v [0] != 0xffffffff || v [1] != 0 || v [2] != 0xffffffff || v[3] != 0)
			return 1;
		return 0;
	}
	*/

	public static int test_0_vector_t_i2_equal () {
		var elems1 = new short [] { 1, 1, 1, 1, 1, 1, 1, 1 };
		var v1 = new Vector<short> (elems1);
		var elems2 = new short [] { 1, 2, 1, 2, 1, 2, 1, 2 };
		var v2 = new Vector<short> (elems2);
		Vector<short> v = Vector.Equals (v1, v2);
		for (int i = 0; i < Vector<short>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_u2_equal () {
		var elems1 = new ushort [] { 1, 1, 1, 1, 1, 1, 1, 1 };
		var v1 = new Vector<ushort> (elems1);
		var elems2 = new ushort [] { 1, 2, 1, 2, 1, 2, 1, 2 };
		var v2 = new Vector<ushort> (elems2);
		Vector<ushort> v = Vector.Equals (v1, v2);
		for (int i = 0; i < Vector<ushort>.Length; ++i) {
			if (i % 2 == 0 && v [i] != 0xffff)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_i1_equal () {
		var elems1 = new sbyte [] { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };
		var v1 = new Vector<sbyte> (elems1);
		var elems2 = new sbyte [] { 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 };
		var v2 = new Vector<sbyte> (elems2);
		Vector<sbyte> v = Vector.Equals (v1, v2);
		for (int i = 0; i < Vector<sbyte>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_u1_equal () {
		var elems1 = new byte [] { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };
		var v1 = new Vector<byte> (elems1);
		var elems2 = new byte [] { 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 };
		var v2 = new Vector<byte> (elems2);
		Vector<byte> v = Vector.Equals (v1, v2);
		for (int i = 0; i < Vector<byte>.Length; ++i) {
			if (i % 2 == 0 && v [i] != 0xff)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	/* Vector.GreaterThan () */

	public static int test_0_vector_t_i8_gt () {
		var elems1 = new long [] { 1, 1 };
		var v1 = new Vector<long> (elems1);
		var elems2 = new long [] { 0, 1 };
		var v2 = new Vector<long> (elems2);
		Vector<long> v = Vector.GreaterThan (v1, v2);
		if (v [0] != -1 || v [1] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_i4_gt () {
		var elems1 = new int [] { 1, 1, 1, 1 };
		var v1 = new Vector<int> (elems1);
		var elems2 = new int [] { 0, 1, 0, 1 };
		var v2 = new Vector<int> (elems2);
		Vector<int> v = Vector.GreaterThan (v1, v2);
		if (v [0] != -1 || v [1] != 0 || v [2] != -1 || v[3] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_i2_gt () {
		var elems1 = new short [] { 1, 1, 1, 1, 1, 1, 1, 1 };
		var v1 = new Vector<short> (elems1);
		var elems2 = new short [] { 0, 1, 0, 1, 0, 1, 0, 1 };
		var v2 = new Vector<short> (elems2);
		Vector<short> v = Vector.GreaterThan (v1, v2);
		for (int i = 0; i < Vector<short>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_i1_gt () {
		var elems1 = new sbyte [] { 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };
		var v1 = new Vector<sbyte> (elems1);
		var elems2 = new sbyte [] { 0, 1, -1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 };
		var v2 = new Vector<sbyte> (elems2);
		Vector<sbyte> v = Vector.GreaterThan (v1, v2);
		for (int i = 0; i < Vector<sbyte>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	/* Vector.GreaterThanOrEqual */

	public static int test_0_vector_t_i1_ge () {
		var elems1 = new sbyte [] { 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1 };
		var v1 = new Vector<sbyte> (elems1);
		var elems2 = new sbyte [] { 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 };
		var v2 = new Vector<sbyte> (elems2);
		Vector<sbyte> v = Vector.GreaterThanOrEqual (v1, v2);
		for (int i = 0; i < Vector<sbyte>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_i2_ge () {
		var elems1 = new short [] { 1, 1, 0, 1, 1, 1, 0, 1 };
		var v1 = new Vector<short> (elems1);
		var elems2 = new short [] { 0, 2, 0, 2, 0, 2, 0, 2 };
		var v2 = new Vector<short> (elems2);
		Vector<short> v = Vector.GreaterThanOrEqual (v1, v2);
		for (int i = 0; i < Vector<short>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_i4_ge () {
		var elems1 = new int [] { 1, 1, 0, 1 };
		var v1 = new Vector<int> (elems1);
		var elems2 = new int [] { 0, 2, 0, 2 };
		var v2 = new Vector<int> (elems2);
		Vector<int> v = Vector.GreaterThanOrEqual (v1, v2);
		if (v [0] != -1 || v [1] != 0 || v [2] != -1 || v[3] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_i8_ge () {
		var elems1 = new long [] { 1, 1 };
		var v1 = new Vector<long> (elems1);
		var elems2 = new long [] { 0, 1 };
		var v2 = new Vector<long> (elems2);
		Vector<long> v = Vector.GreaterThanOrEqual (v1, v2);
		if (v [0] != -1 || v [1] != -1)
			return 1;
		return 0;
	}

	/* Vector.LessThan */

	public static int test_0_vector_t_i8_lt () {
		var elems1 = new long [] { 1, 1 };
		var v1 = new Vector<long> (elems1);
		var elems2 = new long [] { 0, 1 };
		var v2 = new Vector<long> (elems2);
		Vector<long> v = Vector.LessThan (v2, v1);
		if (v [0] != -1 || v [1] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_i4_lt () {
		var elems1 = new int [] { 1, 1, 1, 1 };
		var v1 = new Vector<int> (elems1);
		var elems2 = new int [] { 0, 1, 0, 1 };
		var v2 = new Vector<int> (elems2);
		Vector<int> v = Vector.LessThan (v2, v1);
		if (v [0] != -1 || v [1] != 0 || v [2] != -1 || v[3] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_i2_lt () {
		var elems1 = new short [] { 1, 1, 1, 1, 1, 1, 1, 1 };
		var v1 = new Vector<short> (elems1);
		var elems2 = new short [] { 0, 1, 0, 1, 0, 1, 0, 1 };
		var v2 = new Vector<short> (elems2);
		Vector<short> v = Vector.LessThan (v2, v1);
		for (int i = 0; i < Vector<short>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_i1_lt () {
		var elems1 = new sbyte [] { 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };
		var v1 = new Vector<sbyte> (elems1);
		var elems2 = new sbyte [] { 0, 1, -1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 };
		var v2 = new Vector<sbyte> (elems2);
		Vector<sbyte> v = Vector.LessThan (v2, v1);
		for (int i = 0; i < Vector<sbyte>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	/* Vector.LessThanOrEqual */

	public static int test_0_vector_t_i1_le () {
		var elems1 = new sbyte [] { 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1 };
		var v1 = new Vector<sbyte> (elems1);
		var elems2 = new sbyte [] { 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 };
		var v2 = new Vector<sbyte> (elems2);
		Vector<sbyte> v = Vector.GreaterThanOrEqual (v1, v2);
		for (int i = 0; i < Vector<sbyte>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_i2_le () {
		var elems1 = new short [] { 1, 1, 0, 1, 1, 1, 0, 1 };
		var v1 = new Vector<short> (elems1);
		var elems2 = new short [] { 0, 2, 0, 2, 0, 2, 0, 2 };
		var v2 = new Vector<short> (elems2);
		Vector<short> v = Vector.GreaterThanOrEqual (v1, v2);
		for (int i = 0; i < Vector<short>.Length; ++i) {
			if (i % 2 == 0 && v [i] != -1)
				return 1;
			if (i % 2 == 1 && v [i] != 0)
				return 1;
		}
		return 0;
	}

	public static int test_0_vector_t_i4_le () {
		var elems1 = new int [] { 1, 1, 0, 1 };
		var v1 = new Vector<int> (elems1);
		var elems2 = new int [] { 0, 2, 0, 2 };
		var v2 = new Vector<int> (elems2);
		Vector<int> v = Vector.GreaterThanOrEqual (v1, v2);
		if (v [0] != -1 || v [1] != 0 || v [2] != -1 || v[3] != 0)
			return 1;
		return 0;
	}

	public static int test_0_vector_t_i8_le () {
		var elems1 = new long [] { 1, 1 };
		var v1 = new Vector<long> (elems1);
		var elems2 = new long [] { 0, 1 };
		var v2 = new Vector<long> (elems2);
		Vector<long> v = Vector.GreaterThanOrEqual (v1, v2);
		if (v [0] != -1 || v [1] != -1)
			return 1;
		return 0;
	}

	/* op_Explicit () -> Vector<int32> */

	public static int test_0_vector_t_cast_vector_int32 () {
		var v1 = new Vector<long> (new long [] { 0x123456789abcdef0L, 0x23456789abcdef01L });
		var v = (Vector<int>)v1;
		if ((uint)v [0] != 0x9abcdef0 || (uint)v [1] != 0x12345678)
			return 1;
		if ((uint)v [2] != 0xabcdef01 || (uint)v [3] != 0x23456789)
			return 2;
		return 0;
	}

	/* CopyTo */

	public static int test_0_vector_t_i1_copyto () {
		var elems = new byte [] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
								  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 };
		var v = new Vector<byte> (elems, 16);
		var elems2 = new byte [17];
		v.CopyTo (elems2);
		for (int i = 0; i < 16; ++i)
			if (elems2 [i] != i)
				return 1;
		v.CopyTo (elems2, 1);
		for (int i = 0; i < 16; ++i)
			if (elems2 [i + 1] != i)
				return 1;
		/* FIXME: The simd and non-simd versions throw different exceptions
		try {
			v.CopyTo (elems2, 1);
			return 2;
		} catch (ArgumentException) {
		}
		*/
		return 0;
	}

}
