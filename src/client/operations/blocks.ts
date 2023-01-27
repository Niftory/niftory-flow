import { Util } from "#"
import { Blocks } from "../entities"
import { FlowHttp } from "../http"

type GetLatestBlockParams = {}

const latest = FlowHttp.createHandler<GetLatestBlockParams>({
  method: "GET",
  path: () => `/v1/blocks?height=sealed`,
})(Blocks.transform((blocks) => blocks[0]!).parse)

type GetBlocksByHeightParams = {
  heights: Util.IntLike[]
}

const byHeight = FlowHttp.createHandler<GetBlocksByHeightParams>({
  method: "GET",
  path: (params) =>
    `/v1/blocks?height=${params.heights.map(Util.IntLike.asString).join(",")}`,
})(Blocks.parse)

type GetBlocksBetweenHeightsParams = {
  start: Util.IntLike
  end: Util.IntLike
}

const betweenHeights = FlowHttp.createHandler<GetBlocksBetweenHeightsParams>({
  method: "GET",
  path: (params) =>
    `/v1/blocks` +
    `?start_height=${Util.IntLike.asString(params.start)}` +
    `&end_height=${Util.IntLike.asString(params.end)}`,
})(Blocks.parse)

type GetBlocksByIdParams = {
  ids: string[]
}

const byId = FlowHttp.createHandler<GetBlocksByIdParams>({
  method: "GET",
  path: (params) => `/v1/blocks/${params.ids.join(",")}`,
})(Blocks.parse)

const BlockOps = {
  latest,
  byHeight,
  byId,
  betweenHeights,
}

export { BlockOps }
