import { z } from "zod"
import { buildZodCodec } from "./base"

const encode = () => ({
  type: "Void",
})

const decoder = z.object({ type: z.literal("Void") })

const Void = buildZodCodec<void>(encode)(decoder)(
  (_) => _.transform(() => undefined).parse,
)

export { Void }
