import { ff, flow, pipe, z } from "#"
import { FunctionUtils } from "./function"
import { Zod } from "./zod"

const { log } = FunctionUtils

export function debug<T>(value: T, message?: string): T {
  console.log(`${message ?? ""}` + JSON.stringify(value, null, 2))
  return value
}

type Utf8 = string

type Hex = {
  readonly _tag: "hex"
  readonly value: string
}

const _hex = (value: string) =>
  ({
    _tag: "hex" as const,
    value,
  } as Hex)

const HexZod = z
  .string()
  .regex(/^(0x)?[0-9a-fA-F]+$/)
  .transform((str) => str.replace(/^0x/, ""))

const parseHex = flow(Zod.prettyParser(HexZod), _hex)

const isHex = (hex: unknown): hex is Hex =>
  typeof hex == "object" &&
  hex !== null &&
  "value" in hex &&
  "_tag" in hex &&
  hex._tag === "hex"

type Base64 = {
  readonly _tag: "base64"
  readonly value: string
}

const _base64 = (value: string) =>
  ({
    _tag: "base64" as const,
    value,
  } as Base64)

const Base64Zod = z
  .string()
  .regex(/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/)

const parseBase64 = flow(Zod.prettyParser(Base64Zod), _base64)

const isBase64 = (base64: unknown): base64 is Base64 =>
  typeof base64 == "object" &&
  base64 !== null &&
  "value" in base64 &&
  "_tag" in base64 &&
  base64._tag === "base64"

type BufferLike = Buffer | Utf8 | bigint | Hex | Base64

type BufferLikeFunctionResult<T extends BufferLike> = T extends Buffer
  ? Buffer
  : T extends Utf8
  ? Utf8
  : T extends bigint
  ? bigint
  : T extends Hex
  ? Hex
  : T extends Base64
  ? Base64
  : never

const toString = (bufferLike: BufferLike): string => {
  if (Buffer.isBuffer(bufferLike)) {
    return bufferLike.toString("hex")
  }
  if (typeof bufferLike === "string") {
    return bufferLike
  }
  if (typeof bufferLike === "bigint") {
    return bufferLike.toString()
  }
  if (isHex(bufferLike)) {
    return bufferLike.value
  }
  if (isBase64(bufferLike)) {
    return bufferLike.value
  }
  throw new Error(`Invalid BufferLike: ${bufferLike}`)
}

const buffer = (bufferLike: BufferLike): Buffer => {
  if (Buffer.isBuffer(bufferLike)) {
    return bufferLike
  }
  if (typeof bufferLike === "string") {
    return Buffer.from(bufferLike, "utf8")
  }
  if (typeof bufferLike === "bigint") {
    return debug(Buffer.from(bufferLike.toString(16), "hex"))
  }
  if (isHex(bufferLike)) {
    return Buffer.from(bufferLike.value, "hex")
  }
  if (isBase64(bufferLike)) {
    return Buffer.from(bufferLike.value, "base64")
  }
  throw new Error(`Invalid BufferLike: ${bufferLike}`)
}

const utf8 = (bufferLike: BufferLike): Utf8 =>
  typeof bufferLike === "string"
    ? bufferLike
    : buffer(bufferLike).toString("utf8")

const hex = (bufferLike: BufferLike): Hex =>
  isHex(bufferLike) ? bufferLike : _hex(buffer(bufferLike).toString("hex"))

const base64 = (bufferLike: BufferLike): Base64 =>
  isBase64(bufferLike)
    ? bufferLike
    : _base64(buffer(bufferLike).toString("base64"))

const int = (bufferLike: BufferLike): bigint =>
  typeof bufferLike === "bigint"
    ? bufferLike
    : BigInt("0x0" + buffer(bufferLike).toString("hex"))

type BufferLikeTransformerOverrides = {
  buffer?: (_: Buffer) => BufferLike
  utf8?: (_: string) => BufferLike
  hex?: (_: Hex) => BufferLike
  base64?: (_: Base64) => BufferLike
  int?: (_: bigint) => BufferLike
}

const createBufferLikeTransformer =
  <T extends BufferLike>(
    convert: (_: BufferLike) => T,
    fn: (_: T) => BufferLike,
    overrides?: BufferLikeTransformerOverrides,
  ) =>
  <U extends BufferLike>(bufferLike: U): BufferLikeFunctionResult<U> => {
    const getDefaultResult = () => pipe(bufferLike, convert, fn)
    if (Buffer.isBuffer(bufferLike)) {
      return buffer(
        overrides?.buffer !== undefined
          ? overrides.buffer(bufferLike)
          : getDefaultResult(),
      ) as BufferLikeFunctionResult<U>
    }
    if (typeof bufferLike === "string") {
      return utf8(
        overrides?.utf8 !== undefined
          ? overrides.utf8(bufferLike)
          : getDefaultResult(),
      ) as BufferLikeFunctionResult<U>
    }
    if (typeof bufferLike === "bigint") {
      return int(
        overrides?.int !== undefined
          ? overrides.int(bufferLike)
          : getDefaultResult(),
      ) as BufferLikeFunctionResult<U>
    }
    if (isHex(bufferLike)) {
      return hex(
        overrides?.hex !== undefined
          ? overrides.hex(bufferLike)
          : getDefaultResult(),
      ) as BufferLikeFunctionResult<U>
    }
    if (isBase64(bufferLike)) {
      return base64(
        overrides?.base64 !== undefined
          ? overrides.base64(bufferLike)
          : getDefaultResult(),
      ) as BufferLikeFunctionResult<U>
    }
    throw new Error(`Invalid BufferLike: ${bufferLike}`)
  }

type BufferLikeReducerOverrides<T> = {
  buffer?: (_: Buffer) => T
  utf8?: (_: string) => T
  hex?: (_: Hex) => T
  base64?: (_: Base64) => T
  int?: (_: bigint) => T
}

const createBufferLikeReducer =
  <T extends BufferLike, V>(
    convert: (_: BufferLike) => T,
    fn: (_: T) => V,
    overrides?: BufferLikeReducerOverrides<V>,
  ) =>
  <U extends BufferLike>(bufferLike: U): V => {
    const getDefaultResult = () => pipe(bufferLike, convert, fn)
    if (Buffer.isBuffer(bufferLike)) {
      return overrides?.buffer !== undefined
        ? overrides.buffer(bufferLike)
        : getDefaultResult()
    }
    if (typeof bufferLike === "string") {
      return overrides?.utf8 !== undefined
        ? overrides.utf8(bufferLike)
        : getDefaultResult()
    }
    if (typeof bufferLike === "bigint") {
      return overrides?.int !== undefined
        ? overrides.int(bufferLike)
        : getDefaultResult()
    }
    if (isHex(bufferLike)) {
      return overrides?.hex !== undefined
        ? overrides.hex(bufferLike)
        : getDefaultResult()
    }
    if (isBase64(bufferLike)) {
      return overrides?.base64 !== undefined
        ? overrides.base64(bufferLike)
        : getDefaultResult()
    }
    throw new Error(`Invalid BufferLike: ${bufferLike}`)
  }

const _bufferStartsWith = (prefix: Buffer, input: Buffer) =>
  input.length >= prefix.length && input.slice(0, prefix.length).equals(prefix)

const _strStartsWith = (prefix: string, input: string) =>
  input.startsWith(prefix)

const startsWith = (prefix: BufferLike) =>
  createBufferLikeReducer(
    buffer,
    (input) => _bufferStartsWith(buffer(prefix), input),
    {
      utf8: (input) => _strStartsWith(utf8(prefix), input),
      hex: (input) => _strStartsWith(hex(prefix).value, input.value),
    },
  )

const _bufferEndsWith = (suffix: Buffer, input: Buffer) =>
  input.length >= suffix.length &&
  input.slice(input.length - suffix.length).equals(suffix)

const _strEndsWith = (suffix: string, input: string) => input.endsWith(suffix)

const endsWith = (suffix: BufferLike) =>
  createBufferLikeReducer(
    buffer,
    (input) => _bufferEndsWith(buffer(suffix), input),
    {
      utf8: (input) => _strEndsWith(utf8(suffix), input),
      hex: (input) => _strEndsWith(hex(suffix).value, input.value),
    },
  )

const _bufferIncludes = (needle: Buffer, input: Buffer) =>
  input.includes(needle)

const _strIncludes = (needle: string, input: string) => input.includes(needle)

const includes = (needle: BufferLike) =>
  createBufferLikeReducer(
    buffer,
    (input) => _bufferIncludes(buffer(needle), input),
    {
      utf8: (input) => _strIncludes(utf8(needle), input),
      hex: (input) => _strIncludes(hex(needle).value, input.value),
    },
  )

const _bufferIndexOf = (needle: Buffer, input: Buffer) => input.indexOf(needle)

const _strIndexOf = (needle: string, input: string) => input.indexOf(needle)

const indexOf = (needle: BufferLike) =>
  createBufferLikeReducer(
    buffer,
    (input) => _bufferIndexOf(buffer(needle), input),
    {
      utf8: (input) => _strIndexOf(utf8(needle), input),
      hex: (input) => _strIndexOf(hex(needle).value, input.value),
    },
  )

const replaceAll = (search: RegExp, replace: BufferLike) =>
  createBufferLikeTransformer(utf8, (input) =>
    input.replaceAll(search, utf8(replace)),
  )

const matchAll = (search: RegExp) =>
  createBufferLikeReducer(utf8, (input) => input.matchAll(search))

const test = (search: RegExp) =>
  createBufferLikeReducer(utf8, (input) => search.test(input))

const split = (separator: RegExp | string) =>
  createBufferLikeReducer(utf8, (input) => input.split(separator))

const slice = (start: number, end?: number) =>
  createBufferLikeTransformer(buffer, (input) => input.slice(start, end), {
    utf8: (input) => input.slice(start, end),
    hex: (input) =>
      _hex(input.value.slice(start * 2, end ? end * 2 : undefined)),
  })

const repeat = (count: number) =>
  createBufferLikeTransformer(
    buffer,
    (input) => {
      const result = Buffer.alloc(input.length * count)
      for (let i = 0; i < count; i++) {
        input.copy(result, i * input.length)
      }
      return result
    },
    {
      utf8: (input) => input.repeat(count),
      hex: (input) => _hex(input.value.repeat(count)),
    },
  )

const trimLeading = (leading: BufferLike) =>
  createBufferLikeTransformer(
    buffer,
    (input) =>
      startsWith(leading)(input) ? input.slice(buffer(leading).length) : input,
    {
      utf8: (input) =>
        startsWith(leading)(input) ? input.slice(utf8(leading).length) : input,
      hex: (input) =>
        startsWith(leading)(input)
          ? _hex(input.value.slice(hex(leading).value.length))
          : input,
    },
  )

const trimTrailing = (trailing: BufferLike) =>
  createBufferLikeTransformer(
    buffer,
    (input) =>
      endsWith(trailing)(input)
        ? input.slice(0, input.length - buffer(trailing).length)
        : input,
    {
      utf8: (input) =>
        endsWith(trailing)(input)
          ? input.slice(0, input.length - utf8(trailing).length)
          : input,
      hex: (input) =>
        endsWith(trailing)(input)
          ? _hex(
              input.value.slice(
                0,
                input.value.length - hex(trailing).value.length,
              ),
            )
          : input,
    },
  )

const _strPrependLeading =
  (leading: string, allow?: string[]) => (str: string) => {
    const toCheck = (allow ?? []).concat(leading)
    return toCheck.some((s) => startsWith(s)(str)) ? str : leading + str
  }

const _bufferPrependLeading =
  (leading: Buffer, allow?: Buffer[]) => (buf: Buffer) => {
    const toCheck = (allow ?? []).concat(leading)
    return toCheck.some((b) => startsWith(b)(buf))
      ? buf
      : Buffer.concat([leading, buf])
  }

const prependLeading = (leading: BufferLike, allow?: BufferLike[]) =>
  createBufferLikeTransformer(
    buffer,
    _bufferPrependLeading(buffer(leading), (allow ?? []).map(buffer)),
    {
      utf8: _strPrependLeading(utf8(leading), (allow ?? []).map(utf8)),
      hex: flow(
        (h) => h.value,
        _strPrependLeading(
          hex(leading).value,
          (allow ?? []).map((x) => hex(x).value),
        ),
        _hex,
      ),
    },
  )

const _strAppendTrailing =
  (trailing: string, allow?: string[]) => (str: string) => {
    const toCheck = (allow ?? []).concat(trailing)
    return toCheck.some((s) => endsWith(s)(str)) ? str : str + trailing
  }

const _bufferAppendTrailing =
  (trailing: Buffer, allow?: Buffer[]) => (buf: Buffer) => {
    const toCheck = (allow ?? []).concat(trailing)
    return toCheck.some((b) => endsWith(b)(buf))
      ? buf
      : Buffer.concat([buf, trailing])
  }

const appendTrailing = (trailing: BufferLike, allow?: BufferLike[]) =>
  createBufferLikeTransformer(
    buffer,
    _bufferAppendTrailing(buffer(trailing), (allow ?? []).map(buffer)),
    {
      utf8: _strAppendTrailing(utf8(trailing), (allow ?? []).map(utf8)),
      hex: flow(
        (h) => h.value,
        _strAppendTrailing(
          hex(trailing).value,
          (allow ?? []).map((x) => hex(x).value),
        ),
        _hex,
      ),
    },
  )

const truncate = (length: number) =>
  createBufferLikeTransformer(buffer, (input) => input.slice(0, length), {
    utf8: (input) => input.slice(0, length),
    hex: (input) => _hex(input.value.slice(0, length * 2)),
  })

const truncateLeft = (length: number) =>
  createBufferLikeTransformer(buffer, (input) => input.slice(-length), {
    utf8: (input) => input.slice(-length),
    hex: (input) => _hex(input.value.slice(-length * 2)),
  })

const padLeft = (length: number, pad: BufferLike) =>
  createBufferLikeTransformer(buffer, (input) => {
    const padBuffer = buffer(pad)
    const padLength = padBuffer.length
    const padCount = Math.ceil(Math.max(length - input.length, 0) / padLength)
    const padBufferRepeated = Buffer.alloc(padLength * padCount)
    for (let i = 0; i < padCount; i++) {
      padBuffer.copy(padBufferRepeated, i * padLength)
    }
    return Buffer.concat([padBufferRepeated, input]).slice(
      -Math.max(length, input.length),
    )
  })

const padRight = (length: number, pad: BufferLike) =>
  createBufferLikeTransformer(buffer, (input) => {
    const padBuffer = buffer(pad)
    const padLength = padBuffer.length
    const padCount = Math.ceil(Math.max(length - input.length, 0) / padLength)
    const padBufferRepeated = Buffer.alloc(padLength * padCount)
    for (let i = 0; i < padCount; i++) {
      padBuffer.copy(padBufferRepeated, i * padLength)
    }
    return Buffer.concat([input, padBufferRepeated]).slice(
      0,
      Math.max(length, input.length),
    )
  })

const add = (a: BufferLike) =>
  createBufferLikeTransformer(int, (b) => int(a) + b)

const multiply = (a: BufferLike) =>
  createBufferLikeTransformer(int, (b) => int(a) * b)

const subtract = (b: BufferLike) =>
  createBufferLikeTransformer(int, (a) => a - int(b))

const divide = (b: BufferLike) =>
  createBufferLikeTransformer(int, (a) => a / int(b))

const mod = (b: BufferLike) =>
  createBufferLikeTransformer(int, (a) => a % int(b))

const negate = createBufferLikeTransformer(int, (a) => -a)

const BufferLikeUtils = {
  parseHex,
  isHex,
  parseBase64,
  isBase64,
  toString,
  buffer,
  utf8,
  hex,
  base64,
  int,
  startsWith,
  endsWith,
  includes,
  indexOf,
  replaceAll,
  matchAll,
  test,
  split,
  slice,
  repeat,
  trimLeading,
  trimTrailing,
  prependLeading,
  appendTrailing,
  truncate,
  truncateLeft,
  padLeft,
  padRight,
  add,
  multiply,
  subtract,
  divide,
}

export { BufferLikeUtils }

const test2 = flow(
  replaceAll(/o/g, "0"),
  buffer,
  replaceAll(/H/g, "h"),
  hex,
  replaceAll(/l/g, parseHex("0x69")),
  slice(0, 8),
  repeat(3),
  buffer,
)

const test2part2 = flow(
  test2,
  repeat(10),
  utf8,
  truncate(32),
  log,
  truncate(29),
  utf8,
  log,
  truncate(24),
)

const test2part3 = flow(
  test2part2,
  log,
  truncate(500),
  hex,
  appendTrailing(parseHex("0x12ABDF31")),
  truncateLeft(4),
  padLeft(8, parseHex("0x00")),
  log,
  padRight(12, "lfkfdf"),
)

const test2part4 = flow(
  test2part3,
  log,
  padRight(3, "lfkfdf"),
  truncateLeft(2),
  int,
  log,
  add(BigInt(100)),
  add(parseHex("0x12ABDF31")),
)

const test2part5 = flow(
  test2part4,
  log,
  divide(BigInt(10000)),
  log,
  subtract(parseHex("0x003213")),
  base64,
  log,
  int,
  divide(50n),
)

const test2part6 = flow(
  test2part5, //
  log,
  negate,
  log,
  negate,
)

const test2part7 = ff(
  test2part6, //
  negate,
  negate,
  negate,
  negate,
  negate,
  negate,
  base64,
  negate,
  negate,
  negate,
  negate,
)

console.log(`=========\n` + toString(test2part7("Hello World")))

console.log(1234n.toString(16))
