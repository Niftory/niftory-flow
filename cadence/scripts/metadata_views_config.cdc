import NiftoryNFTRegistry from "../contracts/NiftoryNFTRegistry.cdc"
import MetadataViewsManager from "../contracts/MetadataViewsManager.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import NiftoryMetadataViewsResolvers from "../contracts/NiftoryMetadataViewsResolvers.cdc"

pub fun main(registryAddress: Address, brand: String): [AnyStruct?] {
  let view1 = Type<MetadataViews.Display>()
  let view2 = Type<MetadataViews.NFTCollectionDisplay>()

  let oldResolver1 = Type<NiftoryMetadataViewsResolvers.DisplayResolver>()
  let oldResolver2 = Type<NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolver>()


  let manager = NiftoryNFTRegistry.getMetadataViewsManagerPublic(
    registryAddress,
    brand
  )
  let resolver1 = manager.inspectView(view: view1)!
  let resolver2 = manager.inspectView(view: view2)!
  return [
    manager.inspectView(view: view1),
    manager.inspectView(view: view2),
    resolver1.getType().isSubtype(of: oldResolver1),
    resolver2.getType().isSubtype(of: oldResolver2)
  ]
}
