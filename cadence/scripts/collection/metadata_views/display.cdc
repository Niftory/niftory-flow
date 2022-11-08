import MetadataViews from "../../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../../contracts/NiftoryNFTRegistry.cdc"

pub struct Display {
  pub let name: String
  pub let description: String
  pub let thumbnail: String

  init(
    name: String,
    description: String,
    thumbnail: String
  ) {
    self.name = name
    self.description = description
    self.thumbnail = thumbnail
  }
}

pub fun main(
  registryAddress: Address,
  brand: String,
  collectionAddress: Address,
  nftId: UInt64
): AnyStruct {
  let paths = NiftoryNFTRegistry.getCollectionPaths(registryAddress, brand)
  let collection = getAccount(collectionAddress)
    .getCapability(paths.public)
    .borrow<&{NiftoryNonFungibleToken.CollectionPublic}>()!
  let nft = collection.borrow(id: nftId)
  let view = Type<MetadataViews.Display>()
  let data = nft.resolveView(view)!

  let realData = data as! MetadataViews.Display
  return Display(
    name: realData.name,
    description: realData.description,
    thumbnail: realData.thumbnail.uri()
  )
}
