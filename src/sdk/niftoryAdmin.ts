import { AnyActor } from '../actor'
import { context } from '../utils'

type NiftoryAdminConfig = {}

class NiftoryAdmin extends AnyActor<NiftoryAdminConfig, NiftoryAdmin> {
  getThis = (_) => new NiftoryAdmin(_)

  initialize = this._send<{}>('niftory_admin/initialize')

  register_brand = this._send<{ brand: string; contractAddress: string }>(
    'niftory_admin/register_brand',
    (_) => [_.contractAddress, _.brand],
  )

  deregister_brand = this._send<{ brand: string }>(
    'niftory_admin/deregister_brand',
    (_) => [_.brand],
  )
}

const createNiftoryAdmin = (name: string): NiftoryAdmin =>
  new NiftoryAdmin({ name, context, config: {} })

export { createNiftoryAdmin }
