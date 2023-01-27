import { Util } from "#"
import { z } from "zod"
import { Codec } from "./base"

type IntSize = 8 | 16 | 32 | 64 | 128 | 256

const XIntN = (
  n: IntSize | null,
  signed: boolean,
): Codec<bigint, Util.IntLike> => {
  const U = signed ? "" : "U"
  const N = n ?? ""
  const encode = (a: Util.IntLike) => ({
    type: `${U}Int${N}`,
    value: Util.IntLike.asString(a),
  })

  const decoder = z.object({
    type: z.literal(`${U}Int${N}`),
    value: z.string(),
  })

  const decode = (a: any) =>
    decoder.transform((a) => Util.IntLike.asBigInt(a.value)).parse(a)

  return {
    encode,
    decode,
    decoder,
  }
}

const Int = XIntN(null, true)
const Int8 = XIntN(8, true)
const Int16 = XIntN(16, true)
const Int32 = XIntN(32, true)
const Int64 = XIntN(64, true)
const Int128 = XIntN(128, true)
const Int256 = XIntN(256, true)

const UInt = XIntN(null, false)
const UInt8 = XIntN(8, false)
const UInt16 = XIntN(16, false)
const UInt32 = XIntN(32, false)
const UInt64 = XIntN(64, false)
const UInt128 = XIntN(128, false)
const UInt256 = XIntN(256, false)

export {
  Int,
  Int8,
  Int16,
  Int32,
  Int64,
  Int128,
  Int256,
  UInt,
  UInt8,
  UInt16,
  UInt32,
  UInt64,
  UInt128,
  UInt256,
}
