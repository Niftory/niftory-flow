import { z } from "zod"

type CompositeTag = {
  contract?: string
  name: string
}

type IdentifierResolver = (tag: CompositeTag) => string | null

const IDENTIFIER: unique symbol = Symbol("IDENTIFIER")

type Reflection = {
  [IDENTIFIER]: string
}

// TODO: Can this be cleaned up? kind of ugly...
const identifier = <T>(
  refl: T,
): T extends Reflection ? string : string | null => {
  if (
    typeof refl === "object" &&
    refl !== null &&
    IDENTIFIER in refl &&
    typeof refl[IDENTIFIER] === "string"
  ) {
    return refl[IDENTIFIER]
  }
  return null as any
}

// AI - I for Input, AO - O for Output
type Codec<AI, AO> = {
  encode: (a: AO, resolve?: IdentifierResolver) => any
  decode: (a: any) => AI
  decoder: z.AnyZodObject
}

type DecodedType<A extends Codec<any, any>> = A extends Codec<infer T, any>
  ? T
  : never

type EncodedType<A extends Codec<any, any>> = A extends Codec<any, infer T>
  ? T
  : never

const buildZodCodec =
  <AO>(encode: (a: AO, resolve?: IdentifierResolver) => any) =>
  <Z extends z.ZodObject<any, any, any>>(decoder: Z) =>
  <AI>(transform: (z: Z) => (a: any) => AI): Codec<AI, AO> => ({
    encode,
    decode: transform(decoder),
    decoder,
  })

export {
  CompositeTag,
  Reflection,
  IdentifierResolver,
  Codec,
  DecodedType,
  EncodedType,
  buildZodCodec,
  identifier,
  IDENTIFIER,
}
