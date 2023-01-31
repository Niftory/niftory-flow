import { flow, pipe, z } from "#"
import { Zod } from "./zod"

const STRING_TYPE = Symbol("STRING_TYPE")

type Hex = {
  [STRING_TYPE]: "hex"
  value: string
}

type Base64 = {
  [STRING_TYPE]: "base64"
  value: string
}

type Utf8 = string | Buffer

type StringLike = Hex | Base64 | Utf8

const foldStringLike =
  <T, U, V>(
    hex: (hex: Hex) => T,
    base64: (base64: Base64) => U,
    utf8: (utf8: Utf8) => V,
  ) =>
  (str: StringLike): T | U | V => {
    if (typeof str === "string") {
      return utf8(str)
    }
    if (Buffer.isBuffer(str)) {
      return utf8(str)
    }
    if (str[STRING_TYPE] === "hex") {
      return hex(str)
    }
    if (str[STRING_TYPE] === "base64") {
      return base64(str)
    }
    throw new Error(`Invalid StringLike: ${str}`)
  }

const HexZod = z
  .string()
  .regex(/^(0x)?[0-9a-fA-F]+$/)
  .transform(trimLeading("0x"))
const parseHex = Zod.prettyParser(HexZod)
// const hex = (value: unkn)

const StringUtils = {}
