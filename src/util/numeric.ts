import { pipe } from "#"
import { BufferUtil } from "./buffer"
import { StringUtil } from "./string"

// Any string mentioned here should be base 10
type DecimalString = string

type Numeric = DecimalString | number | bigint | Buffer

const fromNumberToBuffer = (n: number): Buffer =>
  Buffer.from(n.toString(16), "hex")

const fromBigIntToBuffer = (n: bigint): Buffer =>
  Buffer.from(n.toString(16), "hex")

const asString = (n: Numeric): string => {
  if (typeof n === "string") return StringUtil.parseDecimal(n)
  if (typeof n === "number") return n.toString()
  if (typeof n === "bigint") return n.toString()
  if (Buffer.isBuffer(n)) return BufferUtil.toBigInt(n).toString()
  throw new Error(`Invalid numeric type: ${n}`)
}

const asNumber = (n: Numeric): number => {
  if (typeof n === "string") return StringUtil.toNumber(n)
  if (typeof n === "number") return n
  if (typeof n === "bigint") return Number(n)
  if (Buffer.isBuffer(n)) return BufferUtil.toNumber(n)
  throw new Error(`Invalid numeric type: ${n}`)
}

const asBigInt = (n: Numeric): bigint => {
  if (typeof n === "string") return BigInt(n)
  if (typeof n === "number") return BigInt(n)
  if (typeof n === "bigint") return n
  if (Buffer.isBuffer(n)) return BufferUtil.toBigInt(n)
  throw new Error(`Invalid numeric type: ${n}`)
}

const asBuffer = (n: Numeric): Buffer => {
  if (typeof n === "string")
    return pipe(n, StringUtil.toBigInt, fromBigIntToBuffer)
  if (typeof n === "number") return fromNumberToBuffer(n)
  if (typeof n === "bigint") return fromBigIntToBuffer(n)
  if (Buffer.isBuffer(n)) return n
  throw new Error(`Invalid numeric type: ${n}`)
}

const NumericUtil = {
  asString,
  asNumber,
  asBigInt,
  asBuffer,
}

export { NumericUtil, Numeric }
