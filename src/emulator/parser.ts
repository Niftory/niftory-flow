// A single process output may contain multiple lines, so we need to split it
// with the below regex.
const NEWLINE_REGEX = /[\r\n]+/

// To parse the child_process output
const parseLines = (data: any): string[] => {
  var lines: string[] = []
  try {
    lines = data.toString().split(NEWLINE_REGEX)
    // We don't want the last line - it is likely blank.
    if (lines[lines.length - 1] === '') {
      lines.pop()
    }
  } catch (e) {
    console.error(
      `Unable to parse raw process output. Skipping.\n` +
        `Lines: ${lines}\n` +
        `Error: ${e}`,
    )
  }
  return lines
}

const Parser = {
  parseLines,
}
export { Parser }
