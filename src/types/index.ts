import { z } from "zod"

const Void_ = z
  .object({
    type: z.literal("Void"),
  })
  .transform(() => undefined).parse

const t: any = {
  type: "Void",
}

const parsed = Void_(t)

console.log(parsed)
