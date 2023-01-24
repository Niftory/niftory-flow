// These strings will show up in the emulator logs as
// "Started <string> server on port <number>"
const PORT_STRINGS = {
  grpc: 'gRPC',
  rest: 'REST API',
  admin: 'admin',
}

type PortType = 'grpc' | 'rest' | 'admin'

type Port = {
  type: PortType
  number: number
}

type EmulatorPorts = {
  grpc?: number
  rest?: number
  admin?: number
}

// Whenever a port is successfully started, it does it with the below message
const createPattern = (type: string) =>
  new RegExp(`Started ${type} server on port`)

// Parse the emulator output to find the ports, if it is a port message
const parsePort = (json: object): Port | undefined => {
  try {
    const message: string = json['msg']
    for (const type of ['grpc', 'rest', 'admin'] as PortType[]) {
      const pattern = createPattern(PORT_STRINGS[type])
      if (pattern.test(message)) {
        const port: number = json['port']
        return { type, number: port }
      }
    }
  } catch (e) {
    // probably just not a port message. No need to do anything
  }
  return undefined
}

const portsReady = ({ admin, grpc, rest }: EmulatorPorts): boolean =>
  admin !== undefined && grpc !== undefined && rest !== undefined

const updatePorts = (
  json: object,
  currentPorts: EmulatorPorts,
): [EmulatorPorts, boolean] => {
  const possiblePort = parsePort(json)
  const ports = currentPorts
  if (possiblePort !== undefined) {
    const { type, number } = possiblePort
    ports[type] = number
  }
  const ready = portsReady(ports)
  return [ports, ready]
}

const Ports = {
  updatePorts,
}

export { Ports }
export type { EmulatorPorts }
