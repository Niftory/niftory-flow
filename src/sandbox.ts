import * as E from '@effect/io/Effect'
import { flow } from 'fp-ts/lib/function'
import { Auth, Util } from '.'

const program = async () => {
  const signBuffer = Auth.InMemory.fromAlias(
    'hello',
    'SHA2_256',
    'ECDSA_P256',
  ).sign
  const sign = flow(
    Util.Buffer.utf8ToBuffer,
    signBuffer,
    E.map(Util.Buffer.bufferToHex),
    E.unsafeRunPromise,
  )
  console.log(await sign('hello'))
}

program()
