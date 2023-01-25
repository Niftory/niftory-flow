import {
  deployContract,
  DeployRequest,
  sendTransaction,
  TransactionFailure,
  TransactionRequest,
  TransactionResult,
  TransactionSuccess,
} from "./transaction"

const elseUndefined = (arr: any[]) => (arr.length > 0 ? arr : undefined)

type Alive = {
  _tag: "alive"
  numSuccessfulTransactions: number
  successfulTransactions: TransactionSuccess[]
}

type Dead = {
  _tag: "dead"
  numSuccessfulTransactions: number
  numFailedTransactions: number
  successfulTransactions: TransactionSuccess[]
  failedTransaction: TransactionFailure
}

type ActorContext = Dead | Alive

const newContext = (): Promise<ActorContext> =>
  Promise.resolve({
    _tag: "alive",
    numSuccessfulTransactions: 0,
    successfulTransactions: [],
  })

const registerSuccess =
  (transaction: TransactionSuccess) =>
  (context: Alive): ActorContext => ({
    _tag: "alive",
    numSuccessfulTransactions: context.numSuccessfulTransactions + 1,
    successfulTransactions: [...context.successfulTransactions, transaction],
  })

const registerFailure =
  (transaction: TransactionFailure) =>
  (context: Alive): ActorContext => ({
    ...context,
    _tag: "dead",
    numFailedTransactions: 1,
    failedTransaction: transaction,
  })

const registerTransaction = (
  transaction: TransactionResult,
): ((context: Alive) => ActorContext) =>
  transaction._tag === "success"
    ? registerSuccess(transaction)
    : registerFailure(transaction)

const registerSkip = (context: Dead): Dead => ({
  ...context,
  numFailedTransactions: context.numFailedTransactions + 1,
})

const advanceContextWith =
  <Request extends TransactionRequest | DeployRequest>(
    handler: (_: Request) => Promise<TransactionResult>,
  ) =>
  (transaction: Request) =>
  (context: ActorContext): Promise<ActorContext> =>
    context._tag === "alive"
      ? handler(transaction)
          .then(registerTransaction)
          .then((apply) => apply(context))
      : Promise.resolve(registerSkip(context))

const advanceContextWithTransaction = advanceContextWith(sendTransaction)
const advanceContextWithDeployment = advanceContextWith(deployContract)

abstract class AnyActor<Config, Actor extends AnyActor<Config, Actor>> {
  constructor(
    public _: {
      name: string | string[]
      context: Promise<ActorContext>
      config: Config
    },
  ) {}

  abstract getThis: (_: {
    name: string | string[]
    context: Promise<ActorContext>
    config: Config
  }) => Actor

  _send =
    <ExtraParams>(
      codePath: string,
      asArgs: (_: Config & ExtraParams) => any[] = () => [],
    ) =>
    (extraParams: ExtraParams): Actor =>
      this.getThis({
        ...this._,
        context: this._.context.then(
          advanceContextWithTransaction({
            codePath,
            args: asArgs({ ...this._.config, ...extraParams }),
            authorizers: Array.isArray(this._.name)
              ? this._.name
              : [this._.name],
          }),
        ),
      })

  _deploy =
    <ExtraParams>(
      codePath: string,
      asArgs: (_: Config & ExtraParams) => any[] = () => [],
    ) =>
    (extraParams: ExtraParams): Actor =>
      this.getThis({
        ...this._,
        context: this._.context.then(
          advanceContextWithDeployment({
            codePath,
            args: elseUndefined(asArgs({ ...this._.config, ...extraParams })),
            deployer: Array.isArray(this._.name) ? this._.name[0] : this._.name,
          }),
        ),
      })

  do = (handler: (context: ActorContext) => void): Actor =>
    this.getThis({
      ...this._,
      context: this._.context.then((context) => {
        handler(context)
        return context
      }),
    })

  log = (): Actor =>
    this.do((data) => {
      console.log(JSON.stringify(data, null, 2))
    })

  wait = (): Promise<ActorContext> => this._.context
}

class Actor extends AnyActor<{}, Actor> {
  getThis = (_) => new Actor(_)
}

const actor = (_) => new Actor(_)

export type { ActorContext }
export { AnyActor, newContext, actor }
