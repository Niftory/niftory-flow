import { pipe } from "#"
import { BufferUtil } from "./buffer"
import { StringUtil } from "./string"

// Any string mentioned here should be base 10
type DecimalString = string

type IntLike = DecimalString | number | bigint | Buffer

const fromNumberToBuffer = (n: number): Buffer =>
  Buffer.from(n.toString(16), "hex")

const fromBigIntToBuffer = (n: bigint): Buffer =>
  Buffer.from(n.toString(16), "hex")

const asString = (n: IntLike): string => {
  if (typeof n === "string") return StringUtil.parseDecimal(n)
  if (typeof n === "number") return n.toString()
  if (typeof n === "bigint") return n.toString()
  if (Buffer.isBuffer(n)) return BufferUtil.toBigInt(n).toString()
  throw new Error(`Invalid IntLike type: ${n}`)
}

const asNumber = (n: IntLike): number => {
  if (typeof n === "string") return StringUtil.toNumber(n)
  if (typeof n === "number") return n
  if (typeof n === "bigint") return Number(n)
  if (Buffer.isBuffer(n)) return BufferUtil.toNumber(n)
  throw new Error(`Invalid IntLike type: ${n}`)
}

const asBigInt = (n: IntLike): bigint => {
  if (typeof n === "string") return BigInt(n)
  if (typeof n === "number") return BigInt(n)
  if (typeof n === "bigint") return n
  if (Buffer.isBuffer(n)) return BufferUtil.toBigInt(n)
  throw new Error(`Invalid IntLike type: ${n}`)
}

const asBuffer = (n: IntLike): Buffer => {
  if (typeof n === "string")
    return pipe(n, StringUtil.toBigInt, fromBigIntToBuffer)
  if (typeof n === "number") return fromNumberToBuffer(n)
  if (typeof n === "bigint") return fromBigIntToBuffer(n)
  if (Buffer.isBuffer(n)) return n
  throw new Error(`Invalid IntLike type: ${n}`)
}

const IntLikeUtil = {
  asString,
  asNumber,
  asBigInt,
  asBuffer,
}

export { IntLikeUtil, IntLike }
