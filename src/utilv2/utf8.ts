import { flow, pipe, z } from "#"
import { Zod } from "./zod"

type Utf8 = string | Buffer

const foldUtf8 =
  <T, U>(str: (str: string) => T, buf: (buf: Buffer) => U) =>
  (utf8: Utf8): T | U => {
    if (typeof utf8 === "string") {
      return str(utf8)
    }
    return buf(utf8)
  }

// Given a function from string to string, return a function from Utf8 to Utf8
const mapUtf8 = (fn: (str: string) => string) => (utf8: Utf8) =>
  foldUtf8(fn, (buf) => Buffer.from(fn(buf.toString("utf8")), "utf8"))(utf8)

const StrUtf8 = z.string()
const parseStr = Zod.prettyParser(StrUtf8)

const toBuffer = (str: Utf8) => foldUtf8(Buffer.from, (buf) => buf)(str)
const fromBuffer = (buf: Buffer) => buf.toString("utf8")

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

const replaceAll = (search: string, replace: string) => (str: string) =>
  str.split(search).join(replace)

const replaceAllRegex = (search: RegExp, replace: string) => (str: string) =>
  str.replace(search, replace)

const Utf8Util = {
  parseStr,
  toBuffer,
  fromBuffer,
  trimLeading,
  trimTrailing,
  prependLeading,
  appendTrailing,
  replaceAll,
  replaceAllRegex,
}

export { Utf8Util }
