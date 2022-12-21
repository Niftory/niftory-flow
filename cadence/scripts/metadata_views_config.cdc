import NiftoryNFTRegistry from "../contracts/NiftoryNFTRegistry.cdc"
import MetadataViewsManager from "../contracts/MetadataViewsManager.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import NiftoryMetadataViewsResolvers from "../contracts/NiftoryMetadataViewsResolvers.cdc"

pub fun main(registryAddress: Address, brand: String): [AnyStruct?] {
  let manager = NiftoryNFTRegistry.getMetadataViewsManagerPublic(
    registryAddress,
    brand
  )
  let views = manager.getViews()
  return [views]
}
