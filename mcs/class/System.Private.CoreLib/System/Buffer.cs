using System.Runtime;
using System.Runtime.CompilerServices;
using Internal.Runtime.CompilerServices;

#if BIT64
using nuint = System.UInt64;
#else
using nuint = System.UInt32;
#endif

namespace System
{
	partial class Buffer
	{
		public static void BlockCopy (Array src, int srcOffset, Array dst, int dstOffset, int count)
		{
			if (src == null)
				throw new ArgumentNullException (nameof (src));
			if (dst == null)
				throw new ArgumentNullException (nameof (dst));

			if (srcOffset < 0)
				throw new ArgumentOutOfRangeException (SR.ArgumentOutOfRange_MustBeNonNegInt32, nameof (srcOffset));
			if (dstOffset < 0)
				throw new ArgumentOutOfRangeException (SR.ArgumentOutOfRange_MustBeNonNegInt32, nameof (dstOffset));
			if (count < 0)
				throw new ArgumentOutOfRangeException (SR.ArgumentOutOfRange_MustBeNonNegInt32, nameof (count));

			var uCount = (nuint) count;
			var uSrcOffset = (nuint) srcOffset;
			var uDstOffset = (nuint) dstOffset;

			var uSrcLen = (nuint) src.Length;
			var uDstLen = (nuint) dst.Length;

			if (uSrcLen < uSrcOffset + uCount)
				throw new ArgumentException (SR.Argument_InvalidOffLen);
			if (uDstLen < uDstOffset + uCount)
				throw new ArgumentException (SR.Argument_InvalidOffLen);

			if (uCount != 0) {
				unsafe {
					fixed (byte* pSrc = &src.GetRawArrayData (), pDst = &dst.GetRawArrayData ()) {
						Memmove (pDst + uDstOffset, pSrc + uSrcOffset, uCount);
					}
				}
			}
		}

		[MethodImplAttribute (MethodImplOptions.InternalCall)]
		static extern int _ByteLength (Array array);

		static bool IsPrimitiveTypeArray (Array array)
		{
			return array.GetType ().GetElementType ().IsPrimitive;
		}

		internal static unsafe void Memcpy (byte* dest, byte* src, int len) => Memmove (dest, src, (nuint) len);

		[MethodImpl (MethodImplOptions.InternalCall)]
		static extern unsafe void __Memmove (byte* dest, byte* src, nuint len);
	}
}