import { flow, pipe, z } from "#"

const BASE64 = Symbol("base64")

// full correct base64 regex, including correct padding
const BASE64_REGEX =
  /^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/

type Base64 = {
  [BASE64]: string
  [Symbol.toStringTag]: string
}

const Base64 = z.string().regex(BASE64_REGEX)

const parseBase64 = (str: string) => ({
  [BASE64]: Base64.parse(str),
  [Symbol.toStringTag]: str,
})

const fromBase64ToBuffer = (base64: Base64) =>
  Buffer.from(base64[BASE64], "base64")

const fromBase64ToString = (base64: Base64) => base64[BASE64]

const sampleBase64 = "SGVsbG8sIFdvcmxkIQ=="

console.log(parseBase64(sampleBase64).toString())
