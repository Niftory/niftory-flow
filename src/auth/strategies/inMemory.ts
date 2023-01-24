import { flow, pipe } from 'fp-ts/lib/function'
import { Crypto, Util } from '../..'
import { HashAlgorithm, SignatureAlgorithm, Strategy } from '../strategy'

const createAlias = flow(Util.Buffer.utf8ToBuffer, Crypto.Hashers.sha2_256.hash)

const getHasher = (hashAlgorithm: HashAlgorithm) => {
  switch (hashAlgorithm) {
    case 'SHA2_256':
      return Crypto.Hashers.sha2_256
    case 'SHA3_256':
      return Crypto.Hashers.sha3_256
  }
}

const getSigner = (signatureAlgorithm: SignatureAlgorithm) => {
  switch (signatureAlgorithm) {
    case 'ECDSA_P256':
      return Crypto.Elliptic.p256.signerFromPrivateKey
    case 'ECDSA_secp256k1':
      return Crypto.Elliptic.secp256k1.signerFromPrivateKey
  }
}

const fromPrivateKey = (
  privateKey: Buffer,
  hashAlgorithm: HashAlgorithm,
  signatureAlgorithm: SignatureAlgorithm,
): Strategy => {
  const hash = getHasher(hashAlgorithm).hash
  const sign = getSigner(signatureAlgorithm)(privateKey).sign
  return {
    sign: (data) => Promise.resolve(pipe(data, hash, sign)),
  }
}

const fromAlias = (
  alias: string,
  hashAlgorithm: HashAlgorithm,
  signatureAlgorithm: SignatureAlgorithm,
): Strategy =>
  fromPrivateKey(createAlias(alias), hashAlgorithm, signatureAlgorithm)

const InMemory = {
  fromAlias,
  fromPrivateKey,
}

export { InMemory }
