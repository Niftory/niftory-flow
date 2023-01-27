import { flow, Util } from "#"
import { z } from "zod"
import { buildZodCodec } from "./base"

const encode = (a: string) => ({
  type: "Address",
  value: Util.String.prependLeading("0x")(a),
})

const decoder = z.object({
  type: z.literal("Address"),
  value: z.string().regex(/^(0x)?[a-fA-F0-9]*$/),
})

const Address = buildZodCodec<string>(encode)(decoder)((_) =>
  flow(_.transform((a) => a.value).parse, Util.String.trimLeading("0x")),
)

export { Address }
