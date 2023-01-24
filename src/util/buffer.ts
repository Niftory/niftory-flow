import { pipe } from 'fp-ts/lib/function'
import { z } from 'zod'

const HexString = z.string().regex(/^([0-9a-fA-F]{2})+$/)
const Base64String = z
  .string()
  .regex(/^([0-9a-zA-Z+/]{4})*(([0-9a-zA-Z+/]{2}==)|([0-9a-zA-Z+/]{3}=))?$/)

const bufferToHex = (buffer: Buffer) => buffer.toString('hex')
const hexToBuffer = (hex: string) =>
  pipe(HexString.parse(hex), (parsed) => Buffer.from(parsed, 'hex'))

const bufferToBase64 = (buffer: Buffer) => buffer.toString('base64')
const base64ToBuffer = (base64: string) =>
  pipe(Base64String.parse(base64), (parsed) => Buffer.from(parsed, 'base64'))

const bufferToUtf8 = (buffer: Buffer) => buffer.toString('utf8')
const utf8ToBuffer = (utf8: string) => Buffer.from(utf8, 'utf8')

const BufferUtil = {
  bufferToHex,
  hexToBuffer,
  bufferToBase64,
  base64ToBuffer,
  bufferToUtf8,
  utf8ToBuffer,
}

export { BufferUtil }
