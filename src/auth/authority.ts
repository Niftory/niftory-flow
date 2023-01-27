import { Util } from "#"

type Signer = {
  getKeyIndex: () => Promise<Util.IntLike>
  sign: (data: Buffer) => Promise<Buffer>
}

type Account = {
  address: string
}

type Authorizer = Account & {
  signers: Signer[]
}

const createAuthorizer = (address: string, signers: Signer[]): Authorizer => ({
  address,
  signers,
})

type Payer = Authorizer

type Proposer = Account &
  Signer & {
    getSequenceNumber: () => Promise<Util.IntLike>
  }

type TransactionAuthority = {
  authorizers: Authorizer[]
  payer: Payer
  proposer: Proposer
}

type Signature = {
  address: string
  keyIndex: Util.IntLike
  signature: Buffer
}

type ProposalKey = {
  address: string
  keyIndex: Util.IntLike
  sequenceNumber: Util.IntLike
}

const getPayloadSignaturesFor =
  ({ authorizers, payer, proposer }: TransactionAuthority) =>
  async (payload: Buffer): Promise<Signature[]> => {
    const flatAuthorizers = authorizers
      .filter(({ address }) => address !== payer.address)
      .flatMap(({ address, signers }) =>
        signers.map((signer) => ({ address, signer })),
      )

    const signatures: Signature[] = []
    for (const { address, signer } of flatAuthorizers) {
      const keyIndex = await signer.getKeyIndex()
      const signature = await signer.sign(payload)
      signatures.push({ address, keyIndex, signature })
    }

    if (proposer.address !== payer.address) {
      const keyIndex = await proposer.getKeyIndex()
      const signature = await proposer.sign(payload)
      signatures.push({ address: proposer.address, keyIndex, signature })
    }

    return signatures
  }

const getAuthorizationEnvelopeSignersFor =
  ({ payer }: TransactionAuthority) =>
  async (payload: Buffer): Promise<Signature[]> => {
    const signatures: Signature[] = []
    for (const signer of payer.signers) {
      const keyIndex = await signer.getKeyIndex()
      const signature = await signer.sign(payload)
      signatures.push({ address: payer.address, keyIndex, signature })
    }
    return signatures
  }

const getPayerAddress = ({ payer }: TransactionAuthority): string =>
  payer.address

const getAuthorizerAddresses = ({
  authorizers,
}: TransactionAuthority): string[] => authorizers.map(({ address }) => address)

const getProposalKey = async ({
  proposer,
}: TransactionAuthority): Promise<ProposalKey> => {
  const keyIndex = await proposer.getKeyIndex()
  const sequenceNumber = await proposer.getSequenceNumber()
  return { address: proposer.address, keyIndex, sequenceNumber }
}
