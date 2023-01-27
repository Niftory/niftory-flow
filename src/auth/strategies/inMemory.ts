import { flow, pipe } from "fp-ts/lib/function"
import { Crypto, Util } from "../.."
import { HashAlgorithm, SignatureAlgorithm, Strategy } from "../strategy"

const createAlias = flow(
  Util.String.fromUtf8ToBuffer,
  Crypto.Hashers.sha2_256.hash,
)

const getHasher = (hashAlgorithm: HashAlgorithm) => {
  switch (hashAlgorithm) {
    case "SHA2_256":
      return Crypto.Hashers.sha2_256
    case "SHA3_256":
      return Crypto.Hashers.sha3_256
  }
}

const getSigner = (signatureAlgorithm: SignatureAlgorithm) => {
  switch (signatureAlgorithm) {
    case "ECDSA_P256":
      return Crypto.Elliptic.p256.signerFromPrivateKey
    case "ECDSA_secp256k1":
      return Crypto.Elliptic.secp256k1.signerFromPrivateKey
  }
}

const fromPrivateKey = (
  privateKey: Buffer,
  hashAlgorithm: HashAlgorithm = "SHA3_256",
  signatureAlgorithm: SignatureAlgorithm = "ECDSA_P256",
) => {
  const hasher = getHasher(hashAlgorithm)
  const signer = getSigner(signatureAlgorithm)(privateKey)
  const strategy: Strategy = {
    sign: (data) => Promise.resolve(pipe(data, hasher.hash, signer.sign)),
  }
  return {
    hasher,
    signer,
    strategy,
  }
}

const fromAlias = (
  alias: string,
  hashAlgorithm: HashAlgorithm = "SHA3_256",
  signatureAlgorithm: SignatureAlgorithm = "ECDSA_P256",
) => fromPrivateKey(createAlias(alias), hashAlgorithm, signatureAlgorithm)

const InMemory = {
  fromAlias,
  fromPrivateKey,
}

export { InMemory }
