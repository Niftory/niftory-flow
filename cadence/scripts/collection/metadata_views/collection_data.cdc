import MetadataViews from "../../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../../contracts/NiftoryNFTRegistry.cdc"

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
  let view = Type<MetadataViews.NFTCollectionData>()
  let data = nft.resolveView(view)!
  let realData = data as! MetadataViews.NFTCollectionData 

  return CollectionData(
    storagePath: "a" ,
    publicPath: "b",
    providerPath: "c",
  )
//  return CollectionData(
//    storagePath: realData.storagePath.toString() ,
//    publicPath: realData.publicPath.toString(),
//    providerPath: realData.providerPath.toString(),
//  )
}