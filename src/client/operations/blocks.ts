import { Blocks } from '../entities'
import { FlowHttp } from '../http'

type GetLatestBlockParams = {}

const getLatestBlock = FlowHttp.createHandler<GetLatestBlockParams>({
  method: 'GET',
  path: () => `/v1/blocks?height=sealed`,
})(Blocks.transform((blocks) => blocks[0]!).parse)

type GetBlockAtHeight = {
  height: number | BigInt | string
}

getLatestBlock('https://rest-mainnet.onflow.org', {}).then((resp) => {
  if (resp.tag === 'success') {
    console.log(resp.body)
  }
})
