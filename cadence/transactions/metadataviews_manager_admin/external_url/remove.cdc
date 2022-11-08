import MetadataViews from "../../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../../contracts/NiftoryNFTRegistry.cdc"

transaction(registryAddress: Address, brand: String) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!
  }

  execute {
    let type = Type<MetadataViews.ExternalURL>()
    self.nftManager.removeMetadataViewsResolver(type)
  }
}
