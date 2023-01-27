import { z } from "zod"
import { Codec, DecodedType, EncodedType, IdentifierResolver } from "./base"

type TupleCodec<A extends Codec<any, any>[]> = Codec<
  { [Z in keyof A]: DecodedType<A[Z]> },
  { [Z in keyof A]: EncodedType<A[Z]> }
>

const Tuple = <A extends Codec<any, any>[]>(codecs: [...A]): TupleCodec<A> => {
  const encode = (
    a: {
      [K in keyof A]: EncodedType<A[K]>
    },
    resolve?: IdentifierResolver,
  ) => ({
    type: "Array",
    value: codecs.map((codec, i) => codec.encode(a[i], resolve)),
  })

  const decoder = z.object({
    type: z.literal("Array"),
    value: z.tuple(codecs.map((codec) => codec.decoder) as any),
  })

  const decode = (a: any) => {
    const result = decoder.parse(a)
    return result.value.map((value, i) => codecs[i].decode(value)) as any
  }

  return {
    encode,
    decode,
    decoder,
  }
}

export { Tuple }
