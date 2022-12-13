const someFunction = (value: number) => {
  if (value <= 0) throw new Error('yo')
  someFunction(value - 1)
}

var j = 0

const someFunctionForLoop = (value: number) => {
  for (let i = 0; i < value; i++) {
    j = j + 1
  }
}

const someFunctionPromise = async (value: number): Promise<number> => {
  if (value <= 0) throw new Error('yo')
  return Promise.resolve().then(() => {
    j = j + 1
    return someFunctionPromise(value - 1)
  })
}

const someFunctionForLoopAsync = async (value: number) => {
  for (let i = 0; i < value; i++) {
    await Promise.resolve().then(() => {
      j = j + 1
    })
  }
}

// someFunctionForLoop(2_000_000_000)
// someFunctionForLoopAsync(100_000_000)
someFunctionPromise(10_000_000)
// someFunction(10)

console.log(j)
