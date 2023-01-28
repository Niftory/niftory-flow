import { Client } from "#"
import { ChildProcess, spawn } from "node:child_process"
import {
  buildCommand,
  EmulatorParams,
  getFullEmulatorParams,
  RootAccount,
} from "./params"
import { Parser } from "./parser"
import { EmulatorPorts, Ports } from "./ports"

const FLOW_COMMAND = "flow"

type EmulatorProcessParams = {
  startTimeoutMs: number
  checkIntervalMs: number
  stdout: (data: string) => Promise<void>
  stderr: (data: string) => Promise<void>
}

const DEFAULT_STDOUT_HANDLER = (data: string) =>
  new Promise<void>((resolve) => {
    console.log(data)
    resolve()
  })

const DEFAULT_STDERR_HANDLER = (data: string) =>
  new Promise<void>((resolve) => {
    console.error(data)
    resolve()
  })

const EMULATOR_PROCESS_PARAM_DEFAULTS: EmulatorProcessParams = {
  startTimeoutMs: 10000,
  checkIntervalMs: 100,
  stdout: DEFAULT_STDOUT_HANDLER,
  stderr: DEFAULT_STDERR_HANDLER,
}

type EmulatorProcess = {
  ports: EmulatorPorts
  kill: () => Promise<void>
  process: ChildProcess
  client: ReturnType<typeof Client.create>
  root: RootAccount
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))

const create = async (
  params: EmulatorParams,
  options?: Partial<EmulatorProcessParams>,
): Promise<EmulatorProcess> => {
  const { startTimeoutMs, checkIntervalMs, stdout, stderr } = {
    ...EMULATOR_PROCESS_PARAM_DEFAULTS,
    ...options,
  }
  const flow = spawn(FLOW_COMMAND, buildCommand(params))

  var ports: EmulatorPorts = {}
  var ready = false
  var closed = false

  process.on("exit", () => {
    if (!closed) {
      flow.kill()
    }
  })

  flow.stdout.on("data", async (data: any) => {
    const lines: string[] = Parser.parseLines(data)
    for (const line of lines) {
      try {
        const json = JSON.parse(line)
        await stdout(line)
        if (!ready) [ports, ready] = Ports.updatePorts(json, ports)
      } catch (e) {
        stderr(
          `Unable to parse emulator log. Skipping.\n` +
            `Line: ${line}\n` +
            `Error: ${e}`,
        )
      }
    }
  })

  flow.stderr.on("data", (data: any) => {
    stderr(`ERROR: ${data}`)
  })

  flow.on("close", (code) => {
    closed = true
  })

  const start = Date.now()
  while (!ready && Date.now() - start < startTimeoutMs) {
    await sleep(checkIntervalMs)
  }

  if (!ready) {
    flow.kill()
    throw new Error("Emulator failed to start")
  }

  const kill = async () => {
    flow.kill()
    while (!closed) {
      await sleep(100)
    }
  }

  const client = Client.create("http://127.0.0.1:" + ports.rest!)

  return {
    ports,
    kill,
    process: flow,
    client,
    root: getFullEmulatorParams(params).root,
  }
}

export { create }
