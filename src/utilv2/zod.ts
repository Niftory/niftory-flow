import { z } from "#"

const mapIssues = (issues: z.ZodIssue[]) => {
  return issues.map((issue) => {
    const path = issue.path.length > 0 ? `${issue.path.join("/")}: ` : ""
    return `  - ${path}${issue.message}`
  })
}

const mapError = (error: z.ZodError, attempt?: unknown) => {
  const issues = mapIssues(error.issues)
  let attemptString: string = ""
  try {
    attemptString = `\nInput:\n` + `${JSON.stringify(attempt, null, 2)}`
  } catch (err) {
    attemptString = ""
  }
  return `Unable to parse input.\n${issues.join("\n")}${attemptString}`
}

const prettyParser =
  <T>(schema: z.ZodType<T>) =>
  (attempt: unknown) => {
    try {
      return schema.parse(attempt)
    } catch (error) {
      if (error instanceof z.ZodError) {
        throw new Error(mapError(error, attempt))
      }
      throw error
    }
  }

const Zod = {
  prettyParser,
}

export { Zod }
