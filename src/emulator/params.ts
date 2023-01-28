import { Util } from "#"
import { z } from "zod"

const EMULATOR_COMMAND = "emulator"

type ChainId = "emulator" | "testnet" | "mainnet"

type HashAlgorithm = "SHA2_256" | "SHA3_256"
type SignatureAlgorithm = "ECDSA_P256" | "ECDSA_secp256k1"

type RootAccount = {
  hashAlgorithm: HashAlgorithm
  signatureAlgorithm: SignatureAlgorithm
  privateKey: string
}

// we are keeping this simpler than the emulator allows...
const Duration = z.string().regex(/^-?\d+(ns|us|µs|ms|s|m|h)$/)
type Duration = z.infer<typeof Duration>

type EmulatorParamsFull = {
  // ports
  adminApiPort: number
  grpcPort: number
  httpPort: number

  // blockchain
  chainId: ChainId
  blockTime: Duration

  // logging
  restDebug: boolean
  grpcDebug: boolean

  // service account
  root: RootAccount

  // emulator configuration
  contracts: boolean
  simpleAddresses: boolean
  minAccountBalance: string
  skipTxValidation: boolean
  scriptGasLimit: Util.IntLike
  transactionGasLimit: Util.IntLike

  enableStorageLimit: boolean
  mbStoragePerFlow: string
  tokenSupply: string

  transactionExpiry: number
  enableTransactionFees: boolean

  // persistance
  // TODO: add persistance settings
}

const EmulatorDefaults = {
  adminApiPort: 8080,
  grpcPort: 3569,
  httpPort: 8888,
  chainId: "emulator" as ChainId,
  blockTime: "1ms" as Duration,
  restDebug: false,
  grpcDebug: false,
  root: {
    hashAlgorithm: "SHA3_256" as HashAlgorithm,
    signatureAlgorithm: "ECDSA_P256" as SignatureAlgorithm,
    privateKey:
      "c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8c2a8",
  },
  contracts: false,
  simpleAddresses: true,
  minAccountBalance: "100.0",
  skipTxValidation: false,
  scriptGasLimit: 1000000,
  transactionGasLimit: 1000000,
  enableStorageLimit: true,
  mbStoragePerFlow: "100.0",
  tokenSupply: "10000000.0",
  transactionExpiry: 10000,
  enableTransactionFees: true,
}
type EmulatorDefaults = typeof EmulatorDefaults

// a type to represent optional emulator params, which makes only the
// EmulatorDefault keys optional
type NoDefaults = Omit<EmulatorParamsFull, keyof EmulatorDefaults>
type HasDefaults = Omit<EmulatorParamsFull, keyof NoDefaults>

type EmulatorParams = NoDefaults & Partial<HasDefaults>

const getFullEmulatorParams = (params: EmulatorParams): EmulatorParamsFull => {
  return {
    ...EmulatorDefaults,
    ...params,
  }
}

const formatEmulatorParams = (params: EmulatorParamsFull): string[] => [
  "--log-format",
  "json",
  "--admin-port",
  params.adminApiPort.toString(),
  "--port",
  params.grpcPort.toString(),
  "--rest-port",
  params.httpPort.toString(),
  "--chain-id",
  params.chainId,
  // TODO: The below option has some issues. Need to investigate.
  // "--block-time",
  // params.blockTime,
  ...(params.restDebug ? ["--rest-debug"] : []),
  ...(params.grpcDebug ? ["--grpc-debug"] : []),
  "--service-hash-algo",
  params.root.hashAlgorithm,
  "--service-sig-algo",
  params.root.signatureAlgorithm,
  "--service-priv-key",
  params.root.privateKey,
  ...(params.contracts ? ["--contracts"] : []),
  ...(params.simpleAddresses ? ["--simple-addresses"] : []),
  "--min-account-balance",
  params.minAccountBalance,
  ...(params.skipTxValidation ? ["--skip-tx-validation"] : []),
  "--script-gas-limit",
  Util.IntLike.asString(params.scriptGasLimit),
  "--transaction-max-gas-limit",
  Util.IntLike.asString(params.transactionGasLimit),
  ...(params.enableStorageLimit ? ["--storage-limit"] : []),
  "--storage-per-flow",
  params.mbStoragePerFlow,
  "--token-supply",
  params.tokenSupply,
  "--transaction-expiry",
  params.transactionExpiry.toString(),
  ...(params.enableTransactionFees ? ["--transaction-fees"] : []),
]

const buildCommand = (params: EmulatorParams): string[] => {
  const fullParams = getFullEmulatorParams(params)
  return [EMULATOR_COMMAND, ...formatEmulatorParams(fullParams)]
}

export { EmulatorParams, buildCommand, RootAccount, getFullEmulatorParams }
