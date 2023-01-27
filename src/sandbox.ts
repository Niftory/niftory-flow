import { Codec } from "#"

console.log(Codec.Bool.encode(true))

console.log(Codec.Optional(Codec.Optional(Codec.Bool)).encode(true))

console.log(Codec.Optional(Codec.UInt128).encode(123))

const t = Codec.Tuple([Codec.Bool, Codec.UInt128, Codec.Optional(Codec.String)])

const encoded = JSON.stringify(t.encode([true, "3213", null]), null, 2)
const decoded = t.decode(JSON.parse(encoded))

const a = Codec.Array(Codec.Array(Codec.Bool))

a.encode([
  [true, false],
  [true, false],
])

console.log(encoded)
console.log(decoded)

const superExampleCodec = Codec.Tuple([
  Codec.Bool,
  Codec.UInt128,
  Codec.Optional(Codec.Struct("Foo", { a: Codec.Bool, b: Codec.PrivatePath })),
])

const encoded2 = superExampleCodec.encode([
  true,
  123,
  { a: true, b: { domain: "private", identifier: "foo" } },
])
console.log(JSON.stringify(encoded2))
