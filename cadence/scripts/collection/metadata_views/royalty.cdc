import MetadataViews from "../../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../../contracts/NiftoryNFTRegistry.cdc"

pub struct Royalty {
  pub let token: String 
  pub let receiverPath: String
  pub let cut: UFix64
  pub let description: String
  init(
    token: String,
    receiverPath: String,
    cut: UFix64, 
    description: String
  ) {
    self.token = token
    self.receiverPath = receiverPath
    self.cut = cut
    self.description = description
  }
}

pub fun main(
  registryAddress: Address,
  brand: String,
  collectionAddress: Address,
  nftId: UInt64
): AnyStruct? {
  let paths = NiftoryNFTRegistry.getCollectionPaths(registryAddress, brand)
  let collection = getAccount(collectionAddress)
    .getCapability(paths.public)
    .borrow<&{NiftoryNonFungibleToken.CollectionPublic}>()!
  let nft = collection.borrow(id: nftId)
  let view = Type<MetadataViews.Royalties>()
  let data = nft.resolveView(view)!
  let realData = data as! MetadataViews.Royalties
  let royalty = realData.getRoyalties()[0]
  return Royalty(
    token: royalty.receiver.borrow()!.getType().identifier,
    receiverPath: paths.public.toString(),
    cut: royalty.cut,
    description: royalty.description
  )
}