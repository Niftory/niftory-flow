import { flow, z } from "#"

// Parsers
const parser =
  <A>(genericParse: (_: unknown) => A) =>
  (str: string) =>
    genericParse(str)

const AnyString = z.string()
const parseAny = AnyString.parse

const DecimalString = z.string().regex(/^([0-9]+)$/)
const parseDecimal = parser(DecimalString.parse)

const HexString = z.string().regex(/^([0-9a-fA-F]{2})+$/)
const parseHex = parser(HexString.parse)

const Base64String = z
  .string()
  .regex(/^([0-9a-zA-Z+/]{4})*(([0-9a-zA-Z+/]{2}==)|([0-9a-zA-Z+/]{3}=))?$/)
const parseBase64 = parser(Base64String.parse)

// String replacements
const trimTrailing = (trailing: string) => (str: string) =>
  str.endsWith(trailing) ? str.slice(0, -trailing.length) : str

const trimLeading = (leading: string) => (str: string) =>
  str.startsWith(leading) ? str.slice(leading.length) : str

const prependLeading = (leading: string, allow?: string[]) => (str: string) => {
  const toCheck = (allow ?? []).concat(leading)
  return toCheck.some(str.startsWith) ? str : leading + str
}

const appendTrailing =
  (trailing: string, allow?: string[]) => (str: string) => {
    const toCheck = (allow ?? []).concat(trailing)
    return toCheck.some(str.endsWith) ? str : str + trailing
  }

const trimTrailingSlash = trimTrailing("/")

const addLeadingSlash = prependLeading("/")

const replaceAll = (search: string, replace: string) => (str: string) =>
  str.split(search).join(replace)

const replaceAllRegex = (search: RegExp, replace: string) => (str: string) =>
  str.replace(search, replace)

// IntLike conversions
const toBigInt = flow(parseDecimal, DecimalString.parse, BigInt)

const toNumber = flow(toBigInt, Number)

// Buffer conversions
const fromHexToBuffer = (hex: string) => Buffer.from(parseHex(hex), "hex")

const fromBase64ToBuffer = (base64: string) =>
  Buffer.from(parseBase64(base64), "base64")

const fromUtf8ToBuffer = (utf8: string) => Buffer.from(utf8, "utf8")

const StringUtil = {
  trimLeading,
  trimTrailing,
  prependLeading,
  appendTrailing,
  trimTrailingSlash,
  addLeadingSlash,
  replaceAll,
  replaceAllRegex,
  parseAny,
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
