import { flow, pipe, X } from "#"

const double = (x: number) => x * 2

const toString = (x: number) => x.toString()

const repeat = (x: string) => x.repeat(2)

const negate = (x: number) => -x

const parse = (x: string) => parseInt(x)

const log = X.tap(console.log)

const main = () =>
  pipe(
    X.resolve(5),
    X.then(double),
    X.sleepMs(250),
    X.timeout(2000),
    X.tapAsync(console.log),
    X.sleepMs(250),
    X.timeout(2000),
    X.then(negate),
    X.tapAsync(console.log),
    X.then(toString),
    X.tapAsync((v) => Promise.reject(10)),
    X.timeout(3000),
    X.then(parse),
    X.then(negate),
  )

const main2 = async () => {
  const examplePromiseStruct = {
    a: Promise.resolve(1),
    b: "b",
    c: {
      d: Promise.reject(new Error("you suck")),
      e: { f: Promise.resolve(2), g: Promise.resolve(3), h: true },
    },
  }
  const z = await X.all(examplePromiseStruct)
  console.log(z)
}

main()
