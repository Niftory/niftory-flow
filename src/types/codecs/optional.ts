import { z } from "zod"
import { Codec, DecodedType, EncodedType, IdentifierResolver } from "./base"

type OptionalCodec<A extends Codec<any, any>> = Codec<
  DecodedType<A> | null,
  EncodedType<A> | null
>

const Optional = <A extends Codec<any, any>>(codec: A): OptionalCodec<A> => {
  const encode = (a: A | null, resolve?: IdentifierResolver) => {
    if (a === null) {
      return {
        type: "Optional",
        value: null,
      }
    } else {
      return {
        type: "Optional",
        value: codec.encode(a, resolve),
      }
    }
  }

  const decoder = z.object({
    type: z.literal("Optional"),
    value: z.union([z.null(), codec.decoder]),
  })

  const decode = (a: any) => {
    const result = decoder.parse(a)
    if (result.value === null) {
      return null
    } else {
      return codec.decode(result.value)
    }
  }

  return {
    encode,
    decode,
    decoder,
  }
}

export { Optional }
