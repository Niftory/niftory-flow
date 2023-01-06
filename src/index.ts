import * as Emulator from './testing/emulator'

Emulator.run({ basePath: 'src', port: 3569, logging: true }, async () => {
  /*
  client: Client

  client.account
    AccountRequest => AccountResponse | Error
  client.block
    BlockRequest => BlockRes
  client.query
    QueryRequest => QueryResponse | Error
  client.mutate
    TransactionRequest => TransactionResponse | Error
  client.send
    TransactionRequest => TransactionVoucher | Error
  client.check
    TransactionVoucher =>

  root: Actor

  signer = Signer.inMemory({
    privateKey:
    hashingAlgorithm:
    signingAlgorithm:
  })

  Signer
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
