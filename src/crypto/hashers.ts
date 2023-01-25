import { pipe } from "#"
import crypto from "crypto"

type NodeCryptoHashAlgorithm = "sha256" | "sha3-256" | "md5"

interface Hasher {
  hash: (data: Buffer) => Buffer
}

const hashToBuffer = (hash: crypto.Hash) => Buffer.from(hash.digest())

const createNodeCryptoHasher = (
  algorithm: NodeCryptoHashAlgorithm,
): Hasher => ({
  hash: (data: Buffer) =>
    pipe(crypto.createHash(algorithm).update(data), hashToBuffer),
})

const sha2_256 = createNodeCryptoHasher("sha256")
const sha3_256 = createNodeCryptoHasher("sha3-256")
const md5 = createNodeCryptoHasher("md5")

const Hashers = {
  sha2_256,
  sha3_256,
  md5,
}

export type { Hasher }
export { Hashers }
