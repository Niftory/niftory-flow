// String conversions
const toHex = (buffer: Buffer) => buffer.toString("hex")

const toBase64 = (buffer: Buffer) => buffer.toString("base64")

const toUtf8 = (buffer: Buffer) => buffer.toString("utf8")

// Numeric conversions
const toNumber = (buffer: Buffer) => parseInt(buffer.toString("hex"), 16)

const toBigInt = (buffer: Buffer) => BigInt(buffer.toString("hex"))

const BufferUtil = {
  toHex,
  toBase64,
  toUtf8,
  toNumber,
  toBigInt,
}

export { BufferUtil }
