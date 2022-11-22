import * as jest from '@jest/globals'

import * as constants from './constants'
import * as emulator from './emulator'

// A testbed boilerplate with preconfigured actors interacting with the Niftory
// ecosystem.
const bed = (emulatorParamsOverrides?: Partial<emulator.EmulatorParams>) => {
  // Emulator configurations
  const emulatorParams: emulator.EmulatorParams = {
    ...constants.EMULATOR_DEFAULT,
    ...emulatorParamsOverrides,
  }

  // Our new describe function will handle the emulator initialization and
  // teardown.
  const describe = (name: string, fn: () => Promise<void>) =>
    jest.describe(name, () => {
      jest.beforeAll(async () => emulator.start(emulatorParams))

      jest.afterAll(async () => emulator.stop())

      fn()
    })

  const test = (name: string, fn: (actors: {}) => Promise<void>) =>
    jest.test(name, () => fn({}))

  return { describe, test }
}

export default bed
