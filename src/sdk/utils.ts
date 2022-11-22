import { newContext } from './actor'

// Defualt context for convenience
const context = newContext()

// Take a function that takes an empty object and return a function that takes
// no arguments
const noArg =
  <F>(fn: (_empty: {}) => F) =>
  () =>
    fn({})

// Remove the 0x prefix from an address
const sansPrefix = (address: string): string => address.replace(/^0x/, '')

export { context, noArg, sansPrefix }
