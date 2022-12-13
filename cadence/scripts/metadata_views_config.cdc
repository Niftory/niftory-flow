import NiftoryNFTRegistry from "../contracts/NiftoryNFTRegistry.cdc"
import MetadataViewsManager from "../contracts/MetadataViewsManager.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

pub fun main(registryAddress: Address, brand: String): AnyStruct? {
  let view = Type<MetadataViews.Display>()
  let manager = NiftoryNFTRegistry.getMetadataViewsManagerPublic(
    registryAddress,
    brand
  )
  return manager.inspectView(view: view)
}
