import MutableMetadata from "../../contracts/MutableMetadata.cdc"
import MutableMetadataSet from "../../contracts/MutableMetadataSet.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  initialMetadata: {String: String}
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
    let mutableMetadata <- MutableMetadata.create(metadata: initialMetadata)
    let mutableSet <- MutableMetadataSet.create( metadata: <- mutableMetadata)
    self.nftManager.addSet(<-mutableSet)
  }
}