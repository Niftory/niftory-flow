import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

pub struct CollectionInfo {
  pub let numNfts: Int
  pub let nftIds: [UInt64]
  init(numNfts: Int, nftIds: [UInt64]) {
    self.numNfts = numNfts
    self.nftIds = nftIds
  }
}

pub fun main(registryAddress: Address, brand: String, collectionAddress: Address): CollectionInfo {
  let paths = NiftoryNFTRegistry.getCollectionPaths(registryAddress, brand)
  let collection = getAccount(collectionAddress)
    .getCapability(paths.public)
    .borrow<&{NiftoryNonFungibleToken.CollectionPublic}>()!
  return CollectionInfo(
    numNfts: collection.getIDs().length,
    nftIds: collection.getIDs()
  )
}