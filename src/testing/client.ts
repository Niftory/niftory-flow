import * as fcl from '@onflow/fcl'

type Network = 'emulator' | 'testnet' | 'mainnet'
type SignatureAlgorithm = 'ECDSA_P256' | 'ECDSA_secp256k1'
type HashingAlgorithm = 'SHA2_256' | 'SHA3_256'

type Config = {
  endpoint: string
  network: Network
}

interface Client {
  do: <A>(action: () => Promise<A>) => Promise<A>
}

const client = ({ endpoint, network }: Config): Client => ({
  do: (action) => {
    fcl.config().put('accessNode.api', endpoint).put('flow.network', network)
    return action()
  },
})

type KeyObject = {
  index: number
  publicKey: string
  signAlgo: SignatureAlgorithm
  hashAlgo: HashingAlgorithm
  weight: number
  sequenceNumber: number
  revoked: boolean
}

type ProposalKeyObject = {
  address: string
  keyIndex: number
  sequenceNumber: number
}

type AccountObject = {
  address: string
  balance: BigInt
  keys: KeyObject[]
}

type AccountRequest = {
  address: string
}

type AccountResponse = AccountObject

const getAccount = (request: AccountRequest, client: Client): AccountResponse =>
  client.do(async () => {
    const response = await fcl.send([fcl.getAccount(address)]).then(fcl.decode)
    return response as AccountResponse
  })
