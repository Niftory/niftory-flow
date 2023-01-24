import { z } from 'zod'

const trim0x = (s: string) => (s.startsWith('0x') ? s.slice(2) : s)

const AddressSansPrefix = z.string().transform(trim0x)

const Base64 = z.string().transform((s) => Buffer.from(s, 'base64').toString())

const Signature = z.string().transform((s) => Buffer.from(s, 'base64'))

const Timestamp = z.string().transform((s) => new Date(s))

const Block = z
  .object({
    header: z.object({
      id: z.string(),
      height: z.string().transform(BigInt),
      parent_id: z.string(),
      timestamp: Timestamp,
    }),
  })
  .transform((block) => block.header)

const Blocks = z.array(Block)

type Blocks = z.infer<typeof Blocks>

const Key = z.object({
  index: z.string().transform(BigInt),
  public_key: AddressSansPrefix,
  signing_algorithm: z.union([
    z.literal('ECDSA_P256'),
    z.literal('ECDSA_secp256k1'),
  ]),
  hashing_algorithm: z.union([z.literal('SHA2_256'), z.literal('SHA3_256')]),
  sequence_number: z.string().transform(BigInt),
  weight: z.string().transform(Number),
  revoked: z.boolean(),
})

const Account = z.object({
  address: AddressSansPrefix,
  balance: z.string().transform(BigInt),
  keys: z.array(Key),
})

type Account = z.infer<typeof Account>

const Contracts = z.object({
  address: AddressSansPrefix,
  balance: z.string().transform(BigInt),
  contracts: z.record(Base64),
})

type Contracts = z.infer<typeof Contracts>

export { Account, Contracts, Blocks }
