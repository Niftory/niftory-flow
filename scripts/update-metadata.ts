import { KMSClient, SignCommand } from '@aws-sdk/client-kms'
import * as fcl from '@onflow/fcl'
import crypto from 'crypto'
import * as dotenv from 'dotenv'
import { derToJose } from 'ecdsa-sig-formatter'
import * as fs from 'fs'
import { z } from 'zod'

dotenv.config()

type Network = 'emulator' | 'testnet' | 'mainnet'

type FclConfig = {
  network: Network
  accessNode: string
}

const CONFIG_FILE = 'flowargs.json'

const AWS_ACCESS_KEY_ID = process.env.AWS_ACCESS_KEY_ID!
const AWS_SECRET_ACCESS_KEY = process.env.AWS_SECRET_ACCESS_KEY!
const AWS_REGION = process.env.AWS_REGION!

const KMS_SIGNING_ALGORITHM = 'ECDSA_SHA_256'

type ContractVar = {
  emulator?: string
  testnet?: string
  mainnet?: string
}

type Contracts = {
  [key: string]: ContractVar
}

type Variables = {
  [key: string]: ContractVar
}

type Config = {
  contracts: Contracts
  variables: Variables
}

interface ConfigOps {
  getContractAddress: (name: string) => string
  getVariable: (name: string) => string
}

const parseConfig =
  (configFile: string = CONFIG_FILE) =>
  (network: Network): ConfigOps => {
    const address = z.string().length(16)

    const variable = z.object({
      name: z.string(),
      values: z.object({
        emulator: z.string(),
        testnet: z.string(),
        mainnet: z.string(),
      }),
    })

    const contract = z.object({
      name: z.string(),
      addresses: z.object({
        emulator: z.optional(address),
        testnet: z.optional(address),
        mainnet: z.optional(address),
      }),
    })

    const config = z.object({
      contracts: z.array(contract),
      variables: z.array(variable),
    })

    const rawConfig = fs.readFileSync(configFile, 'utf8')
    const parsedConfig = config.parse(JSON.parse(rawConfig))

    var dslConfig: Config = {
      contracts: {},
      variables: {},
    }

    parsedConfig.contracts.forEach((contract) => {
      dslConfig.contracts[contract.name] = contract.addresses
    })

    parsedConfig.variables.forEach((variable) => {
      dslConfig.variables[variable.name] = variable.values
    })

    return {
      getContractAddress: (name: string) => {
        const value = dslConfig.contracts[name][network]
        if (value) {
          return value
        } else {
          throw new Error(
            `No contract named ${name} found for network ${network}`,
          )
        }
      },
      getVariable: (name: string) => {
        const value = dslConfig.variables[name][network]
        if (value) {
          return value
        }
        throw new Error(
          `No variable named ${name} found for network ${network}`,
        )
      },
    }
  }

const configureFcl = ({ network, accessNode }: FclConfig) => {
  fcl.config().put('flow.network', network).put('accessNode.api', accessNode)
}

const getTransactionCode = (
  txFile: string,
  getImport: (_: string) => string,
) => {
  const rawCode = fs.readFileSync(txFile, 'utf8')
  const code = rawCode.replace(
    /^(import\s)(\w+)(\sfrom\s)\S+$/gm,
    (_, header, name, footer) =>
      `${header}${name}${footer}0x${getImport(name)}`,
  )

  return code
}

const asBuffer = (payload: string | Buffer) =>
  typeof payload === 'string' ? Buffer.from(payload, 'hex') : payload

// calculate sha256 hash of the payload buffer
const getPayloadHash = (payload: Buffer) => {
  const hash = crypto.createHash('sha256')
  hash.update(payload)
  return hash.digest()
}

type KmsConfig = {
  region: string
  keyId: string
  accessKeyId: string
  secretAccessKey: string
}

const getKmsSigner = ({
  keyId,
  region,
  accessKeyId,
  secretAccessKey,
}: KmsConfig) => {
  const client = new KMSClient({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  })
  return async (payload: Buffer | string) => {
    const command = new SignCommand({
      KeyId: keyId,
      Message: getPayloadHash(asBuffer(payload)),
      SigningAlgorithm: KMS_SIGNING_ALGORITHM,
      MessageType: 'DIGEST',
    })

    const { Signature: signature } = await client.send(command)
    if (!signature) {
      throw new Error('KMS signing failed')
    }

    const buffered = Buffer.from(signature)
    const base64ed = derToJose(buffered, 'ES256')
    const hexed = Buffer.from(base64ed, 'base64').toString('hex')
    return hexed
  }
}

const authorizationFunction =
  (
    address: string,
    keyId: string,
    sign: (payload: Buffer | string) => Promise<string>,
  ) =>
  async (account: any) => {
    return {
      ...account,
      tempId: `${address}-${keyId}`,
      addr: fcl.sansPrefix(address),
      keyId: Number(keyId),
      signingFunction: async (signable: any) => {
        return {
          addr: fcl.withPrefix(address),
          keyId: Number(keyId),
          signature: await sign(signable.message),
        }
      },
    }
  }

const getArgs = (
  registryAddress: string,
  brand: string,
  ipfsGateway: String,
) => {
  return (arg: any, t: any) => [
    arg(registryAddress, t.Address),
    arg(brand, t.String),
    arg(ipfsGateway, t.String),
  ]
}

const NETWORK = 'mainnet'
// const ACCESS_NODE = 'https://rest-testnet.onflow.org'
const ACCESS_NODE = 'https://rest-mainnet.onflow.org'

/*
Niftory Dapper Sample
clacupltt00040hjkt5tidz25_NiftoryDapperSample
0xbabb26e959d6e018
*/

const TX_FILE =
  'cadence/transactions/metadata_views_manager_admin/update_gamisodes.cdc'

const REGISTRY = '0x32d62d5c43ad1038'
const BRAND = 'cl9bquwn300010hkzt0td7pec_Gamisodes'

const ADDRESS = '0x09e04bdbcccde6ca'
const KEY_ID = '0'

const KMS_ID = '524fd40e-23f7-41ab-8a2b-39ad8bdb5531'

const main = async () => {
  configureFcl({ network: NETWORK, accessNode: ACCESS_NODE })
  const { getContractAddress, getVariable } = parseConfig()(NETWORK)
  const code = getTransactionCode(TX_FILE, getContractAddress)
  const signer = getKmsSigner({
    keyId: KMS_ID,
    region: AWS_REGION,
    accessKeyId: AWS_ACCESS_KEY_ID,
    secretAccessKey: AWS_SECRET_ACCESS_KEY,
  })
  const args = getArgs(REGISTRY, BRAND, 'https://cloudflare-ipfs.com/ipfs/')
  const authFunction = authorizationFunction(ADDRESS, KEY_ID, signer)

  const transactionId = await fcl.mutate({
    cadence: code,
    args,
    authorizations: [authFunction],
    proposer: authFunction,
    payer: authFunction,
    limit: 9999,
  })

  const transaction = await fcl.tx(transactionId).onceSealed()
  console.log(transaction)
}

main()
