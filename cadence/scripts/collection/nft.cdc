import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

pub struct NFTInfo {
  pub let id: UInt64
  pub let serial: UInt64
  pub let setId: Int
  pub let templateId: Int
  pub let metadata: AnyStruct
  pub let setMetadata: AnyStruct
  pub let views: [Type]
  init(
    id: UInt64,
    serial: UInt64,
    setId: Int,
    templateId: Int,
    metadata: AnyStruct,
    setMetadata: AnyStruct,
    views: [Type]
  ) {
    self.id = id
    self.serial = serial
    self.setId = setId
    self.templateId = templateId
    self.metadata = metadata
    self.setMetadata = setMetadata
    self.views = views
  }
}

pub fun main(
  registryAddress: Address,
  brand: String,
  collectionAddress: Address,
  nftId: UInt64
): NFTInfo {
  let paths = NiftoryNFTRegistry.getCollectionPaths(registryAddress, brand)
  let collection = getAccount(collectionAddress)
    .getCapability(paths.public)
    .borrow<&{NiftoryNonFungibleToken.CollectionPublic}>()!
  let nft = collection.borrow(id: nftId)
  return NFTInfo(
    id: nft.id,
    serial: nft.serial,
    setId: nft.setId,
    templateId: nft.templateId,
    metadata: nft.metadata().get(),
    setMetadata: nft.set().metadata().get(),
    views: nft.getViews()
  )
}
 