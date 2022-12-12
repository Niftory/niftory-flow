import NiftoryNonFungibleToken from "../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../contracts/NiftoryNFTRegistry.cdc"


pub fun main(registryAddress: Address, brand: String): CollectionInfo {
  NiftoryNFTRegistry.
  let paths = NiftoryNFTRegistry.getCollectionPaths(registryAddress, brand)
  let collection = getAccount(collectionAddress)
    .getCapability(paths.public)
    .borrow<&{NiftoryNonFungibleToken.CollectionPublic}>()!
  return CollectionInfo(
    numNfts: collection.getIDs().length,
    nftIds: collection.getIDs()
  )
}