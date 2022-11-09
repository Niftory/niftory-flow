import * as fcl from '@onflow/fcl'
// import { send as transportGRPC } from '@onflow/transport-grpc'
import * as rlp from '@onflow/rlp'
import * as t from '@onflow/types'
import { ec } from 'elliptic'
import { SHA3 } from 'sha3'

const PRIVATE_KEY =
  '418acca4607d4a220009623d5d4f392b0e1511a3cca422cbd54ae817a0f65f69'
const KEY_ID = 0
const ADDRESS = '0xf8d6e0586b0a20c7'

const curve = new ec('p256')

const hashMsgHex = (msgHex: string) => {
  const sha = new SHA3(256)
  sha.update(Buffer.from(msgHex, 'hex'))
  return sha.digest()
}

const parsePresignedMessage = (msgHex: string) => {
  const msgHash = msgHex.slice(64).replace(/\s/g, '')
  const msgHashBuffer = Buffer.from(msgHash, 'hex')
  const decoded = rlp.decode(msgHashBuffer)
  const utf8 = (buffer: Buffer) => buffer.toString('utf8')
  const hex = (buffer: Buffer) => buffer.toString('hex')
  const num = (buffer: Buffer) => parseInt(hex(buffer), 16)
  return {
    script: utf8(decoded[0][0]),
    args: decoded[0][1].map((arg: any) => JSON.parse(utf8(arg))),
    referenceBlocK: hex(decoded[0][2]),
    computeLimit: num(decoded[0][3]),
    proposerAddress: hex(decoded[0][4]),
    proposerKeyId: num(decoded[0][5]),
    prposerSequenceNum: num(decoded[0][6]),
    payer: hex(decoded[0][7]),
    authorizers: decoded[0][8].map(hex),
  }
}

const sign = (msgHex: string, privateKey: string) => {
  console.log(JSON.stringify(parsePresignedMessage(msgHex), null, 2))

  // const txBuffer: Buffer = decoded[0][0]
  // const argsBuffers: Buffer[] = decoded[0][1]

  // const txString = txBuffer.toString('utf8')
  // console.log(txString)

  const key = curve.keyFromPrivate(privateKey, 'hex')
  const sig = key.sign(hashMsgHex(msgHex))
  const n = 32 // half of signature length?
  const r = sig.r.toArrayLike(Buffer, 'be', n)
  const s = sig.s.toArrayLike(Buffer, 'be', n)
  return Buffer.concat([r, s]).toString('hex')
}

const getAuthorizationFunction =
  (privateKey: string, address: string, key_id: number) =>
  async (account: any) => {
    return {
      ...account,
      tempId: `${address}-${key_id}`,
      addr: address,
      keyId: Number(key_id),
      signingFunction: async (signable) => {
        return {
          addr: address,
          keyId: Number(key_id),
          signature: sign(signable.message, privateKey),
        }
      },
    }
  }
const myAuthorizationFunction = getAuthorizationFunction(
  PRIVATE_KEY,
  ADDRESS,
  KEY_ID,
)

const main = async () => {
  // await fcl.config({
  //   'accessNode.api': '127.0.0.1:3569',
  //   'sdk.transport': transportGRPC,
  // })
  await fcl.config().put('accessNode.api', 'http://127.0.0.1:8888')
  const transactionId = await fcl.send([
    fcl.transaction`
    transaction(number: Int, greeting: String) {
      prepare(signer: AuthAccount) {
      }
      execute {}
    }
    `,
    fcl.args([fcl.arg(1, t.Int), fcl.arg('Hello', t.String)]),
    fcl.proposer(myAuthorizationFunction),
    fcl.payer(myAuthorizationFunction),
    fcl.authorizations([myAuthorizationFunction]),
    fcl.limit(9999),
  ])
  // .then(fcl.decode)

  // console.log(transactionId)
}

main()
