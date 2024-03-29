import { flow } from "#"
import EC from "elliptic"

type EllipticSigningAlgorithm = "secp256k1" | "p256"

interface Verifier {
  publicKey: Buffer
  verify: (data: Buffer, signature: Buffer) => boolean
}

interface Signer extends Verifier {
  privateKey: Buffer
  sign: (data: Buffer) => Buffer
}

interface EllipticAlgorithm {
  signerFromPrivateKey: (privateKey: Buffer) => Signer
  verifierFromPublicKey: (publicKey: Buffer) => Verifier
  generate: () => Signer
}

const getPublicKey = (key: EC.ec.KeyPair): Buffer => {
  const publicKey = key.getPublic()
  const xBuffer = publicKey.getX().toArrayLike(Buffer, "be", 32)
  const yBuffer = publicKey.getY().toArrayLike(Buffer, "be", 32)
  return Buffer.concat([xBuffer, yBuffer])
}

const getPrivateKey = (key: EC.ec.KeyPair): Buffer =>
  key.getPrivate().toArrayLike(Buffer, "be", 32)

const sign = (key: EC.ec.KeyPair, data: Buffer): Buffer => {
  const signature = key.sign(data)
  const rBuffer = signature.r.toArrayLike(Buffer, "be", 32)
  const sBuffer = signature.s.toArrayLike(Buffer, "be", 32)
  return Buffer.concat([rBuffer, sBuffer])
}

const verify = (
  key: EC.ec.KeyPair,
  data: Buffer,
  signature: Buffer,
): boolean => {
  const r = signature.slice(0, 32)
  const s = signature.slice(32, 64)
  return key.verify(data, { r, s })
}

const verifierFromEcKey = (key: EC.ec.KeyPair): Verifier => ({
  publicKey: getPublicKey(key),
  verify: (data: Buffer, signature: Buffer) => verify(key, data, signature),
})

const signerFromEcKey = (key: EC.ec.KeyPair): Signer => ({
  ...verifierFromEcKey(key),
  privateKey: getPrivateKey(key),
  sign: (data: Buffer) => sign(key, data),
})

const createEllipticAlgorithm = (
  algorithm: EllipticSigningAlgorithm,
): EllipticAlgorithm => {
  const ec = new EC.ec(algorithm)
  return {
    signerFromPrivateKey: flow(ec.keyFromPrivate, signerFromEcKey),
    verifierFromPublicKey: flow(ec.keyFromPublic, verifierFromEcKey),
    generate: flow(ec.genKeyPair, signerFromEcKey),
  }
}

const secp256k1 = createEllipticAlgorithm("secp256k1")
const p256 = createEllipticAlgorithm("p256")

const Elliptic = {
  secp256k1,
  p256,
}

export type { EllipticAlgorithm, Signer }
export { Elliptic }
