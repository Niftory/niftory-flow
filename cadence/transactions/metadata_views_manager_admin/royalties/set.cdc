import FungibleToken from "../../../contracts/FungibleToken.cdc"
import MetadataViews from "../../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryMetadataViewsResolvers from "../../../contracts/NiftoryMetadataViewsResolvers.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  receiverAddress: Address,
  receiverPath: String,
  cut: UFix64,
  description: String
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!
  }

  execute {
    let receiverPublicPath = PublicPath(identifier: receiverPath)!
    let receiver = getAccount(receiverAddress)
      .getCapability<&AnyResource{FungibleToken.Receiver}>(receiverPublicPath)
    let royalty = MetadataViews.Royalty(
        receiver: receiver,
        cut: cut,
        description: description
    )
    let resolver = NiftoryMetadataViewsResolvers.RoyaltiesResolver(
      royalties: MetadataViews.Royalties([royalty])
    )
    self.nftManager.setMetadataViewsResolver(resolver)
  }
}
 