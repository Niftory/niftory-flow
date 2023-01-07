import * as Emulator from './testing/emulator'

Emulator.run({ basePath: 'src', port: 3569, logging: true }, async () => {
  /*
  INPUTS:
    client: Client
    root: Actor

  client.account
    AccountRequest => Promise<AccountResponse | Error>
  client.block
    BlockRequest => Promise<BlockResponse | Error>
  client.query
    QueryRequest => Promise<QueryResponse | Error>
  client.mutate
    TransactionRequest => Promise<TransactionResponse | Error>
  client.send
    TransactionRequest => Promise<TransactionVoucher | Error>
  client.check
    TransactionVoucher => Promise<TransactionResponse | Error>

  root: Actor

  signer = Auth.inMemory({
    privateKey:
    hashingAlgorithm:
    signingAlgorithm:
  })

  Auth
    .inMemory
    .aws
    .gcp
    .azure

  actor = Actor.simple({
    client,
    signer,
  })

  Actor
    .simple
    .full

  actor.
    .mutate({script, args, limit})
    .mutate({})
    .execute()

  brandManager = actor.connect(sdk)

  brandManager
    .mint()
    .execute()

  Response =
    Pending
      {
        _tag: "pending"
        status: Status
      }
    Success
      {
        _tag: "success",
        response: {
          events: Event[]
        }
      }
    Failure
      {
        _tag: "error"
        error:
          {
            _tag: "server"
            message: string
          }
          {
            _tag: "cadence"
            code: number
            message: string
          }
      }
  */
})
