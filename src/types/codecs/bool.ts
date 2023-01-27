import { z } from "zod"
import { buildZodCodec } from "./base"

const encode = (a: boolean) => ({
  type: "Bool",
  value: a,
})

const decoder = z.object({ type: z.literal("Bool"), value: z.boolean() })

const Bool = buildZodCodec(encode)(decoder)(
  (_) => _.transform((a) => a.value).parse,
)

export { Bool }
