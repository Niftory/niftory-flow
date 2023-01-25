import { flow, z } from "#"

// Parsers
const parser =
  <A>(genericParse: (_: unknown) => A) =>
  (str: string) =>
    genericParse(str)

const DecimalString = z.string().regex(/^([0-9]+)$/)
const parseDecimal = parser(DecimalString.parse)

const HexString = z.string().regex(/^([0-9a-fA-F]{2})+$/)
const parseHex = parser(HexString.parse)

const Base64String = z
  .string()
  .regex(/^([0-9a-zA-Z+/]{4})*(([0-9a-zA-Z+/]{2}==)|([0-9a-zA-Z+/]{3}=))?$/)
const parseBase64 = parser(Base64String.parse)

// String replacements
const trimTrailingSlash = (str: string) =>
  str.endsWith("/") ? str.slice(0, -1) : str

const addLeadingSlash = (str: string) => (str.startsWith("/") ? str : "/" + str)

const replaceAll = (search: string, replace: string) => (str: string) =>
  str.split(search).join(replace)

const replaceAllRegex = (search: RegExp, replace: string) => (str: string) =>
  str.replace(search, replace)

// Numeric conversions
const toBigInt = flow(parseDecimal, DecimalString.parse, BigInt)

const toNumber = flow(toBigInt, Number)

// Buffer conversions
const fromHexToBuffer = (hex: string) => Buffer.from(parseHex(hex), "hex")

const fromBase64ToBuffer = (base64: string) =>
  Buffer.from(parseBase64(base64), "base64")

const fromUtf8ToBuffer = (utf8: string) => Buffer.from(utf8, "utf8")

const StringUtil = {
  trimTrailingSlash,
  addLeadingSlash,
  replaceAll,
  replaceAllRegex,
  parseDecimal,
  parseBase64,
  parseHex,
  toBigInt,
  toNumber,
  fromHexToBuffer,
  fromBase64ToBuffer,
  fromUtf8ToBuffer,
}

export { StringUtil }
