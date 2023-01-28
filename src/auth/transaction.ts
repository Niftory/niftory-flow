/*
Transaction
  - script : string
  - arguments : any[]
  - reference_block_id : string
  - gas_limit : IntLike
  - payer : string
  - proposal_key : ProposalKey
  - authorizers : string

  - payload_signatures : Signature[]

  - envelope_signatures : Signature[]

TransactionRequest -> TransactionPayload

TransactionPayload -> PayloadSignatures

[TransactionRequest, PayloadSignatures] => AuthorizationEnvelope

AuthorizationEnvelope -> EnvelopeSignatures

[TransactionRequest, PayloadSignatures, EnvelopeSignatures]
*/

import { Util } from "#"

type TransactionRequest = {
  script: string
  arguments: any[]
  reference_block_id: string
  gas_limit: Util.IntLike
  payer: string
}
