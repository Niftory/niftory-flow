const noArg =
  <A>(fn: (_: {}) => A) =>
  () =>
    fn({})

const FunctionUtil = {
  noArg,
}

export { FunctionUtil }
