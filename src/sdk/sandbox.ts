import * as fcl from '@onflow/fcl'
import { parseError } from './errors'
const main = async () => {
  fcl
    .config()
    .put('accessNode.api', 'http://127.0.0.1:8888')
    .put('flow.network', 'emulator')
  let account: Promise<any>
  try {
    account = await fcl.account('0x0000000000000T09')
  } catch (e: unknown) {
    console.log(parseError(e))
  }
}
main()
// account.then(console.log)
