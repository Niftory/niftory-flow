import * as fcl from '@onflow/fcl'
import * as t from '@onflow/types'
import { ec } from 'elliptic'
import { SHA3 } from 'sha3'

const PRIVATE_KEY =
  '418acca4607d4a220009623d5d4f392b0e1511a3cca422cbd54ae817a0f65f69'
const KEY_ID = '0'
const ADDRESS = '0xf8d6e0586b0a20c7'

const curve = new ec('p256')

const hashMsgHex = (msgHex: string) => {
  const sha = new SHA3(256)
  sha.update(Buffer.from(msgHex, 'hex'))
  return sha.digest()
}

const sign = (msgHex: string, privateKey: string) => {
  const key = curve.keyFromPrivate(privateKey, 'hex')
  const sig = key.sign(hashMsgHex(msgHex))
  const n = 32 // half of signature length?
  const r = sig.r.toArrayLike(Buffer, 'be', n)
  const s = sig.s.toArrayLike(Buffer, 'be', n)
  return Buffer.concat([r, s]).toString('hex')
}

const getAuthorizationFunction =
  (privateKey: string, address: string, key_id: string) =>
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
  await fcl.config().put('accessNode.api', '127.0.0.1:8888')
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
