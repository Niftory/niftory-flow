import { AnyActor } from '../sdk2/actor'
import { context } from '../sdk2/utils'

type ContractAccountConfig = {}

class ContractDeployer<ValidContract extends string> extends AnyActor<
  ContractAccountConfig,
  ContractDeployer<ValidContract>
> {
  getThis = (_) => new ContractDeployer<ValidContract>(_)
  deploy = (contract: ValidContract) => this._deploy(contract)({})
}

const createBaseContractDeployer = (
  name: string,
): ContractDeployer<
  'NonFungibleToken' | 'MetadataViews' | 'NFTStorefrontV2' | 'TokenForwarding'
> => new ContractDeployer({ name, context, config: {} })

const createExternalContractDeployer = (
  name: string,
): ContractDeployer<
  'DapperUtilityCoin' | 'FlowUtilityToken' | 'NFTCatalog' | 'NFTCatalogAdmin'
> => new ContractDeployer({ name, context, config: {} })

const createNiftoryContractDeployer = (
  name: string,
): ContractDeployer<
  | 'MetadataViewsManager'
  | 'MutableMetadata'
  | 'MutableMetadataSet'
  | 'MutableMetadataSetManager'
  | 'MutableMetadataTemplate'
  | 'NiftoryNonFungibleToken'
  | 'NiftoryNonFungibleTokenProxy'
  | 'NiftoryMetadataViewsResolvers'
  | 'NiftoryNFTRegistry'
> => new ContractDeployer({ name, context, config: {} })

export {
  createBaseContractDeployer,
  createExternalContractDeployer,
  createNiftoryContractDeployer,
}
