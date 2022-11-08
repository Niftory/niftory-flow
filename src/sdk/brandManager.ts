import { AnyActor } from '../actor'
import { context } from '../utils'

type BrandManagerConfig = {
  registryAddress: string
  brand: string
}

class BrandManager extends AnyActor<BrandManagerConfig, BrandManager> {
  getThis = (_) => new BrandManager(_)

  initialize_proxy = this._send<{}>('brand_manager/initialize_proxy')

  initialize_collection = this._send<{}>('collector/initialize', (_) => [
    _.registryAddress,
    _.brand,
  ])

  add_set = this._send<{
    initialMetadata: { [key: string]: string }
  }>('brand_manager/add_set', (_) => [
    _.registryAddress,
    _.brand,
    _.initialMetadata,
  ])

  add_template = this._send<{
    setId: number
    initialMetadata: { [key: string]: string }
    maxMint?: number
  }>('brand_manager/add_template', (_) => [
    _.registryAddress,
    _.brand,
    _.setId,
    _.initialMetadata,
    _.maxMint,
  ])
}

const createBrandManager = (
  name: string,
  registryAddress: string,
  brand: string,
): BrandManager =>
  new BrandManager({ name, context, config: { registryAddress, brand } })

export { createBrandManager }
