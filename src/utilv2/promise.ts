type PromiseIsh<T> = Promise<T> | PromiseLike<T> | T

const isPromise = <T>(value: unknown): value is Promise<T> =>
  typeof value === "object" &&
  value !== undefined &&
  value !== null &&
  "then" in value &&
  "catch" in value &&
  "finally" in value

const isPromiseLike = <T>(value: unknown): value is PromiseLike<T> =>
  typeof value === "object" &&
  value !== undefined &&
  value !== null &&
  "then" in value

const lift = <T>(value: PromiseIsh<T>): Promise<T> =>
  isPromise(value) ? value : Promise.resolve(value)

const then =
  <T, U>(fn: (result: U) => T) =>
  (promise: PromiseIsh<U>) =>
    lift(promise).then(fn)

const catch_ =
  <T>(fn: (error: unknown) => T) =>
  <U>(promise: PromiseIsh<U>) =>
    lift(promise).catch(fn)

const finally_ =
  (fn: () => any) =>
  <U>(promise: PromiseIsh<U>) =>
    lift(promise).finally(fn)

const resolve = <T>(value: T) => Promise.resolve(value)

const reject = <T = void>(error: unknown) => Promise.reject<T>(error)

const tapAsync =
  <T>(fn: (value: T) => any) =>
  (promise: PromiseIsh<T>) => {
    const lifted = lift(promise)
    lifted.then(fn)
    return lifted
  }

const tapAsyncAndWait =
  <T>(fn: (value: T) => any) =>
  async (promise: PromiseLike<T>) => {
    const lifted = lift(promise)
    await lifted.then(fn)
    return lifted
  }

const sleepMs = <T>(ms: number) =>
  tapAsyncAndWait<T>(() => new Promise((resolve) => setTimeout(resolve, ms)))

const timeout =
  (ms: number) =>
  <T>(promise: Promise<T>) => {
    const timeoutPromise = new Promise<T>((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        reject(new Error(`Timed out in ${ms} ms.`))
      }, ms)
      promise.then(() => {
        clearTimeout(timeoutId)
        promise.then(resolve)
      })
    })
    return timeoutPromise
  }

type AwaitedStruct<T extends Record<any, any>> = {
  [K in keyof T]: T[K] extends PromiseLike<infer U>
    ? U
    : T[K] extends Record<any, any>
    ? AwaitedStruct<T[K]>
    : T[K]
}

const all = async <T extends Record<any, any>>(
  obj: T,
): Promise<AwaitedStruct<T>> => {
  const keys = Object.keys(obj) as (keyof T)[]
  const promises = keys.map((key) => {
    if (isPromiseLike(obj[key])) {
      return obj[key]
    }
    if (typeof obj[key] === "object" && obj[key] !== null) {
      console.log(obj)
      return all(obj[key])
    }
    return obj[key]
  })
  const values = await Promise.all(promises)
  const result: any = {} as AwaitedStruct<T>
  keys.forEach((key, index) => {
    result[key] = values[index]
  })
  return result
}

const PromiseUtils = {
  then,
  catch: catch_,
  finally: finally_,
  resolve,
  reject,
  all,
  tapAsync,
  tapAsyncAndWait,
  sleepMs,
  timeout,
}

export { PromiseUtils }
