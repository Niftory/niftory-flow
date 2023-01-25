import { FLOW_REST_ENDPOINT_DEFAULTS } from "./defaults"
import { FlowHttp } from "./http"
import { AccountOps } from "./operations/accounts"
import { BlockOps } from "./operations/blocks"

const assertSuccess = <Body>(
  response: FlowHttp.Response<Body>,
): FlowHttp.Success<Body> => {
  if (response.tag === "failure") {
    throw new Error(
      `Expected a success response, but got\n` +
        `Failure code: ${response.code}\n` +
        `Failure response: ${response.message}`,
    )
  }
  return response
}

const create = (baseUrl: string) => {
  const wrap =
    <Params, Body>(handler: FlowHttp.Handler<Params, Body>) =>
    (params: Params) =>
      handler(baseUrl)(params).then(assertSuccess)

  const wrapNoArgs =
    <Body>(handler: FlowHttp.Handler<{}, Body>) =>
    () =>
      wrap(handler)({})

  return {
    latestBlock: wrapNoArgs(BlockOps.latest),
    blocksByHeight: wrap(BlockOps.byHeight),
    blocksById: wrap(BlockOps.byId),
    blocksBetweenHeights: wrap(BlockOps.betweenHeights),
    account: wrap(AccountOps.get),
    contracts: wrap(AccountOps.contracts),
  }
}

const emulator = () => create(FLOW_REST_ENDPOINT_DEFAULTS.EMULATOR)
const testnet = () => create(FLOW_REST_ENDPOINT_DEFAULTS.TESTNET)
const mainnet = () => create(FLOW_REST_ENDPOINT_DEFAULTS.MAINNET)

const Client = {
  create,
  emulator,
  testnet,
  mainnet,
}

export { Client }
