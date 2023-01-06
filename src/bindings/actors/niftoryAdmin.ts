import { AnyActor } from '../../sdk2/actor'
import { context } from '../../utils'

class NiftoryRegistryAdmin extends AnyActor<{}, NiftoryRegistryAdmin> {
  getThis = (_) => new NiftoryRegistryAdmin(_)

  initialize = this._send<{}>('niftory_registry_admin/initialize')

  register_brand = this._send<{ brand: string; contractAddress: string }>(
    'niftory_registry_admin/register_brand',
    (_) => [_.contractAddress, _.brand],
  )

  deregister_brand = this._send<{ brand: string }>(
    'niftory_registry_admin/deregister_brand',
    (_) => [_.brand],
  )
}

const createNiftoryRegistryAdmin = (name: string): NiftoryRegistryAdmin =>
  new NiftoryRegistryAdmin({
    name,
    context,
    config: {},
  })

export { createNiftoryRegistryAdmin }
