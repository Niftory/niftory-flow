import {
  deployContractByName,
  getAccountAddress,
  sendTransaction as sendTransaction_,
} from 'flow-js-testing'

type Account = string

type TransactionRequest = {
  codePath: string
  authorizers: Account[]
  args?: any[]
}

type DeployRequest = {
  codePath: string
  deployer: Account
  args?: any[]
}

type TransactionEvent = {
  type: String
  data: object[]
}

type TransactionSuccess = {
  _tag: 'success'
  events: TransactionEvent[]
}

type TransactionFailure = {
  _tag: 'failure'
  error: any
}

type TransactionResult = TransactionSuccess | TransactionFailure

const parseRawTransactionResult = (result: any[]): TransactionResult => {
  // We expect [ success | undefined, undefined | error]
  if (result.length != 2) {
    return {
      _tag: 'failure',
      error: new Error(`Unexpected raw transaction result: ${result}`),
    }
  }

  const [success, error] = result

  if (error != null) {
    return {
      _tag: 'failure',
      error: error,
    }
  }

  // Return success if result[0] is truthy
  // console.log(success)
  return {
    _tag: 'success',
    events: success.events.map((event) => ({
      type: event.type,
      data: event.data as object[],
    })),
  }
}

const sendTransaction = ({
  codePath,
  authorizers,
  args,
}: TransactionRequest): Promise<TransactionResult> =>
  Promise.all(authorizers.map(getAccountAddress))
    .then((accounts) => sendTransaction_(codePath, accounts, args))
    .then(parseRawTransactionResult)

const deployContract = ({
  codePath,
  deployer,
  args,
}: DeployRequest): Promise<TransactionResult> =>
  getAccountAddress(deployer)
    .then((account: any) =>
      deployContractByName({
        name: codePath,
        to: account,
        args,
      }),
    )
    .then(parseRawTransactionResult)

export type {
  TransactionRequest,
  TransactionResult,
  TransactionSuccess,
  TransactionFailure,
  DeployRequest,
}
export { sendTransaction, deployContract }
