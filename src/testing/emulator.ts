import * as FlowTesting from 'flow-js-testing'

type EmulatorParams = {
  basePath: string
  port: number
  logging: boolean
}

const start = async ({
  basePath,
  port,
  logging,
}: EmulatorParams): Promise<any> =>
  FlowTesting.init(basePath, { port }).then(() =>
    FlowTesting.emulator.start(port, logging),
  )

const stop = async (): Promise<any> => FlowTesting.emulator.stop()

export { start, stop }
export type { EmulatorParams }
