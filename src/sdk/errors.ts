import { z } from 'zod'

const parser = z.object({
  name: z.optional(z.string()),
  statusCode: z.optional(z.number()),
  errorMessage: z.optional(z.string()),
  message: z.optional(z.string()),
})

// When we get an HTTP error from the sdk
type FlowError = { _tag: 'flow' } & z.TypeOf<typeof parser>

// When we can't parse the HTTP error from the sdk
type UnknownError = {
  _tag: 'unknown'
  error: any
  parseError: string
}

const parseError = (error: unknown): FlowError | UnknownError => {
  const maybeParsed = parser.safeParse(error)
  return maybeParsed.success
    ? {
        _tag: 'flow',
        ...maybeParsed.data,
      }
    : {
        _tag: 'unknown',
        error,
        parseError: maybeParsed.error.toString(),
      }
}

export { parseError }
export type { FlowError, UnknownError }
