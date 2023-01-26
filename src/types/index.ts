import { z } from "zod"

class CannotBeEncoded extends Error {}
class CannotBeDecoded extends Error {}
class MissingTag extends Error {}

type CompositeTag = {
  contract?: string
  name: string
}

type IdentifierResolver = (tag: CompositeTag) => string

type Codec<A, Z> = {
  encode: (a: A, resolve?: IdentifierResolver) => any
  decode: (a: any) => A
  zodDecoder: Z
}

const buildZodCodec =
  <A>(encode: (a: A, resolve?: IdentifierResolver) => any) =>
  <Z extends z.ZodObject<any, any, any>>(zodDecoder: Z) =>
  (transform: (z: Z) => (a: any) => A): Codec<A, Z> => ({
    encode,
    decode: transform(zodDecoder),
    zodDecoder,
  })

const encodeVoid = () => ({
  type: "Void",
})

const voidDecoder = z.object({ type: z.literal("Void") })

const Void = buildZodCodec<void>(encodeVoid)(voidDecoder)(
  (_) => _.transform(() => undefined).parse,
)

console.log(Void.encode())
console.log(Void.decode({ type: "Void" }))
// console.log(Void.decode({ type: "Void2" }))
const encodeBool = (a: boolean) => ({
  type: "Bool",
  value: a,
})

const boolDecoder = z.object({ type: z.literal("Bool"), value: z.boolean() })

const Bool = buildZodCodec<boolean>(encodeBool)(boolDecoder)(
  (_) => _.transform((a) => a.value).parse,
)

console.log(Bool.encode(true))
console.log(Bool.encode(false))
console.log(Bool.decode({ type: "Bool", value: true }))
console.log(Bool.decode({ type: "Bool", value: false }))
// console.log(Bool.decode({ type: "Bool", value: "true" }))

const encodeString = (a: string) => ({
  type: "String",
  value: a,
})

const stringDecoder = z.object({
  type: z.literal("String"),
  value: z.string(),
})

const String = buildZodCodec<string>(encodeString)(stringDecoder)(
  (_) => _.transform((a) => a.value).parse,
)

console.log(String.encode("hello"))
console.log(String.decode({ type: "String", value: "hello" }))
// console.log(String.decode({ type: "String", value: 1 }))

const encodeOptional = <A>(a: A | null, resolve?: IdentifierResolver) => ({
  type: "Optional",
  value: a === null ? null : String.encode(a, resolve),
})

console.log(Optional(String).encode("hello"))
console.log(Optional(String).encode(null))
console.log(Optional(String).decode({ type: "Optional", value: "hello" }))
console.log(Optional(String).decode({ type: "Optional", value: null }))
console.log(Optional(String).decode({ type: "Optional", value: 1 }))

/*

Example syntax:

const encoder =
  Codec.struct({

  })


*/
