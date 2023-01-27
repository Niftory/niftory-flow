import { z } from "zod"
import { buildZodCodec, Codec } from "./base"

type PathDomain = "storage" | "private" | "public"

type PathUri = { domain: PathDomain; identifier: string }

type PathInput = string | PathUri

const normalize = (input: PathInput) => {
  if (typeof input === "string") {
    const parse = z.string().regex(/^\/(storage|private|public)\/.+$/).parse
    const [_, domain, identifier]: [any, string, string] = parse(input).split(
      "/",
    ) as any
    return { domain, identifier }
  }
  return input
}

const encode = (input: PathInput) => ({
  type: "Path",
  value: normalize(input),
})

const pathDecoder = z.object({
  type: z.literal("Path"),
  value: z.object({
    domain: z.union([
      z.literal("storage"),
      z.literal("private"),
      z.literal("public"),
    ]),
    identifier: z.string(),
  }),
})

const storageDecoder = z.object({
  type: z.literal("Path"),
  value: z.object({
    domain: z.literal("storage"),
    identifier: z.string(),
  }),
})

const privateDecoder = z.object({
  type: z.literal("Path"),
  value: z.object({
    domain: z.literal("private"),
    identifier: z.string(),
  }),
})

const publicDecoder = z.object({
  type: z.literal("Path"),
  value: z.object({
    domain: z.literal("public"),
    identifier: z.string(),
  }),
})

const Path: Codec<PathUri, PathInput> = buildZodCodec(encode)(pathDecoder)(
  (_) => _.transform((a) => a.value).parse,
)

const StoragePath: Codec<PathUri, PathInput> = buildZodCodec(encode)(
  storageDecoder,
)((_) => _.transform((a) => a.value).parse)

const PrivatePath: Codec<PathUri, PathInput> = buildZodCodec(encode)(
  privateDecoder,
)((_) => _.transform((a) => a.value).parse)

const PublicPath: Codec<PathUri, PathInput> = buildZodCodec(encode)(
  publicDecoder,
)((_) => _.transform((a) => a.value).parse)

export { Path, StoragePath, PrivatePath, PublicPath }
