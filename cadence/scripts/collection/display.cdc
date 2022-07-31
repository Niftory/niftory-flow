import MetadataViews from "../../contracts/MetadataViews.cdc"

import Niftory from "../../contracts/Niftory.cdc"
  
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
  collectionAddress: Address,
  collectionPath: String,
  nftId: UInt64
): AnyStruct {
  let collectionPublicPath = PublicPath(identifier: collectionPath)!
  let collection = getAccount(collectionAddress)
    .getCapability(collectionPublicPath)
    .borrow<&{Niftory.CollectionPublic}>()!
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