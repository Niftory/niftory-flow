import * as path from 'path'
import * as emulator from './emulator'

// Premade emulator accounts
const EMULATOR_ACCOUNTS = {
  // FlowServiceAccount, used for XXX
  // FlowStorageFees, used for XXX
  service: '0xf8d6e0586b0a20c7',

  // FungibleToken, the standard FungibleToken contract
  coreContracts: '0xee82856bf20e2aa6',

  // FlowToken, the primary currency of the Flow blockchain
  mintContracts: '0x0ae53cb6e3f42a79',
}

// Keys to be used for all tests
const EMULATOR_CREDENTIALS = {
  privateKey:
    '418acca4607d4a220009623d5d4f392b0e1511a3cca422cbd54ae817a0f65f69',
  publicKey:
    '6e1bfdf4da1e5c1930465c8bbe0af3ca398cc252e824dd224c79e4d2111c5a7c36a7099f9019f46df4fb9903939c083fe8409e8899af0a05fbbfe8d994569f23',
  hashingAlg: 'SHA3_256',
  signatureAlg: 'ECDSA_P256',
}

// All accounts
const TEST_ACCOUNTS = {
  extraBaseContracts: 'EXTRA_BASE_CONTRACTS',
  catalogAdmin: 'CATALOG_ADMIN',
  dapperAdmin: 'DAPPER_ADMIN',
  niftoryContracts: 'NIFTORY_CONTRACTS',
  niftoryAdmin: 'NIFTORY_ADMIN',
  brandA: 'BRAND_A',
  brandB: 'BRAND_B',
  collectorA: 'COLLECTOR_A',
  collectorB: 'COLLECTOR_B',
}

// Misc
const MAX_UINT_64 = BigInt('18446744073709551615')

// Default emulator params
const EMULATOR_DEFAULT: emulator.EmulatorParams = {
  basePath: path.resolve(__dirname, '../cadence'),
  port: 8080,
  logging: true,
}

export {
  EMULATOR_ACCOUNTS,
  EMULATOR_CREDENTIALS,
  TEST_ACCOUNTS,
  MAX_UINT_64,
  EMULATOR_DEFAULT,
}
