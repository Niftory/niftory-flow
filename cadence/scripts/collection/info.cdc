import Niftory from "../../contracts/Niftory.cdc"

pub struct CollectionInfo {
  pub let numNfts: Int
  pub let nftIds: [UInt64]
  init(numNfts: Int, nftIds: [UInt64]) {
    self.numNfts = numNfts
    self.nftIds = nftIds
  }
}

pub fun main(collectionAddress: Address, collectionPath: String): CollectionInfo {
  let collectionPublicPath = PublicPath(identifier: collectionPath)!
  let collection = getAccount(collectionAddress)
    .getCapability(collectionPublicPath)
    .borrow<&{Niftory.CollectionPublic}>()!
  return CollectionInfo(
    numNfts: collection.getIDs().length,
    nftIds: collection.getIDs()
  )
}