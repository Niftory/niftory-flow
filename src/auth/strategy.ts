type HashAlgorithm = 'SHA2_256' | 'SHA3_256'
type SignatureAlgorithm = 'ECDSA_P256' | 'ECDSA_secp256k1'

interface Strategy {
  sign: (data: Buffer) => Promise<Buffer>
}

export type { Strategy, HashAlgorithm, SignatureAlgorithm }
