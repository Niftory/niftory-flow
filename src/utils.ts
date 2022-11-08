import { newContext } from './actor'

const context = newContext()
const noArg =
  <F>(fn: (_empty: {}) => F) =>
  () =>
    fn({})

export { context, noArg }
