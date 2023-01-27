import { z } from "zod"
import { Codec, DecodedType, EncodedType, IdentifierResolver } from "./base"

type DictionaryCodec<
  A extends Codec<any, any>,
  B extends Codec<any, any>,
> = Codec<
  { [Z in DecodedType<A>]: DecodedType<B> },
  { [Z in EncodedType<A>]: EncodedType<B> }
>

const Dictionary = <A extends Codec<any, any>, B extends Codec<any, any>>(
  keyCodec: A,
  valueCodec: B,
): DictionaryCodec<A, B> => {
  const encode = (
    a: {
      [K in EncodedType<A>]: EncodedType<B>
    },
    resolve?: IdentifierResolver,
  ) => ({
    type: "Dictionary",
    value: Object.entries(a).map(([key, value]) => ({
      key: keyCodec.encode(key, resolve),
      value: valueCodec.encode(value, resolve),
    })),
  })

  const decoder = z.object({
    type: z.literal("Dictionary"),
    value: z.array(
      z.object({
        key: keyCodec.decoder,
        value: valueCodec.decoder,
      }),
    ),
  })

  const decode = (a: any) => {
    const result = decoder.parse(a)
    return result.value.reduce((acc, { key, value }) => {
      acc[keyCodec.decode(key)] = valueCodec.decode(value)
      return acc
    }, {} as any)
  }

  return {
    encode,
    decode,
    decoder,
  }
}

export { Dictionary }
