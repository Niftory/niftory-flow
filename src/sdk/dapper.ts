import { AnyActor } from '../actor'
import { context } from '../utils'

type DapperTripleAuthorizerConfig = {}

class DapperTripleAuthorizer extends AnyActor<
  DapperTripleAuthorizerConfig,
  DapperTripleAuthorizer
> {
  getThis = (_) => new DapperTripleAuthorizer(_)

  custom_buy = this._send<{
    merchantAccountAddress: string
    registryAddress: string
    brand: string
    nftId?: number | undefined
    setId?: number | undefined
    templateId?: number | undefined
    price: string
  }>('external/buy_from_dapper_with_duc_emulator', (_) => [
    _.merchantAccountAddress,
    _.registryAddress,
    _.brand,
    _.nftId,
    _.setId,
    _.templateId,
    _.price,
  ])
}

const createDapperTripleAuthorizer = (
  minterName: string,
  dapperName: string,
  buyerName: string,
): DapperTripleAuthorizer =>
  new DapperTripleAuthorizer({
    name: [minterName, dapperName, buyerName],
    context,
    config: {},
  })

export { createDapperTripleAuthorizer }
