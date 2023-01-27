import { z } from "zod"
import { buildZodCodec } from "./base"

const encode = (a: string) => ({
  type: "String",
  value: a,
})

const decode = z.object({
  type: z.literal("String"),
  value: z.string(),
})

const String = buildZodCodec(encode)(decode)(
  (_) => _.transform((a) => a.value).parse,
)

export { String }
