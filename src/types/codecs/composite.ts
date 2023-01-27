import { z } from "zod"
import {
  Codec,
  DecodedType,
  EncodedType,
  IDENTIFIER,
  IdentifierResolver,
  Reflection,
} from "./base"

type CompositeType = "Struct" | "Resource" | "Event" | "Contract" | "Enum"

type CompositeCodec<A extends { [K in keyof A]: Codec<any, any> }> = Codec<
  { [K in keyof A]: DecodedType<A[K]> } & Reflection,
  { [K in keyof A]: EncodedType<A[K]> }
>

const Composite =
  <C extends CompositeType>(type: C) =>
  <A extends { [K in keyof A]: Codec<any, any> }>(
    identifier: string,
    fields: A,
  ): CompositeCodec<A> => {
    const encode = (
      a: {
        [K in keyof A]: EncodedType<A[K]>
      },
      resolve?: IdentifierResolver,
    ) => ({
      type,
      value: {
        id: identifier,
        fields: Object.entries(a).map(([key, value]) => ({
          name: key,
          value: (fields as any)[key].encode(value, resolve),
        })),
      },
    })

    const decoder = z.object({
      type: z.literal(type),
      value: z.object({
        id: z.literal(identifier),
        fields: z.array(
          z.object({
            name: z.string(),
            value: z.unknown(),
          }),
        ),
      }),
    })

    const decode = (a: any) => {
      const result = decoder.parse(a)
      return {
        [IDENTIFIER]: result.value.id,
        ...result.value.fields.reduce((acc, { name, value }) => {
          acc[name] = (fields as any)[name].decode(value)
          return acc
        }, {} as any),
      }
    }

    return {
      encode,
      decode,
      decoder,
    }
  }

const Struct = Composite("Struct")
const Resource = Composite("Resource")
const Event = Composite("Event")
const Contract = Composite("Contract")
const Enum = Composite("Enum")

export { Struct, Resource, Event, Contract, Enum }
