import { z } from "zod"
import { Codec, DecodedType, EncodedType, IdentifierResolver } from "./base"

type ArrayCodec<A extends Codec<any, any>> = Codec<
  DecodedType<A>[],
  EncodedType<A>[]
>

const Array = <A extends Codec<any, any>>(codec: A): ArrayCodec<A> => {
  const encode = (a: EncodedType<A>[], resolve?: IdentifierResolver) => ({
    type: "Array",
    value: a.map((a) => codec.encode(a, resolve)),
  })

  const decoder = z.object({
    type: z.literal("Array"),
    value: z.array(codec.decoder),
  })

  const decode = (a: any) => {
    const result = decoder.parse(a)
    return result.value.map((value) => codec.decode(value))
  }

  return {
    encode,
    decode,
    decoder,
  }
}

export { Array }
