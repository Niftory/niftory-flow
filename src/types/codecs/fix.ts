import * as z from "zod"
import { Codec } from "./base"

const XFix64 = (signed: boolean): Codec<string, string> => {
  const U = signed ? "" : "U"
  const encode = (a: string) => ({
    type: `${U}Fix64`,
    value: a,
  })

  const decoder = z.object({
    type: z.literal(`${U}Fix64`),
    value: z.string().regex(/^-?\d+\.\d*$/),
  })

  const decode = (a: any) => decoder.transform((a) => a.value).parse(a)

  return {
    encode,
    decode,
    decoder,
  }
}

const Fix64 = XFix64(true)
const UFix64 = XFix64(false)

export { Fix64, UFix64 }
