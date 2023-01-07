import { spawn } from 'node:child_process'
import { parseLines } from './parser'
import { EmulatorPorts, updatePorts } from './ports'

const FLOW_COMMAND = 'flow'
const EMULATOR_ACTION = 'emulator'

type EmulatorParams = {
  basePath: string
  port: number
  logging: boolean
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))

const run = async (
  { basePath, port, logging }: EmulatorParams,
  fn: () => Promise<void>,
): Promise<void> => {
  const flow = spawn(FLOW_COMMAND, [EMULATOR_ACTION, '--log-format', 'json'])

  var ports: EmulatorPorts = {}
  var ready = false
  var closed = false

  // For every single line of emulator output, let's try to do the following
  // things:
  // - Parse the line as JSON
  // - Parse any potential ports during startup
  // - For each transaction
  //   - Capture any accounts created
  //   - Capture any contracts deployed
  flow.stdout.on('data', (data: any) => {
    const lines: string[] = parseLines(data)
    for (const line of lines) {
      try {
        const json = JSON.parse(line)
        if (!ready) [ports, ready] = updatePorts(json, ports)
      } catch (e) {
        console.error(
          `Unable to parse emulator log. Skipping.\n` +
            `Line: ${line}\n` +
            `Error: ${e}`,
        )
      }
    }
  })

  flow.stderr.on('data', (data: any) => {
    console.error(`ERROR: ${data}`)
  })

  flow.on('close', (code) => {
    closed = true
  })

  // Don't run anything until the emulator is ready (all ports are ready)
  var lastLog = Date.now()
  while (!ready) {
    if (Date.now() - lastLog > 5000) {
      console.log('waiting for emulator to start')
      lastLog = Date.now()
    }
    await sleep(100)
  }

  // Run whatever the user wants to run
  await fn()

  // Close the emulator and wait for it to close
  flow.kill()
  lastLog = Date.now()
  while (!closed) {
    if (Date.now() - lastLog > 5000) {
      console.log('waiting for emulator to close')
      lastLog = Date.now()
    }
    await sleep(100)
  }

  // We are done!
  console.log(ports)
  console.log("Emulator closed. That's all folks!")
}

export { run }
export type { EmulatorParams }
