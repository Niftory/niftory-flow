import { z } from 'zod'
import { Account } from './entities'
import { FlowHttp } from './http'

const stringifyBigInt = (key: any, value: any) =>
  typeof value === 'bigint' ? value.toString() : value

const exampleHandler = FlowHttp.createHandler<{ address: string }>({
  method: 'GET',
  path: (params) => `/v1/accounts/${params.address}?expand=keys,contracts`,
})(Account.parse)

exampleHandler('https://rest-mainnet.onflow.org', {
  address: '7ec1f607f0872a9e',
}).then((resp) => {
  if (resp.tag === 'success') {
    console.log(resp.body)
  }
})
