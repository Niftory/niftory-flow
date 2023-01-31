const as =
  <T>(value: T) =>
  () =>
    value

const tap =
  <T>(fn: (value: T) => any) =>
  (value: T) => {
    fn(value)
    return value
  }

const provide =
  <T>(value: T) =>
  <U>(fn: (value: T) => U) =>
    fn(value)

const log = <T>(value: T) => tap<T>(console.log)(value)

const FunctionUtils = {
  as,
  tap,
  log,
  provide,
}

export { FunctionUtils }
