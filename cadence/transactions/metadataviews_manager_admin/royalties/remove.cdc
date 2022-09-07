import FungibleToken from "../../../contracts/FungibleToken.cdc"
import MetadataViews from "../../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryMetadataViewsResolvers from "../../../contracts/NiftoryMetadataViewsResolvers.cdc"

transaction(
  registryAddress: Address,
  brand: String,
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
    let type = Type<MetadataViews.Royalties>()
    self.nftManager.removeMetadataViewsResolver(type)
  }
}
