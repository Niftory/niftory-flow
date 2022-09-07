import MetadataViews from "../../contracts/MetadataViews.cdc"

import Niftory from "../../contracts/Niftory.cdc"

pub struct CollectionData {
  pub let storagePath: String
  pub let publicPath: String
  pub let providerPath: String
  init(
    storagePath: String,
    publicPath: String,
    providerPath: String
  ) {
    self.storagePath = storagePath
    self.publicPath = publicPath
    self.providerPath = providerPath
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
  let view = Type<MetadataViews.NFTCollectionData>()
  let data = nft.resolveView(view)!
  let realData = data as! MetadataViews.NFTCollectionData 

  return CollectionData(
    storagePath: realData.storagePath.toString() ,
    publicPath: realData.publicPath.toString(),
    providerPath: realData.providerPath.toString(),
  )
}