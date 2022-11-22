import { AnyActor } from '../sdk/actor'
import { context } from '../utils'

type ContractManagerConfig = {}

class ContractManager extends AnyActor<ContractManagerConfig, ContractManager> {
  getThis = (_) => new ContractManager(_)
  deployNFTContract = this._deploy<{
    // registryAddress: string
    // brand: string
  }>(
    'NiftoryTemplate',
    // (_) => [_.registryAddress, _.brand]
  )

  transfer_proxy = this._send<{
    registryAddress: string
    brand: string
    proxyAddress: string
  }>('contract_manager/transfer_proxy', (_) => [
    _.registryAddress,
    _.brand,
    _.proxyAddress,
  ])
}

const createContractManager = (name: string): ContractManager =>
  new ContractManager({ name, context, config: {} })

export { createContractManager }

// type NiftoryAdminConfig = {}

// class NiftoryAdmin extends AnyActor<NiftoryAdminConfig, NiftoryAdmin> {
//   getThis = (_) => new NiftoryAdmin(_)

//   initialize = this._send<{}>('niftory_admin/initialize')

//   register_brand = this._send<{ brand: string; contractAddress: string }>(
//     'niftory_admin/register_brand',
//     (_) => [_.contractAddress, _.brand],
//   )

//   deregister_brand = this._send<{ brand: string }>(
//     'niftory_admin/deregister_brand',
//     (_) => [_.brand],
//   )
// }

// const createNiftoryAdmin = (name: string): NiftoryAdmin =>
//   new NiftoryAdmin({ name, context, config: {} })

// export { createNiftoryAdmin }
