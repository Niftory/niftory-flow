import { pipe } from "./compose"

type None = null | undefined
type Option<A> = A | None

const isNone = (value: unknown): value is None =>
  value === null || value === undefined

const mapSome =
  <A, B>(fn: (value: A) => B) =>
  (value: Option<A>) => {
    if (isNone(value)) {
      return value
    }
    return fn(value)
  }

const mapNone =
  <B>(fn: () => B) =>
  <A>(value: A | None): A | B => {
    if (isNone(value)) {
      return fn()
    }
    return value
  }

const throwIfNone = mapNone(() => {
  throw new Error("Unexpected None.")
})

const OptionUtils = {
  throwIfNone,
  mapSome,
  mapNone,
}

export { OptionUtils }

// Example

const someFunction = (x: number) =>
  pipe(
    x,
    OptionUtils.mapSome((x) => x + 1),
    OptionUtils.mapSome((x) => x.toString()),
  )

console.log(someFunction(1))
