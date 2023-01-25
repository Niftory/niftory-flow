import { Account, Contracts } from "../entities"
import { FlowHttp } from "../http"

type GetAccountParams = {
  address: string
}

const get = FlowHttp.createHandler<GetAccountParams>({
  method: "GET",
  path: (params) => `/v1/accounts/${params.address}?expand=keys`,
})(Account.parse)

type GetAccountContractsParams = {
  address: string
}

const contracts = FlowHttp.createHandler<GetAccountContractsParams>({
  method: "GET",
  path: (params) => `/v1/accounts/${params.address}?expand=contracts`,
})(Contracts.parse)

const AccountOps = {
  get,
  contracts,
}

export { AccountOps }
